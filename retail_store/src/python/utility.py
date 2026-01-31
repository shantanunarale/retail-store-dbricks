def getMaxBatchId(spark, tableName: str):
  return spark.sql(f"SELECT NVL(MAX(BatchId), 0) AS BatchId FROM {tableName}")