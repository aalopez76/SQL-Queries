-- 01_null_checks.sql
-- Purpose:
--   Identify missing (NULL) values in key business-critical fields.

-- Nulls in customer fields
SELECT *
FROM customers
WHERE customerNumber IS NULL
   OR customerName IS NULL
   OR creditLimit IS NULL;

-- Nulls in order fields
SELECT *
FROM orders
WHERE orderNumber IS NULL
   OR customerNumber IS NULL
   OR orderDate IS NULL
   OR status IS NULL;

-- Nulls in employee fields
SELECT *
FROM employees
WHERE employeeNumber IS NULL
   OR lastName IS NULL
   OR firstName IS NULL
   OR jobTitle IS NULL;
