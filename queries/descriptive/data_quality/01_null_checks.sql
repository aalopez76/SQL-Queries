-- 01_null_checks.sql
-- Purpose: Identify missing values in key fields across tables in one single result

SELECT 'Customer' AS table_name, customerNumber AS record_id, 'Missing Critical Info' AS issue
FROM customers
WHERE customerNumber IS NULL OR customerName IS NULL OR creditLimit IS NULL

UNION ALL

SELECT 'Order' AS table_name, orderNumber AS record_id, 'Missing Critical Info' AS issue
FROM orders
WHERE orderNumber IS NULL OR customerNumber IS NULL OR orderDate IS NULL OR status IS NULL

UNION ALL

SELECT 'Employee' AS table_name, employeeNumber AS record_id, 'Missing Critical Info' AS issue
FROM employees
WHERE employeeNumber IS NULL OR lastName IS NULL OR firstName IS NULL OR jobTitle IS NULL;