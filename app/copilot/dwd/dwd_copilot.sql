result
=
SELECT
    Time,
    Application,
    UserId,
    TenantId,
    Platform,
    OsName,
    OlsLicenseId,
    DeviceId,
    FeatureName,
    FeatureCategory,
    FeatureActionType,
    SessionId,
    CountryCode,
    Language,
    to_date(Time) Date
FROM copilot
WHERE isnotnull(UserId)
    AND isnotnull(TenantId)
    AND isnotnull(FeatureName)
    AND isnotnull(FeatureActionType)
    AND lower(FeatureCategory) = 'copilot';
