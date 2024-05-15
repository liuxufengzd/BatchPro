result
=
SELECT Date, Application, TenantId, Platform, OsName, FeatureName, sum (ActiveUsageCount) ActiveUsageCount
FROM copilot_td
GROUP BY Date, Application, TenantId, Platform, OsName, FeatureName