-- 06_fk_customers_salesrep.sql
-- Purpose:
--   Identify customers assigned to a sales representative (salesRepEmployeeNumber)
--   that does not exist in employees.

SELECT
    c.customerNumber,
    c.customerName,
    c.salesRepEmployeeNumber
FROM customers c
LEFT JOIN employees e
    ON c.salesRepEmployeeNumber = e.employeeNumber
WHERE c.salesRepEmployeeNumber IS NOT NULL
  AND e.employeeNumber IS NULL;
