-- 02_duplicate_checks.sql
-- Purpose:
--   Detect duplicated primary keys across core business tables.

-- Duplicates in customers (customerNumber should be unique)
SELECT customerNumber, COUNT(*) AS cnt
FROM customers
GROUP BY customerNumber
HAVING cnt > 1;

-- Duplicates in orders (orderNumber should be unique)
SELECT orderNumber, COUNT(*) AS cnt
FROM orders
GROUP BY orderNumber
HAVING cnt > 1;

-- Duplicates in products (productCode should be unique)
SELECT productCode, COUNT(*) AS cnt
FROM products
GROUP BY productCode
HAVING cnt > 1;
