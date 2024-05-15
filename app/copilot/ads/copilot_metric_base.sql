result
=
SELECT
    Date, Application, TenantId, FeatureActionType, AggregationType, MetricName, CASE
    WHEN AggregationType='1' AND MetricName='UserCount' THEN UserCount_1d
    WHEN AggregationType='7' AND MetricName='UserCount' THEN UserCount_7d
    WHEN AggregationType='30' AND MetricName='UserCount' THEN UserCount_30d
    WHEN AggregationType='1' AND MetricName='ActionCount' THEN ActionCount_1d
    WHEN AggregationType='7' AND MetricName='ActionCount' THEN ActionCount_7d
    WHEN AggregationType='30' AND MetricName='ActionCount' THEN ActionCount_30d
    WHEN AggregationType='1' AND MetricName='DeviceCount' THEN DeviceCount_1d
    WHEN AggregationType='7' AND MetricName='DeviceCount' THEN DeviceCount_7d
    WHEN AggregationType='30' AND MetricName='DeviceCount' THEN DeviceCount_30d
END
AS MetricValue
FROM (SELECT * FROM copilot_nd WHERE FeatureActionType IN ('IsTried', 'IsKept'))
    LATERAL VIEW explode(array(1, 7, 30)) tmp as AggregationType
    LATERAL VIEW explode(array("UserCount", "ActionCount", "DeviceCount")) tmp as MetricName
