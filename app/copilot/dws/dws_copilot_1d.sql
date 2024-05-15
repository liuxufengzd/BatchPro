result
=
SELECT to_date(Time) Date,
    Application,
    UserId,
    TenantId,
    Platform,
    OsName,
    DeviceId,
    FeatureName,
    FeatureActionType,
    CountryCode,
    COUNT(FeatureName) ActionCount_1d
FROM copilot
GROUP BY Date, Application, UserId, TenantId, Platform, OSName, DeviceId, FeatureName, FeatureActionType, CountryCode;
