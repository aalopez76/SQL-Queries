-- 05_product_demand_trend_flag.sql
-- Purpose:
--   Flag products as GROWING, STABLE, or DECLINING based on recent sales trends.
--   Approach:
--     - Aggregate monthly sales per product.
--     - Compute "months_ago" relative to the latest month in the dataset.
--     - Compare average sales in:
--         * recent window: last 3 months (months_ago BETWEEN 0 AND 2)
--         * previous window: previous 3 months (months_ago BETWEEN 3 AND 5)
--     - Compute growth rate and assign a simple trend flag:
--         * growth_rate >= +15% → 'GROWING'
--         * growth_rate <= -15% → 'DECLINING'
--         * otherwise          → 'STABLE'
--
-- Dataset: toys_and_models.sqlite

-- 1) Monthly sales per product
WITH MonthlyProductSales AS (
    SELECT
        p.productCode,
        p.productName,
        strftime('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM products p
    JOIN orderdetails od
        ON p.productCode = od.productCode
    JOIN orders o
        ON od.orderNumber = o.orderNumber
    GROUP BY
        p.productCode,
        p.productName,
        salesMonth
),

-- 2) Convert YYYY-MM to a numeric month key for easier "months_ago" calculation
MonthlyWithKey AS (
    SELECT
        productCode,
        productName,
        salesMonth,
        totalSales,
        (CAST(substr(salesMonth, 1, 4) AS INTEGER) * 12
         + CAST(substr(salesMonth, 6, 2) AS INTEGER)) AS month_key
    FROM MonthlyProductSales
),

-- 3) Get the maximum month_key across the dataset
GlobalMaxMonth AS (
    SELECT
        MAX(month_key) AS max_month_key
    FROM MonthlyWithKey
),

-- 4) Compute "months_ago" per product-month
MonthlyWithLag AS (
    SELECT
        m.productCode,
        m.productName,
        m.salesMonth,
        m.totalSales,
        m.month_key,
        (g.max_month_key - m.month_key) AS months_ago
    FROM MonthlyWithKey m
    CROSS JOIN GlobalMaxMonth g
),

-- 5) Aggregate recent vs previous windows per product
ProductTrendAgg AS (
    SELECT
        productCode,
        productName,

        -- Recent window: last 3 months
        AVG(CASE WHEN months_ago BETWEEN 0 AND 2 THEN totalSales END) AS recent_avg,

        -- Previous window: months 3 to 5
        AVG(CASE WHEN months_ago BETWEEN 3 AND 5 THEN totalSales END) AS prev_avg
    FROM MonthlyWithLag
    GROUP BY
        productCode,
        productName
),

-- 6) Compute growth rate
ProductTrendMetrics AS (
    SELECT
        productCode,
        productName,
        recent_avg,
        prev_avg,
        CASE
            WHEN prev_avg IS NOT NULL AND prev_avg > 0
                THEN (recent_avg - prev_avg) / prev_avg
            ELSE NULL
        END AS growth_rate
    FROM ProductTrendAgg
)

-- 7) Final trend classification
SELECT
    productCode,
    productName,
    ROUND(recent_avg, 2) AS recent_avg_sales,
    ROUND(prev_avg, 2)   AS prev_avg_sales,
    ROUND(growth_rate * 100.0, 2) AS growth_rate_pct,
    CASE
        WHEN growth_rate IS NULL THEN 'INSUFFICIENT_DATA'
        WHEN growth_rate >= 0.15 THEN 'GROWING'
        WHEN growth_rate <= -0.15 THEN 'DECLINING'
        ELSE 'STABLE'
    END AS demand_trend_flag
FROM ProductTrendMetrics
ORDER BY
    demand_trend_flag,
    growth_rate_pct DESC;
