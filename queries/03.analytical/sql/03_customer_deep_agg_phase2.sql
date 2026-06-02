-- 03_customer_deep_agg.sql
-- Purpose:
--   Deep-dive aggregation of customer-level performance:
--   - total sales and total units per customer
--   - number of orders and number of distinct products per customer
--   - average sales per order, per product, and per customer
--   - average units per order
--   - % of global sales and cumulative %
--   - ranking and ABC classification (Pareto-style)
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- 1) Base aggregation at customer level
WITH CustomerAgg AS (
    SELECT
        c.customerNumber,
        c.customerName,
        c.country,

        -- Core volume and value metrics
        SUM(od.quantityOrdered * od.priceEach)          AS total_sales,
        SUM(od.quantityOrdered)                         AS total_units,
        COUNT(DISTINCT o.orderNumber)                   AS num_orders,
        COUNT(DISTINCT od.productCode)                  AS num_products

    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber

    GROUP BY
        c.customerNumber,
        c.customerName,
        c.country
),

-- 2) Enrich with averages (per order / per product)
CustomerEnriched AS (
    SELECT
        customerNumber,
        customerName,
        country,
        ROUND(total_sales, 2)                           AS total_sales,
        total_units,
        num_orders,
        num_products,

        -- Average sales per order
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_sales * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                            AS avg_sales_per_order,

        -- Average units per order
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_units * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                            AS avg_units_per_order,

        -- Average sales per product (distinct products bought)
        ROUND(
            CASE
                WHEN num_products > 0
                THEN total_sales * 1.0 / num_products
                ELSE NULL
            END
        , 2)                                            AS avg_sales_per_product
    FROM CustomerAgg
),

-- 3) Add distribution metrics (global share, cumulative, rank)
CustomerRanked AS (
    SELECT
        customerNumber,
        customerName,
        country,
        total_sales,
        total_units,
        num_orders,
        num_products,
        avg_sales_per_order,
        avg_units_per_order,
        avg_sales_per_product,

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

        -- Rank by total sales (1 = highest revenue customer)
        RANK() OVER (ORDER BY total_sales DESC)         AS sales_rank
    FROM CustomerEnriched
)

-- 4) Final output with ABC classification based on cumulative % of sales
SELECT
    customerNumber,
    customerName,
    country,
    total_sales,
    total_units,
    num_orders,
    num_products,
    avg_sales_per_order,
    avg_units_per_order,
    avg_sales_per_product,
    pct_of_global_sales,
    cumulative_pct_of_global_sales,
    sales_rank,

    CASE
        WHEN cumulative_pct_of_global_sales <= 80 THEN 'A'   -- key customers
        WHEN cumulative_pct_of_global_sales <= 95 THEN 'B'   -- important, but not core
        ELSE 'C'                                             -- tail customers
    END AS abc_class
FROM CustomerRanked
ORDER BY
    sales_rank;
