import sys
from argparse import ArgumentError
from delta import configure_spark_with_delta_pip
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, expr
from pyspark.sql.types import StructType, StructField, StringType, LongType

args = sys.argv
if len(args) != 2:
    raise ArgumentError(None, "Topic name is required")
topic = args[1]

builder = (SparkSession.builder
           .appName(f"{topic}_sync")
           .master("yarn")
           .config("spark.sql.shuffle.partitions", 6)
           .config("spark.sql.warehouse.dir", "hdfs://hadoop102:8020/user/lakehouse")
           .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
           .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog"))
spark = configure_spark_with_delta_pip(builder).getOrCreate()

kafka_servers = ["hadoop102:9092", "hadoop103:9092", "hadoop104:9092"]
df = (spark.readStream.format('kafka')
      .option("kafka.bootstrap.servers", ",".join(kafka_servers))
      .option("subscribe", topic)
      .load())
df = df.selectExpr("CAST(value AS STRING)")

if topic == "topic_db":
    df = df.select(
        col("value"),
        from_json(col("value"), StructType(
            [StructField("table", StringType(), False),
             StructField("ts", LongType(), False)]
        )).alias("partitions")
    ).select(
        col("value"),
        col("partitions.table").alias("table"),
        expr('from_unixtime(partitions.ts, "yyyy-MM-dd")').alias('date')
    )
    partitions = ['table', 'date']
elif topic == "topic_log_copilot":
    df = df.select(
        col("value"),
        from_json(col("value"), StructType([StructField("Time", StringType(), False)]
                                           )).alias("partitions")
    ).select(
        col("value"),
        expr('to_date(partitions.Time)').alias('date')
    )
    partitions = ["date"]
elif topic == "topic_log":
    df = df.select(
        col("value"),
        from_json(col("value"), StructType([StructField("ts", LongType(), False)]
                                           )).alias("partitions")
    ).select(
        col("value"),
        expr('from_unixtime(ts/1000, "yyyy-MM-dd")').alias('date')
    )
    partitions = ["date"]
else:
    raise Exception("Not a valid topic")

sink_path = f"/user/lakehouse/raw/{topic}"
ck_path = f"{sink_path}/_checkpoint"
(df.writeStream.format('delta')
 .outputMode('append')
 .option("compression", "gzip")
 .partitionBy(partitions)
 .option('checkpointLocation', ck_path)
 .trigger(availableNow=True)
 .start(sink_path)
 .awaitTermination())
