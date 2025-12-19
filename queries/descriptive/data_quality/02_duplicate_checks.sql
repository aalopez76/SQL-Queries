-- 02_duplicate_checks.sql
-- Purpose: Detect duplicated primary keys across core business tables in a single execution.

SELECT 'Customer' AS table_name, customerNumber AS duplicate_id, COUNT(*) AS occurrences
FROM customers
GROUP BY customerNumber
HAVING occurrences > 1

UNION ALL

SELECT 'Order' AS table_name, orderNumber AS duplicate_id, COUNT(*) AS occurrences
FROM orders
GROUP BY orderNumber
HAVING occurrences > 1

UNION ALL

SELECT 'Product' AS table_name, productCode AS duplicate_id, COUNT(*) AS occurrences
FROM products
GROUP BY productCode
HAVING occurrences > 1;