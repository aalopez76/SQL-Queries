-- 04_fk_orderdetails_products.sql
-- Purpose:
--   Identify orderdetails rows whose productCode does not exist in products.
--   (Missing parent product record)

SELECT
    od.orderNumber,
    od.productCode
FROM orderdetails AS od
LEFT JOIN products AS p
    ON od.productCode = p.productCode
WHERE p.productCode IS NULL;
