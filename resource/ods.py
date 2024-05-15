import argparse
import json
import os
import re
from argparse import ArgumentError
from datetime import datetime

from delta import configure_spark_with_delta_pip
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql.functions import lit, from_json, col
from pyspark.sql.types import *

BASE_TYPES = ('short', 'integer', 'long', 'float', 'double', 'string', 'timestamp', 'date', 'boolean')


def get_base_type(type_name: str) -> DataType:
    if type_name == 'short':
        return ShortType()
    if type_name == 'integer':
        return IntegerType()
    if type_name == 'long':
        return LongType()
    if type_name == 'float':
        return FloatType()
    if type_name == 'double':
        return DoubleType()
    if type_name == 'string':
        return StringType()
    if type_name == 'timestamp':
        return TimestampType()
    if type_name == 'date':
        return DateType()
    if type_name == 'boolean':
        return BooleanType()


def get_type(type_name: str) -> DataType:
    if type_name in BASE_TYPES:
        return get_base_type(type_name)
    match = re.match("^array<(.+)>$", type_name)
    if match:
        return ArrayType(get_type(match.group(1).strip()))
    match = re.match("^map<(.+),(.+)>$", type_name)
    if match:
        return MapType(get_type(match.group(1).strip()), get_type(match.group(2).strip()))
    return struct_dict[type_name]


def parse_struct(struct: dict):
    struct_type = struct_dict[struct['name']]
    if len(struct_type.fieldNames()) > 0:
        return
    for column in struct['schema']:
        column_name = column['name']
        column_type = column['type'].replace('?', '')
        struct_type.add(column_name, get_type(column_type), column['type'].endswith('?'))


def is_date(string):
    try:
        datetime.strptime(string, date_format)
        return True
    except ValueError:
        return False


def table_full_sync(db: str, tb: str, columns: list) -> DataFrame:
    host = 'hadoop102:3306'
    driver = 'com.mysql.cj.jdbc.Driver'
    username = 'root'
    password = '000000'
    url = (f'jdbc:mysql://{host}/{db}?useSSL=false&allowPublicKeyRetrieval=true'
           '&useUnicode=true&characterEncoding=utf-8')
    query = f"SELECT {','.join(columns)} FROM {tb}"

    return (spark
            .read.format('jdbc')
            .option("url", url)
            .option('driver', driver)
            .option('user', username)
            .option('password', password)
            .option("query", query)
            .load())


parser = argparse.ArgumentParser(description="A Python script that accepts arguments")
parser.add_argument('-c', type=str, help='The configuration path')
parser.add_argument('-t', type=str, help='The date partition with pattern "yyyy-MM-dd"')
args = parser.parse_args()
date_format = "%Y-%m-%d"
date = args.t if args.t is not None else ''
if not is_date(date):
    raise ArgumentError(None, f"date should be with the format {date_format}")
config_path = args.c
if config_path is None:
    raise ArgumentError(None, "Configuration path is required")
with open(config_path, encoding="utf-8") as f:
    context = json.load(f)

structs = context.get("structs")
struct_dict = {}
if structs:
    for s in structs:
        struct_dict[s['name']] = StructType()

    for s in structs:
        parse_struct(s)

source = context["source"]
schema = StructType()
for column in source["schema"]:
    col_name = column['name']
    col_type = column['type'].replace('?', '')
    schema.add(col_name, get_type(col_type), column['type'].endswith('?'))
app = context["env"].get("app")
layer = context["env"]["layer"]
nickname = context["env"]["table"]
table_name = f"{layer}_{nickname}"
if app is not None:
    table_name = f"{app}_{table_name}"

# Hive metastore is only used for mapping table name with delta table path
# All other metadata is stored in transactional log entry of the delta table
builder = (SparkSession.builder.
           appName(table_name).
           master("yarn").
           config("spark.sql.shuffle.partitions", 6).
           config("spark.sql.warehouse.dir", "hdfs://hadoop102:8020/user/lakehouse").
           config("hive.metastore.uris", "thrift://hadoop102:9083").
           config("spark.sql.sources.partitionOverwriteMode", "dynamic").
           config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension").
           config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog").
           enableHiveSupport())
spark = configure_spark_with_delta_pip(builder).getOrCreate()

sink_path = f"/user/lakehouse/{app}/{layer}/{nickname}"
partition_date_id = "date__"
compression = "gzip"

if source.get('database'):
    # RDBMS table full sync
    column_names = [column.name for column in schema]
    df = (table_full_sync(source['database'], source['table'], column_names).
          withColumn(partition_date_id, lit(date)))
    (df.write.mode("overwrite").format('delta')
     .partitionBy(partition_date_id)
     .option("compression", compression)
     .saveAsTable(table_name, path=sink_path))
elif source.get('topic'):
    # Kafka database table incremental sync -> read from raw folder
    options = source.get("options")
    input_path = f"/user/lakehouse/raw/{source['topic']}"
    reader = spark.read.format('delta')
    if options:
        for key in options.keys():
            reader = reader.option(key, options[key])
    df = reader.load(input_path).select("*")
    if source['topic'] == 'topic_db':
        df = df.where(f"table = '{source['table']}'")
    df = df.where(f"date = '{date}'")
    df = ((df.select(from_json(col('value'), schema).alias('value'))
          .select(col('value.*')))
          .withColumn(partition_date_id, lit(date)))

    (df.write.mode("overwrite").format('delta')
     .partitionBy(partition_date_id)
     .option("compression", compression)
     .saveAsTable(table_name, path=sink_path))
else:
    # Default: Local source
    options = source.get("options")
    input_path = f"file:///{os.getcwd()}/../local/{source['filename']}"
    file_format = "csv"
    if source.get('format'):
        file_format = source['format']
        if file_format == "text" or file_format == "tsv":
            file_format = "csv"
    reader = spark.read.format(file_format).schema(schema)
    if options:
        for key in options.keys():
            reader = reader.option(key, options[key])
    (reader
     .load(input_path)
     .write
     .mode("overwrite")
     .format('delta')
     .option("compression", compression)
     .saveAsTable(table_name, path=sink_path))

spark.sparkContext.stop()
