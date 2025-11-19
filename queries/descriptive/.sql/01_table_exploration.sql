SELECT 'customers'    AS table_name, COUNT(*) AS n_rows FROM customers
UNION ALL
SELECT 'employees',   COUNT(*) FROM employees
UNION ALL
SELECT 'offices',     COUNT(*) FROM offices
UNION ALL
SELECT 'orderdetails',COUNT(*) FROM orderdetails
UNION ALL
SELECT 'orders',      COUNT(*) FROM orders
UNION ALL
SELECT 'payments',    COUNT(*) FROM payments
UNION ALL
SELECT 'productlines',COUNT(*) FROM productlines
UNION ALL
SELECT 'products',    COUNT(*) FROM products;
