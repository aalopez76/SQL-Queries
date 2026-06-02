-- 01_geographic_credit_anomalies.sql
-- Purpose:
--   Detect countries where the relationship between customer credit limits
--   and realized sales is atypical (potential credit policy anomalies).
--   Examples:
--     - High credit vs low sales (over-crediting)
--     - Low credit vs high sales (under-crediting / growth opportunity)
--
-- Approach:
--   1) Aggregate total sales per customer.
--   2) Aggregate per country: avg credit, avg sales, credit/sales ratio.
--   3) Rank countries by credit_to_sales_ratio using NTILE(100).
--   4) Flag extreme countries in the tails (top 10% and bottom 10%).
--
-- Dataset: toys_and_models.sqlite

-- 1) Aggregate sales at customer level
WITH CustomerSales AS (
    SELECT
        c.customerNumber,
        c.customerName,
        c.country,
        c.creditLimit,
        COALESCE(SUM(od.quantityOrdered * od.priceEach), 0) AS totalSales
    FROM customers c
    LEFT JOIN orders o
        ON c.customerNumber = o.customerNumber
    LEFT JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber,
        c.customerName,
        c.country,
        c.creditLimit
),

-- 2) Aggregate at country level
CountryProfile AS (
    SELECT
        country,
        COUNT(*)                                 AS num_customers,
        SUM(creditLimit)                         AS total_credit_limit,
        SUM(totalSales)                          AS total_sales,
        AVG(creditLimit)                         AS avg_credit_limit,
        AVG(totalSales)                          AS avg_sales_per_customer,
        CASE
            WHEN SUM(totalSales) > 0
            THEN (SUM(creditLimit) * 1.0 / SUM(totalSales))
            ELSE NULL
        END                                      AS credit_to_sales_ratio
    FROM CustomerSales
    WHERE creditLimit IS NOT NULL
    GROUP BY
        country
),

-- 3) Compute percentiles for the credit_to_sales_ratio
CountryPercentiles AS (
    SELECT
        country,
        num_customers,
        total_credit_limit,
        total_sales,
        ROUND(avg_credit_limit, 2)          AS avg_credit_limit,
        ROUND(avg_sales_per_customer, 2)    AS avg_sales_per_customer,
        ROUND(credit_to_sales_ratio, 4)     AS credit_to_sales_ratio,
        NTILE(100) OVER (
            ORDER BY credit_to_sales_ratio
        )                                   AS ratio_pct
    FROM CountryProfile
    WHERE credit_to_sales_ratio IS NOT NULL
)

-- 4) Select anomalous countries (extreme tails)
SELECT
    country,
    num_customers,
    total_credit_limit,
    total_sales,
    avg_credit_limit,
    avg_sales_per_customer,
    credit_to_sales_ratio,
    ratio_pct,
    CASE
        WHEN ratio_pct >= 90 THEN 'HIGH CREDIT VS SALES (Top 10%)'
        WHEN ratio_pct <= 10 THEN 'LOW CREDIT VS SALES (Bottom 10%)'
    END AS anomalyCategory
FROM CountryPercentiles
WHERE
    ratio_pct >= 90   -- high credit relative to sales
    OR
    ratio_pct <= 10   -- low credit relative to sales
ORDER BY
    credit_to_sales_ratio DESC;
