-- 08_salesrep_rank_by_revenue.sql
-- Purpose:
--   Rank sales representatives based on total revenue generated and enrich with:
--   - number of customers per sales rep
--   - number of countries served
--   - number of orders
--   - average order value (ticket size)
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- 1) Aggregate metrics per employee
WITH EmployeeSales AS (
    SELECT
        e.employeeNumber,
        e.firstName || ' ' || e.lastName AS employeeName,

        -- Core value and volume metrics
        COALESCE(SUM(od.quantityOrdered * od.priceEach), 0)    AS totalSales,
        COUNT(DISTINCT c.customerNumber)                       AS numCustomers,
        COUNT(DISTINCT c.country)                              AS numCountries,
        COUNT(DISTINCT o.orderNumber)                          AS numOrders

    FROM employees e
    LEFT JOIN customers c
        ON e.employeeNumber = c.salesRepEmployeeNumber
    LEFT JOIN orders o
        ON c.customerNumber = o.customerNumber
    LEFT JOIN orderdetails od
        ON o.orderNumber = od.orderNumber

    GROUP BY
        e.employeeNumber,
        employeeName
)

-- 2) Final ranking with ticket promedio
SELECT
    employeeNumber,
    employeeName,
    ROUND(totalSales, 2)              AS totalSales,
    numCustomers,
    numCountries,
    numOrders,

    -- Ticket promedio (average order value)
    ROUND(
        CASE
            WHEN numOrders > 0
            THEN totalSales * 1.0 / numOrders
            ELSE NULL
        END
    , 2)                              AS avgOrderValue,

    RANK() OVER (ORDER BY totalSales DESC) AS salesRank
FROM EmployeeSales
ORDER BY
    salesRank,
    employeeName;
