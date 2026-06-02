SELECT 'customers'    AS table_name,
       (SELECT COUNT(*) FROM customers) AS n_rows,
       (SELECT COUNT(*) FROM pragma_table_info('customers')) AS n_columns

UNION ALL
SELECT 'employees',
       (SELECT COUNT(*) FROM employees),
       (SELECT COUNT(*) FROM pragma_table_info('employees'))

UNION ALL
SELECT 'offices',
       (SELECT COUNT(*) FROM offices),
       (SELECT COUNT(*) FROM pragma_table_info('offices'))

UNION ALL
SELECT 'orderdetails',
       (SELECT COUNT(*) FROM orderdetails),
       (SELECT COUNT(*) FROM pragma_table_info('orderdetails'))

UNION ALL
SELECT 'orders',
       (SELECT COUNT(*) FROM orders),
       (SELECT COUNT(*) FROM pragma_table_info('orders'))

UNION ALL
SELECT 'payments',
       (SELECT COUNT(*) FROM payments),
       (SELECT COUNT(*) FROM pragma_table_info('payments'))

UNION ALL
SELECT 'productlines',
       (SELECT COUNT(*) FROM productlines),
       (SELECT COUNT(*) FROM pragma_table_info('productlines'))

UNION ALL
SELECT 'products',
       (SELECT COUNT(*) FROM products),
       (SELECT COUNT(*) FROM pragma_table_info('products'));
