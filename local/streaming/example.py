from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, col, window, session_window
from pyspark.sql.types import StructType, TimestampType, StringType

spark = (SparkSession.builder
         .master("yarn")
         .appName("WordCount")
         .getOrCreate())

# df = (spark.readStream.format("socket")
#       .option("host", "localhost")
#       .option("port", 9999)
#       .load())

# df = df.select(
#     explode(split(col("value"), ' ')).alias("Word")
# ).groupBy("Word").count()
#
# df.writeStream.outputMode("update").format("console").start().awaitTermination()

# specify the schema, rather than rely on Spark to infer it automatically.
# This restriction ensures a consistent schema will be used for the streaming query, even in the case of failures.
schema = StructType().add("Word", StringType()).add("Time", TimestampType())
df = (spark.readStream
      .format("csv")
      .option("header", "true")
      .option("sep", ",")
      .schema(schema)
      .csv("/user/streaming"))

df = df.withWatermark("Time", "10 minutes").groupBy(
    window("Time", "10 minutes", "5 minutes"),
    col("Word")
).count()

df.writeStream.outputMode("update").format("console").start().awaitTermination()
