-- 02_product_monthly_timeseries.sql
-- Monthly time series per product (base dataset for forecasting)

WITH ProductMonthlySales AS (
    SELECT
        p.productCode,
        p.productName,
        STRFTIME('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered) AS totalQuantity,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orders AS o
    INNER JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
    INNER JOIN products AS p ON od.productCode = p.productCode
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
