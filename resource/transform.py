import argparse
import importlib
import json
import os
from argparse import ArgumentError
from datetime import datetime, timedelta
import sqlparse
from delta import configure_spark_with_delta_pip, DeltaTable
from pyspark.sql import SparkSession
from pyspark.sql.functions import lit


def is_date(string):
    try:
        datetime.strptime(string, date_format)
        return True
    except ValueError:
        return False


def remove_comment_lines(s):
    return '\n'.join(line for line in s.split('\n') if not line.strip().startswith('--'))


def get_default_layer(current_layer):
    if current_layer == 'ads':
        return 'dws'
    if current_layer == 'dws':
        return 'dwd'
    return 'ods'


parser = argparse.ArgumentParser(description="A Python script that accepts arguments")
parser.add_argument('-c', type=str, help='The configuration path')
parser.add_argument('-s', type=str, help='The transformation SQL script path')
parser.add_argument('-f', type=str, help='The udf path')
parser.add_argument('-t', type=str, help='The date partition with format "yyyy-MM-dd"')
args = parser.parse_args()
date_format = "%Y-%m-%d"
date = args.t if args.t is not None else datetime.utcnow().strftime(date_format)
if not is_date(date):
    raise ArgumentError(None, f"date should be with format {date_format}")
config_path = args.c
if config_path is None:
    raise ArgumentError(None, "Configuration path is required")
with open(config_path, encoding="utf-8") as f:
    context = json.load(f)

sql_file = f"{os.path.dirname(config_path)}/{context['transform']['sql']}.sql"
if args.s is not None:
    sql_file = args.s

default_partition_key = 'date__'
layer = context["env"]["layer"].lower()
app = context["env"]["app"]
nickname = context["env"]["table"]
table_name = f"{app}_{layer}_{nickname}"

builder = (SparkSession.builder.
           appName(table_name).
           master("yarn").
           config("spark.sql.shuffle.partitions", 6).
           config("spark.sql.crossJoin.enabled", True).
           config("spark.sql.sources.partitionOverwriteMode", "dynamic").
           config("spark.sql.warehouse.dir", "hdfs://hadoop102:8020/user/lakehouse").
           config("hive.metastore.uris", "thrift://hadoop102:9083").
           config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension").
           config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog").
           enableHiveSupport())
spark = configure_spark_with_delta_pip(builder).getOrCreate()

udf_register = context['transform'].get("udf")
if udf_register:
    spark.sparkContext.addPyFile(args.f)
    try:
        file_name = os.path.splitext(os.path.basename(args.f))[0]
        udf = importlib.import_module(file_name)
        for udf_name in udf_register:
            spark.udf.register(udf_name, getattr(udf, udf_name))
    except ModuleNotFoundError:
        raise ModuleNotFoundError("Cannot import udf module")

for source in context["sources"]:
    columns = ""
    for column in source['columns']:
        columns += f"{column},"

    source_layer = get_default_layer(layer)
    if source.get('layer'):
        source_layer = source['layer']
    source_table_name = f"{app}_{source_layer}_{source['table']}"
    partition_key = default_partition_key
    partition_columns = DeltaTable.forName(spark, source_table_name).detail().select('partitionColumns').collect()[0][0]
    if len(partition_columns) > 0:
        partition_key = partition_columns[0]

    view_name = source.get('variable')
    if view_name is None:
        view_name = source['table']
    if source.get('range'):
        timerange = source['range']
        v1, v2 = json.loads(timerange)
        start_date = (datetime.strptime(date, date_format) + timedelta(days=v1)).strftime(date_format)
        end_date = (datetime.strptime(date, date_format) + timedelta(days=v2)).strftime(date_format)
        sql_str = f"""
            SELECT {columns.rstrip(',')}
            FROM {source_table_name}
            WHERE {partition_key} >= "{start_date}" AND {partition_key} <= "{end_date}"
            """
        spark.sql(sql_str).createTempView(view_name)
    else:
        dates = [date]
        if source.get('dates'):
            dates = source['dates']
        filter_condition = []
        for d in dates:
            filter_condition.append(f'{partition_key} = "{d}"')
        filter_clause = ' OR '.join(filter_condition)
        sql_str = f"""
            SELECT {columns.rstrip(',')}
            FROM {source_table_name}
            WHERE {filter_clause}
            """
        spark.sql(sql_str).createTempView(view_name)

with open(sql_file) as f:
    sql = remove_comment_lines(f.read())

statements = sqlparse.split(sql)
df = None
for statement in statements:
    parsed = sqlparse.parse(statement)[0]
    if "=" in statement:
        tokens = [token.value for token in parsed.tokens if not token.is_whitespace]
        transform = " ".join(tokens[2:]).replace('${date}', date)
        df = spark.sql(transform)
        variable = tokens[0]
        spark.catalog.dropTempView(variable)
        df.createTempView(variable)

partition_key = default_partition_key
if not context.get("sink") or not context["sink"].get("partitionBy"):
    df = df.withColumn(partition_key, lit(date))
else:
    partition_key = context["sink"]["partitionBy"]
writer = (df.write.mode('overwrite')
          .partitionBy(partition_key)
          .format('delta')
          .saveAsTable(table_name, path=f"/user/lakehouse/{app}/{layer}/{nickname}"))

spark.sparkContext.stop()
