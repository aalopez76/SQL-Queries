SELECT
    'customers' AS table_name,
    (SELECT COUNT(*) FROM customers) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('customers')) AS n_columns
UNION ALL
SELECT
    'employees' AS table_name,
    (SELECT COUNT(*) FROM employees) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('employees')) AS n_columns
UNION ALL
SELECT
    'offices' AS table_name,
    (SELECT COUNT(*) FROM offices) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('offices')) AS n_columns
UNION ALL
SELECT
    'orderdetails' AS table_name,
    (SELECT COUNT(*) FROM orderdetails) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('orderdetails')) AS n_columns
UNION ALL
SELECT
    'orders' AS table_name,
    (SELECT COUNT(*) FROM orders) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('orders')) AS n_columns
UNION ALL
SELECT
    'payments' AS table_name,
    (SELECT COUNT(*) FROM payments) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('payments')) AS n_columns
UNION ALL
SELECT
    'productlines' AS table_name,
    (SELECT COUNT(*) FROM productlines) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('productlines')) AS n_columns
UNION ALL
SELECT
    'products' AS table_name,
    (SELECT COUNT(*) FROM products) AS n_rows,
    (SELECT COUNT(*) FROM PRAGMA_TABLE_INFO('products')) AS n_columns;
