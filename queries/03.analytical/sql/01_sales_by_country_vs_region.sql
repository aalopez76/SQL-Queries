-- 01_sales_by_country_vs_region.sql
-- Purpose:
--   Compare country-level sales aggregated by region:
--   - total sales, number of orders, number of customers per country
--   - region-level aggregations
--   - % of region sales, % of global sales
--   - ranking of each country within its region
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- 1) Base lines: country, region, order, customer, line-level sales
WITH country_region_base AS (
    SELECT
        c.country,

        -- Region mapping (adjust as needed based on actual countries in the dataset)
        CASE
            WHEN c.country IN ('USA', 'Canada') THEN 'North America'
            WHEN c.country IN (
                'France', 'UK', 'England', 'Germany', 'Spain',
                'Norway', 'Denmark', 'Sweden', 'Finland',
                'Italy', 'Belgium', 'Ireland', 'Switzerland', 'Austria'
            ) THEN 'Europe'
            WHEN c.country IN (
                'Australia', 'Japan', 'Singapore', 'Hong Kong',
                'Philippines', 'New Zealand'
            ) THEN 'Asia-Pacific'
            WHEN c.country IN (
                'Brazil', 'Argentina', 'Chile', 'Mexico', 'Venezuela'
            ) THEN 'Latin America'
            ELSE 'Other'
        END AS region,

        o.orderNumber,
        c.customerNumber,
        (od.quantityOrdered * od.priceEach) AS line_sales

    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
),

-- 2) Aggregate at country level (within region)
country_agg AS (
    SELECT
        region,
        country,
        SUM(line_sales)                AS total_sales,
        COUNT(DISTINCT orderNumber)    AS num_orders,
        COUNT(DISTINCT customerNumber) AS num_customers
    FROM country_region_base
    GROUP BY
        region,
        country
),

-- 3) Aggregate at region level
region_agg AS (
    SELECT
        region,
        SUM(total_sales)             AS region_total_sales,
        SUM(num_orders)              AS region_num_orders,
        SUM(num_customers)           AS region_num_customers
    FROM country_agg
    GROUP BY
        region
),

-- 4) Enrich country metrics with regional and global context
country_vs_region AS (
    SELECT
        ca.region,
        ca.country,
        ROUND(ca.total_sales, 2)       AS total_sales,
        ca.num_orders,
        ca.num_customers,

        -- Region totals
        ra.region_total_sales,
        ra.region_num_orders,
        ra.region_num_customers,

        -- Average sales per customer (country-level)
        ROUND(
            CASE
                WHEN ca.num_customers > 0
                THEN ca.total_sales * 1.0 / ca.num_customers
                ELSE NULL
            END
        , 2) AS avg_sales_per_customer,

        -- Average order value (country-level)
        ROUND(
            CASE
                WHEN ca.num_orders > 0
                THEN ca.total_sales * 1.0 / ca.num_orders
                ELSE NULL
            END
        , 2) AS avg_order_value,

        -- Share of region's sales (%)
        ROUND(
            100.0 * ca.total_sales / ra.region_total_sales
        , 2) AS pct_of_region_sales,

        -- Share of global sales (%)
        ROUND(
            100.0 * ca.total_sales / SUM(ca.total_sales) OVER ()
        , 2) AS pct_of_global_sales,

        -- Rank of country within its region by total sales
        RANK() OVER (
            PARTITION BY ca.region
            ORDER BY ca.total_sales DESC
        ) AS rank_in_region
    FROM country_agg ca
    JOIN region_agg ra
        ON ca.region = ra.region
)

-- 5) Final output
SELECT
    region,
    country,
    total_sales,
    num_orders,
    num_customers,
    region_total_sales,
    region_num_orders,
    region_num_customers,
    avg_sales_per_customer,
    avg_order_value,
    pct_of_region_sales,
    pct_of_global_sales,
    rank_in_region
FROM country_vs_region
ORDER BY
    region,
    rank_in_region;
