-- 03_credit_vs_sales_misalignment_ratio.sql
-- Purpose:
--   Identify customers whose credit limit is strongly misaligned
--   with their realized sales using simple ratios instead of percentiles.
--
--   Two main patterns:
--     - HIGH CREDIT / LOW SALES:
--         creditLimit is much larger than totalSales
--     - LOW CREDIT / HIGH SALES:
--         totalSales are much larger than creditLimit
--
--   Default thresholds in this script:
--     - creditLimit >= 2 * totalSales
--     - OR totalSales >= 2 * creditLimit
--
--   These thresholds can be adjusted depending on business context.
--
-- Dataset: toys_and_models.sqlite

-- 1) Aggregate total sales per customer
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

-- 2) Compute ratios credit/sales and sales/credit
CustomerRatios AS (
    SELECT
        customerNumber,
        customerName,
        country,
        creditLimit,
        totalSales,

        -- Credit-to-sales ratio: how many times credit exceeds realized sales
        CASE
            WHEN totalSales > 0
            THEN creditLimit * 1.0 / totalSales
            ELSE NULL
        END AS credit_to_sales_ratio,

        -- Sales-to-credit ratio: how many times sales exceed credit
        CASE
            WHEN creditLimit > 0
            THEN totalSales * 1.0 / creditLimit
            ELSE NULL
        END AS sales_to_credit_ratio
    FROM CustomerSales
    WHERE creditLimit IS NOT NULL
)

-- 3) Select misaligned customers based on ratio thresholds
SELECT
    customerNumber,
    customerName,
    country,
    ROUND(creditLimit, 2)          AS creditLimit,
    ROUND(totalSales, 2)           AS totalSales,
    ROUND(credit_to_sales_ratio, 2) AS credit_to_sales_ratio,
    ROUND(sales_to_credit_ratio, 2) AS sales_to_credit_ratio,
    CASE
        WHEN credit_to_sales_ratio >= 2
             AND totalSales > 0
            THEN 'HIGH CREDIT / LOW SALES (credit >= 2x sales)'
        WHEN sales_to_credit_ratio >= 2
             AND creditLimit > 0
            THEN 'LOW CREDIT / HIGH SALES (sales >= 2x credit)'
    END AS misalignmentCategory
FROM CustomerRatios
WHERE
    (credit_to_sales_ratio >= 2 AND totalSales > 0)
    OR
    (sales_to_credit_ratio >= 2 AND creditLimit > 0)
ORDER BY
    misalignmentCategory,
    country,
    customerName;
