-- 03_product_lag_features.sql
-- Lag/lead features for monthly product sales

WITH ProductMonthlySales AS (
    SELECT
        p.productCode,
        p.productName,
        strftime('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON p.productCode = od.productCode
    GROUP BY
        p.productCode,
        p.productName,
        salesMonth
)
SELECT
    productCode,
    productName,
    salesMonth,
    totalSales,
    LAG(totalSales, 1) OVER (
        PARTITION BY productCode
        ORDER BY salesMonth
    ) AS sales_lag_1,
    LAG(totalSales, 2) OVER (
        PARTITION BY productCode
        ORDER BY salesMonth
    ) AS sales_lag_2,
    LEAD(totalSales, 1) OVER (
        PARTITION BY productCode
        ORDER BY salesMonth
    ) AS sales_lead_1
FROM ProductMonthlySales
ORDER BY
    productCode,
    salesMonth;
