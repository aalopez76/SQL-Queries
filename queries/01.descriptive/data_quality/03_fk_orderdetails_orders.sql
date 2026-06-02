-- 03_fk_orderdetails_orders.sql
-- Purpose:
--   Identify orderdetails rows whose orderNumber does not exist in orders.
--   (Missing parent order record)

SELECT
    od.orderNumber,
    od.productCode
FROM orderdetails AS od
LEFT JOIN orders AS o
    ON od.orderNumber = o.orderNumber
WHERE o.orderNumber IS NULL;
