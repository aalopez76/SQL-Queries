-- 01_company_monthly_timeseries.sql
-- Monthly company-level KPIs time series (for forecasting or anomaly detection)

WITH MonthlyBase AS (
    SELECT
        strftime('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales,
        COUNT(DISTINCT o.orderNumber) AS totalOrders,
        COUNT(DISTINCT o.customerNumber) AS totalCustomers,
        SUM(
            CASE
                WHEN o.shippedDate IS NOT NULL
                     AND o.requiredDate IS NOT NULL
                     AND o.shippedDate <= o.requiredDate
                THEN 1 ELSE 0
            END
        ) AS onTimeOrders
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY salesMonth
)
SELECT
    salesMonth,
    totalSales,
    totalOrders,
    totalCustomers,
    ROUND(totalSales * 1.0 / totalOrders, 2) AS avgOrderValue,
    ROUND(onTimeOrders * 1.0 / totalOrders * 100, 2) AS onTimeRate_pct
FROM MonthlyBase
ORDER BY
    salesMonth;
