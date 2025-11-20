-- 02_low_high_credit_outliers.sql
-- Purpose:
--   Identify customers with unusually low or unusually high credit limits.
--   These outliers are detected using percentile rankings (NTILE 100):
--     - Bottom 5% (potential risk or under-crediting)
--     - Top 5%  (potential over-crediting or exceptional clients)
--
-- Dataset: toys_and_models.sqlite

-- 1) Compute percentile ranking for customer credit limits
WITH CreditStats AS (
    SELECT
        customerNumber,
        customerName,
        country,
        creditLimit,

        NTILE(100) OVER (ORDER BY creditLimit) AS percentile
    FROM customers
    WHERE creditLimit IS NOT NULL   -- safety filter
)

-- 2) Select extreme outliers
SELECT
    customerNumber,
    customerName,
    country,
    ROUND(creditLimit, 2) AS creditLimit,
    percentile,

    CASE
        WHEN percentile <= 5  THEN 'LOW-CREDIT OUTLIER (Bottom 5%)'
        WHEN percentile >= 95 THEN 'HIGH-CREDIT OUTLIER (Top 5%)'
    END AS outlierCategory
FROM CreditStats
WHERE
    percentile <= 5     -- bottom 5%
    OR
    percentile >= 95    -- top 5%
ORDER BY
    creditLimit;
