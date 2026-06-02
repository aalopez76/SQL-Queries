-- 04_product_monthly_quartiles.sql
-- Quartile features: product position within each month based on sales

WITH ProductMonthlySales AS (
    SELECT
        p.productCode,
        p.productName,
        STRFTIME('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orders AS o
    INNER JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
    INNER JOIN products AS p ON od.productCode = p.productCode
    GROUP BY
        p.productCode, p.productName, salesMonth
)

SELECT
    productCode,
    productName,
    salesMonth,
    totalSales,
    NTILE(4) OVER (
        PARTITION BY salesMonth
        ORDER BY totalSales
    ) AS salesQuartile_month
FROM ProductMonthlySales
ORDER BY
    salesMonth, totalSales;
