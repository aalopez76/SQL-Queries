-- 01_sales_by_country_deep_agg.sql
-- Purpose:
--   Deep-dive aggregation of sales by country:
--   - total sales, number of orders, number of customers
--   - average sales per customer
--   - average order value (ticket size)
--   - % of global sales and cumulative % (Pareto-style)
--   - ranking by total sales
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- Base aggregation by country
WITH country_sales AS (
    SELECT
        c.country,

        -- Raw totals by country
        SUM(od.quantityOrdered * od.priceEach)                 AS total_sales,
        COUNT(DISTINCT o.orderNumber)                          AS num_orders,
        COUNT(DISTINCT c.customerNumber)                       AS num_customers

    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber

    GROUP BY
        c.country
),

-- Enrich with average metrics
country_enriched AS (
    SELECT
        country,
        ROUND(total_sales, 2)                                  AS total_sales,
        num_orders,
        num_customers,

        -- Average sales per customer
        ROUND(
            CASE
                WHEN num_customers > 0
                THEN total_sales * 1.0 / num_customers
                ELSE NULL
            END
        , 2)                                                   AS avg_sales_per_customer,

        -- Average order value (ticket size)
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_sales * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                                   AS avg_order_value
    FROM country_sales
),

-- Add distribution metrics and ranking
country_ranked AS (
    SELECT
        country,
        total_sales,
        num_orders,
        num_customers,
        avg_sales_per_customer,
        avg_order_value,

        -- Share of global sales (%)
        ROUND(
            100.0 * total_sales
            / SUM(total_sales) OVER ()
        , 2)                                                   AS pct_of_global_sales,

        -- Cumulative share of global sales (%), ordered by total_sales DESC
        ROUND(
            100.0 * SUM(total_sales) OVER (
                ORDER BY total_sales DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / SUM(total_sales) OVER ()
        , 2)                                                   AS cumulative_pct_of_global_sales,

        -- Rank by total sales (1 = highest sales)
        RANK() OVER (ORDER BY total_sales DESC)                AS sales_rank
    FROM country_enriched
)

-- Final output: one row per country with deep metrics
SELECT
    country,
    total_sales,
    num_orders,
    num_customers,
    avg_sales_per_customer,
    avg_order_value,
    pct_of_global_sales,
    cumulative_pct_of_global_sales,
    sales_rank
FROM country_ranked
ORDER BY
    sales_rank;
