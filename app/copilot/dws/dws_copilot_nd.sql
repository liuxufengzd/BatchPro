copilot_1d
=
SELECT Application,
       FeatureActionType,
       TenantId,
       COUNT(DISTINCT UserId)   UserCount_1d,
       COUNT(DISTINCT DeviceId) DeviceCount_1d,
       SUM(ActionCount_1d)      ActionCount_1d
FROM copilot_all
WHERE Date >= date_sub("${date}", 0)
GROUP BY Application, FeatureActionType, TenantId;

copilot_7d
=
SELECT Application,
       FeatureActionType,
       TenantId,
       COUNT(DISTINCT UserId)   UserCount_7d,
       COUNT(DISTINCT DeviceId) DeviceCount_7d,
       SUM(ActionCount_1d)      ActionCount_7d
FROM copilot_all
WHERE Date >= date_sub("${date}", 6)
GROUP BY Application, FeatureActionType, TenantId;

copilot_30d
=
SELECT Application,
       FeatureActionType,
       TenantId,
       COUNT(DISTINCT UserId)   UserCount_30d,
       COUNT(DISTINCT DeviceId) DeviceCount_30d,
       SUM(ActionCount_1d)      ActionCount_30d
FROM copilot_all
WHERE Date >= date_sub("${date}", 29)
GROUP BY Application, FeatureActionType, TenantId;

result
=
SELECT a.Application,
       a.FeatureActionType,
       a.TenantId,
       UserCount_1d,
       DeviceCount_1d,
       ActionCount_1d,
       UserCount_7d,
       DeviceCount_7d,
       ActionCount_7d,
       UserCount_30d,
       DeviceCount_30d,
       ActionCount_30d,
       "${date}" Date
FROM copilot_1d a
         LEFT JOIN copilot_7d b
                   ON a.Application = b.Application
                       AND a.FeatureActionType = b.FeatureActionType
                       AND a.TenantId = b.TenantId
         LEFT JOIN copilot_30d c
                   ON a.Application = c.Application
                       AND a.FeatureActionType = c.FeatureActionType
                       AND a.TenantId = c.TenantId;
