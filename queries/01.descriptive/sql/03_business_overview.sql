SELECT 'customers' AS table_name, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'employees', COUNT(*) FROM employees;

