SELECT
    'customers' AS table_name,
    COUNT(*) AS n_rows
FROM customers
UNION ALL
SELECT
    'employees' AS table_name,
    COUNT(*) AS n_rows
FROM employees
UNION ALL
SELECT
    'offices' AS table_name,
    COUNT(*) AS n_rows
FROM offices
UNION ALL
SELECT
    'orderdetails' AS table_name,
    COUNT(*) AS n_rows
FROM orderdetails
UNION ALL
SELECT
    'orders' AS table_name,
    COUNT(*) AS n_rows
FROM orders
UNION ALL
SELECT
    'payments' AS table_name,
    COUNT(*) AS n_rows
FROM payments
UNION ALL
SELECT
    'productlines' AS table_name,
    COUNT(*) AS n_rows
FROM productlines
UNION ALL
SELECT
    'products' AS table_name,
    COUNT(*) AS n_rows
FROM products;
