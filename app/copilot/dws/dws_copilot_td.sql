copilot_enabled
=
SELECT Date, Application, UserId, TenantId, Platform, OsName, FeatureName, CountryCode, 0 ActiveUsageCount, 0 ActiveUsageDays
FROM copilot_1d
WHERE FeatureActionType = 'IsEnabled';

copilot_seen
=
SELECT Application,
       UserId,
       TenantId,
       Platform,
       OsName,
       FeatureName,
       CountryCode, Date FirstSeen, Date LastSeen
FROM copilot_1d
WHERE FeatureActionType = 'IsSeen';

copilot_tried
=
SELECT Application,
       UserId,
       TenantId,
       Platform,
       OsName,
       FeatureName,
       CountryCode, Date FirstTried, Date LastTried, ActionCount_1d ActiveUsageCount, 1 ActiveUsageDays
FROM copilot_1d
WHERE FeatureActionType = 'IsTried';

copilot_kept
=
SELECT Application,
       UserId,
       TenantId,
       Platform,
       OsName,
       FeatureName,
       CountryCode, Date FirstKept, Date LastKept
FROM copilot_1d
WHERE FeatureActionType = 'IsKept';

copilot_current
=
SELECT e.Date,
       e.Application,
       e.UserId,
       e.TenantId,
       e.Platform,
       e.OsName,
       e.FeatureName,
       e.CountryCode,
       s.FirstSeen,
       s.LastSeen,
       t.FirstTried,
       t.LastTried,
       k.FirstKept,
       k.LastKept,
       if(isnotnull(t.ActiveUsageCount), t.ActiveUsageCount, e.ActiveUsageCount) ActiveUsageCount,
       if(isnotnull(t.ActiveUsageDays), t.ActiveUsageDays, e.ActiveUsageDays)    ActiveUsageDays
FROM copilot_enabled e
         LEFT JOIN copilot_seen s ON
    e.Application = s.Application
        AND e.OsName = s.OsName
        AND e.FeatureName = s.FeatureName
        AND e.CountryCode = s.CountryCode
        AND e.Platform = s.Platform
        AND e.TenantId = s.TenantId
        AND e.UserId = s.UserId
         LEFT JOIN copilot_tried t ON
    e.Application = t.Application
        AND e.OsName = t.OsName
        AND e.FeatureName = t.FeatureName
        AND e.CountryCode = t.CountryCode
        AND e.Platform = t.Platform
        AND e.TenantId = t.TenantId
        AND e.UserId = t.UserId
         LEFT JOIN copilot_kept k ON
    e.Application = k.Application
        AND e.OsName = k.OsName
        AND e.FeatureName = k.FeatureName
        AND e.CountryCode = k.CountryCode
        AND e.Platform = k.Platform
        AND e.TenantId = k.TenantId
        AND e.UserId = k.UserId;

copilot
=
SELECT Date, Application, UserId, TenantId, Platform, OsName, FeatureName, CountryCode, min (FirstSeen) FirstSeen, max (LastSeen) LastSeen, min (FirstTried) FirstTried, max (LastTried) LastTried, min (FirstKept) FirstKept, max (LastKept) LastKept, sum (ActiveUsageCount) ActiveUsageCount, cast(sum (ActiveUsageDays) as int) ActiveUsageDays
FROM (SELECT to_date("${date}", 'yyyy-MM-dd') Date, Application, UserId, TenantId, Platform, OsName, FeatureName, CountryCode, FirstSeen, LastSeen, FirstTried, LastTried, FirstKept, LastKept, ActiveUsageCount, ActiveUsageDays
    FROM copilot_td
    UNION ALL
    SELECT Date, Application, UserId, TenantId, Platform, OsName, FeatureName, CountryCode, FirstSeen, LastSeen, FirstTried, LastTried, FirstKept, LastKept, ActiveUsageCount, ActiveUsageDays
    FROM copilot_current)
GROUP BY Date,
    Application,
    UserId,
    TenantId,
    Platform,
    OsName,
    FeatureName,
    CountryCode;