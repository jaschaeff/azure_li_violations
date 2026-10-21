-- Run against a staging table populated from the raw JSON files in ADLS Gen2.
-- The staging table should expose the Socrata fields listed below.

-- Monthly violation volume
SELECT
    DATEFROMPARTS(YEAR(TRY_CONVERT(date, violationdate)), MONTH(TRY_CONVERT(date, violationdate)), 1) AS violation_month,
    COUNT_BIG(*) AS violation_count
FROM dbo.LIViolations
WHERE TRY_CONVERT(date, violationdate) IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(TRY_CONVERT(date, violationdate)), MONTH(TRY_CONVERT(date, violationdate)), 1)
ORDER BY violation_month;

-- Most frequently cited violation codes
SELECT
    violationcode,
    MAX(violationdescription) AS violation_description,
    COUNT_BIG(*) AS violation_count
FROM dbo.LIViolations
WHERE NULLIF(LTRIM(RTRIM(violationcode)), '') IS NOT NULL
GROUP BY violationcode
ORDER BY violation_count DESC;

-- Open violations by ZIP code
SELECT
    zip,
    COUNT_BIG(*) AS open_violation_count
FROM dbo.LIViolations
WHERE UPPER(LTRIM(RTRIM(status))) = 'OPEN'
  AND NULLIF(LTRIM(RTRIM(zip)), '') IS NOT NULL
GROUP BY zip
ORDER BY open_violation_count DESC;
