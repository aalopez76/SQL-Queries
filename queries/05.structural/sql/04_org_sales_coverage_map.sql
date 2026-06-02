-- 04_org_sales_coverage_map.sql
-- Purpose:
--   Provide a structural view of the commercial organization:
--   - Office (territory / country / city)
--   - Sales representative (employee)
--   - Customers assigned to each rep
--
--   This is not a performance query, but an organizational coverage map.
--
-- Dataset: toys_and_models.sqlite

SELECT
    o.territory,
    o.country       AS officeCountry,
    o.city          AS officeCity,
    o.officeCode,
    e.employeeNumber,
    e.firstName || ' ' || e.lastName AS employeeName,
    e.jobTitle,

    c.customerNumber,
    c.customerName,
    c.country       AS customerCountry,
    c.city          AS customerCity
FROM offices o
JOIN employees e
    ON o.officeCode = e.officeCode
LEFT JOIN customers c
    ON e.employeeNumber = c.salesRepEmployeeNumber
ORDER BY
    o.territory,
    officeCountry,
    officeCity,
    employeeName,
    customerName;
