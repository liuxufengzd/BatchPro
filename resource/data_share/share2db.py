import argparse

from delta import configure_spark_with_delta_pip, DeltaTable
from pyspark.sql import SparkSession

parser = argparse.ArgumentParser(description="A Python script that accepts arguments")
parser.add_argument('-t', type=str, help='Table name', required=True)
parser.add_argument('-d', type=str, help='The date partition with pattern "yyyy-MM-dd"', required=True)
args = parser.parse_args()
table = args.t
date = args.d
database = 'gmall_report'
host = 'hadoop102:3306'
driver = 'com.mysql.cj.jdbc.Driver'
user = 'root'
password = '000000'

builder = (SparkSession.builder.
           appName(f"{table}_load_to_db").
           master("yarn").
           config("spark.sql.shuffle.partitions", 6).
           config("spark.sql.warehouse.dir", f"hdfs://hadoop102:8020/user/lakehouse").
           config("hive.metastore.uris", "thrift://hadoop102:9083").
           config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension").
           config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog").
           enableHiveSupport())
spark = configure_spark_with_delta_pip(builder).getOrCreate()

url = (f'jdbc:mysql://{host}/{database}?useSSL=false&allowPublicKeyRetrieval=true'
       '&useUnicode=true&characterEncoding=utf-8')
props = {'driver': driver, 'user': user, 'password': password}

partition_key = "date_id"
partition_columns = DeltaTable.forName(spark, table).detail().select('partitionColumns').collect()[0][0]
if len(partition_columns) > 0:
    partition_key = partition_columns[0]

spark.table(table).where(f"{partition_key}='{date}'").write.jdbc(url, table, mode='append', properties=props)

spark.sparkContext.stop()
