-- 02_products_deep_agg.sql
-- Purpose:
--   Deep-dive aggregation of product-level performance:
--   - total sales and total units per product
--   - number of orders and number of customers per product
--   - average sales per order and per customer
--   - average units per order
--   - % of global sales and cumulative %
--   - ranking and ABC classification (Pareto-style)
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- 1) Base aggregation at product level
WITH ProductAgg AS (
    SELECT
        p.productCode,
        p.productName,

        -- Core volume and value metrics
        SUM(od.quantityOrdered * od.priceEach)          AS total_sales,
        SUM(od.quantityOrdered)                         AS total_units,
        COUNT(DISTINCT o.orderNumber)                   AS num_orders,
        COUNT(DISTINCT c.customerNumber)                AS num_customers

    FROM products p
    JOIN orderdetails od
        ON p.productCode = od.productCode
    JOIN orders o
        ON od.orderNumber = o.orderNumber
    JOIN customers c
        ON o.customerNumber = c.customerNumber

    GROUP BY
        p.productCode,
        p.productName
),

-- 2) Enrich with averages (per order / per customer)
ProductEnriched AS (
    SELECT
        productCode,
        productName,
        ROUND(total_sales, 2)                           AS total_sales,
        total_units,
        num_orders,
        num_customers,

        -- Average sales per order for this product
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_sales * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                            AS avg_sales_per_order,

        -- Average units per order for this product
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_units * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                            AS avg_units_per_order,

        -- Average sales per customer for this product
        ROUND(
            CASE
                WHEN num_customers > 0
                THEN total_sales * 1.0 / num_customers
                ELSE NULL
            END
        , 2)                                            AS avg_sales_per_customer
    FROM ProductAgg
),

-- 3) Add distribution metrics (global share, cumulative, rank, ABC class)
ProductRanked AS (
    SELECT
        productCode,
        productName,
        total_sales,
        total_units,
        num_orders,
        num_customers,
        avg_sales_per_order,
        avg_units_per_order,
        avg_sales_per_customer,

        -- Share of global sales (%)
        ROUND(
            100.0 * total_sales
            / SUM(total_sales) OVER ()
        , 2)                                            AS pct_of_global_sales,

        -- Cumulative share of global sales (%), ordered by total_sales DESC
        ROUND(
            100.0 * SUM(total_sales) OVER (
                ORDER BY total_sales DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / SUM(total_sales) OVER ()
        , 2)                                            AS cumulative_pct_of_global_sales,

        -- Rank by total sales (1 = highest selling product)
        RANK() OVER (ORDER BY total_sales DESC)         AS sales_rank
    FROM ProductEnriched
)

-- 4) Final output with ABC classification based on cumulative % of sales
SELECT
    productCode,
    productName,
    total_sales,
    total_units,
    num_orders,
    num_customers,
    avg_sales_per_order,
    avg_units_per_order,
    avg_sales_per_customer,
    pct_of_global_sales,
    cumulative_pct_of_global_sales,
    sales_rank,

    CASE
        WHEN cumulative_pct_of_global_sales <= 80 THEN 'A'   -- top contributors
        WHEN cumulative_pct_of_global_sales <= 95 THEN 'B'   -- mid-tier
        ELSE 'C'                                             -- tail products
    END AS abc_class
FROM ProductRanked
ORDER BY
    sales_rank;
