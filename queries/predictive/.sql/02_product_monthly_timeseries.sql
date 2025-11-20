-- 02_product_monthly_timeseries.sql
-- Monthly time series per product (base dataset for forecasting)

WITH ProductMonthlySales AS (
    SELECT
        p.productCode,
        p.productName,
        strftime('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered) AS totalQuantity,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON p.productCode = od.productCode
    GROUP BY
        p.productCode,
        p.productName,
        salesMonth
)
SELECT *
FROM ProductMonthlySales
ORDER BY
    productCode,
    salesMonth;
