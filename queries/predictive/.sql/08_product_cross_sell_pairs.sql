-- 08_product_cross_sell_pairs.sql
-- Purpose:
--   Identify product pairs that tend to be bought together (cross-sell candidates).
--
-- Approach:
--   1) Derive the set of products per order (orderNumber, productCode).
--   2) Self-join on orderNumber to get product pairs (productCode1 < productCode2).
--   3) Count co-occurrences (# of orders where both appear).
--   4) Compute:
--        - support = cooccurrence_count / total_orders
--        - confidence_from_p1 = cooccurrence_count / orders_with_product1
--        - confidence_from_p2 = cooccurrence_count / orders_with_product2
--   5) Optionally filter by minimum co-occurrence count.
--
-- Dataset: toys_and_models.sqlite

-- 1) Unique product per order
WITH OrderProducts AS (
    SELECT DISTINCT
        od.orderNumber,
        od.productCode
    FROM orderdetails od
),

-- 2) Total number of distinct orders
TotalOrders AS (
    SELECT COUNT(DISTINCT orderNumber) AS total_orders
    FROM OrderProducts
),

-- 3) Number of orders per product
ProductOrderCounts AS (
    SELECT
        productCode,
        COUNT(DISTINCT orderNumber) AS product_orders
    FROM OrderProducts
    GROUP BY
        productCode
),

-- 4) Product pairs per order (co-occurrence)
ProductPairs AS (
    SELECT
        op1.productCode AS productCode1,
        op2.productCode AS productCode2,
        COUNT(*)        AS cooccurrence_count
    FROM OrderProducts op1
    JOIN OrderProducts op2
        ON op1.orderNumber = op2.orderNumber
       AND op1.productCode < op2.productCode  -- avoid duplicates and self-pairs
    GROUP BY
        op1.productCode,
        op2.productCode
),

-- 5) Join with product-level counts and total orders
PairsWithStats AS (
    SELECT
        pp.productCode1,
        pp.productCode2,
        pp.cooccurrence_count,
        p1.product_orders AS product1_orders,
        p2.product_orders AS product2_orders,
        t.total_orders
    FROM ProductPairs pp
    JOIN ProductOrderCounts p1
        ON pp.productCode1 = p1.productCode
    JOIN ProductOrderCounts p2
        ON pp.productCode2 = p2.productCode
    CROSS JOIN TotalOrders t
),

-- 6) Attach product names
PairsWithNames AS (
    SELECT
        pw.productCode1,
        p1.productName AS productName1,
        pw.productCode2,
        p2.productName AS productName2,
        pw.cooccurrence_count,
        pw.product1_orders,
        pw.product2_orders,
        pw.total_orders
    FROM PairsWithStats pw
    JOIN products p1
        ON pw.productCode1 = p1.productCode
    JOIN products p2
        ON pw.productCode2 = p2.productCode
)

-- 7) Final metrics and optional filtering
SELECT
    productCode1,
    productName1,
    productCode2,
    productName2,
    cooccurrence_count,
    product1_orders,
    product2_orders,
    total_orders,

    ROUND(1.0 * cooccurrence_count / total_orders, 4) AS support,

    -- P(product2 | product1)
    ROUND(1.0 * cooccurrence_count / product1_orders, 4) AS confidence_from_p1,

    -- P(product1 | product2)
    ROUND(1.0 * cooccurrence_count / product2_orders, 4) AS confidence_from_p2
FROM PairsWithNames
WHERE
    cooccurrence_count >= 3  -- minimum co-occurrences threshold (adjust as needed)
ORDER BY
    support DESC,
    cooccurrence_count DESC;
