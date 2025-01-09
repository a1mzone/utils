SELECT
    source,
    count(*) days,
    SUM(dwh_total-druid_total) missing
FROM druid_compare dc
WHERE dwh_total > druid_total
AND date_checked >= '2025-01-01'
GROUP BY source
ORDER BY missing DESC;


SELECT
    *
FROM druid_compare
WHERE dwh_total > druid_total
AND date_checked >= '2025-01-01'