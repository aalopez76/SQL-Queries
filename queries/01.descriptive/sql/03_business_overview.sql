SELECT
    'customers' AS table_name,
    COUNT(*) AS total
FROM customers
UNION ALL
SELECT
    'products' AS table_name,
    COUNT(*) AS total
FROM products
UNION ALL
SELECT
    'employees' AS table_name,
    COUNT(*) AS total
FROM employees;
