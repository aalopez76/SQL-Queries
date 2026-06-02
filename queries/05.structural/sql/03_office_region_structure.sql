-- 03_office_region_structure.sql
-- Purpose:
--   Describe the geographic and organizational structure of the company:
--   - Offices by territory, country, and city
--   - Number of employees per office
--   - Number of customers served (via sales reps in that office)
--
-- Dataset: toys_and_models.sqlite

WITH EmployeesPerOffice AS (
    SELECT
        e.officeCode,
        COUNT(*) AS numEmployees
    FROM employees AS e
    GROUP BY
        e.officeCode
),

CustomersPerOffice AS (
    SELECT
        e.officeCode,
        COUNT(DISTINCT c.customerNumber) AS numCustomers
    FROM employees AS e
    LEFT JOIN customers AS c
        ON e.employeeNumber = c.salesRepEmployeeNumber
    GROUP BY
        e.officeCode
)

SELECT
    o.officeCode,
    o.territory,
    o.country,
    o.city,
    o.phone,
    COALESCE(epo.numEmployees, 0) AS numEmployees,
    COALESCE(cpo.numCustomers, 0) AS numCustomers
FROM offices AS o
LEFT JOIN EmployeesPerOffice AS epo
    ON o.officeCode = epo.officeCode
LEFT JOIN CustomersPerOffice AS cpo
    ON o.officeCode = cpo.officeCode
ORDER BY
    o.territory,
    o.country,
    o.city;
