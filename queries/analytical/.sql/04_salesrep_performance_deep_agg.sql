-- 04_salesrep_performance_deep_agg.sql
-- Purpose:
--   Deep-dive aggregation of sales representative performance:
--   - total sales and total units per sales rep
--   - number of orders and number of customers served
--   - customer countries covered (territorial reach)
--   - average sales per order and per customer
--   - average units per order
--   - % of global sales and cumulative %
--   - ranking and ABC classification (Pareto-style)
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- 1) Base lines: sales rep, office, customer, order, line-level sales
WITH SalesRepBase AS (
    SELECT
        e.employeeNumber,
        e.firstName || ' ' || e.lastName        AS salesRepName,
        e.jobTitle,
        e.officeCode,
        oof.country                              AS office_country,
        oof.territory                            AS office_territory,

        c.customerNumber,
        c.country                                AS customer_country,
        o.orderNumber,
        (od.quantityOrdered * od.priceEach)      AS line_sales,
        od.quantityOrdered                       AS line_units
    FROM employees e
    LEFT JOIN offices oof
        ON e.officeCode = oof.officeCode
    LEFT JOIN customers c
        ON e.employeeNumber = c.salesRepEmployeeNumber
    LEFT JOIN orders o
        ON c.customerNumber = o.customerNumber
    LEFT JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
),

-- 2) Aggregate at sales rep level
SalesRepAgg AS (
    SELECT
        employeeNumber,
        salesRepName,
        jobTitle,
        officeCode,
        office_country,
        office_territory,

        -- Aggregate value and volume
        COALESCE(SUM(line_sales), 0)                 AS total_sales,
        COALESCE(SUM(line_units), 0)                 AS total_units,

        -- Distinct entities served
        COUNT(DISTINCT orderNumber)                  AS num_orders,
        COUNT(DISTINCT customerNumber)               AS num_customers,
        COUNT(DISTINCT customer_country)             AS num_customer_countries
    FROM SalesRepBase
    GROUP BY
        employeeNumber,
        salesRepName,
        jobTitle,
        officeCode,
        office_country,
        office_territory
),

-- 3) Enrich with averages (per order / per customer)
SalesRepEnriched AS (
    SELECT
        employeeNumber,
        salesRepName,
        jobTitle,
        officeCode,
        office_country,
        office_territory,
        ROUND(total_sales, 2)                        AS total_sales,
        total_units,
        num_orders,
        num_customers,
        num_customer_countries,

        -- Average sales per order
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_sales * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                         AS avg_sales_per_order,

        -- Average units per order
        ROUND(
            CASE
                WHEN num_orders > 0
                THEN total_units * 1.0 / num_orders
                ELSE NULL
            END
        , 2)                                         AS avg_units_per_order,

        -- Average sales per customer
        ROUND(
            CASE
                WHEN num_customers > 0
                THEN total_sales * 1.0 / num_customers
                ELSE NULL
            END
        , 2)                                         AS avg_sales_per_customer
    FROM SalesRepAgg
),

-- 4) Add distribution metrics (global share, cumulative, rank)
SalesRepRanked AS (
    SELECT
        employeeNumber,
        salesRepName,
        jobTitle,
        officeCode,
        office_country,
        office_territory,
        total_sales,
        total_units,
        num_orders,
        num_customers,
        num_customer_countries,
        avg_sales_per_order,
        avg_units_per_order,
        avg_sales_per_customer,

        -- Share of global sales (%)
        ROUND(
            100.0 * total_sales
            / NULLIF(SUM(total_sales) OVER (), 0)
        , 2)                                         AS pct_of_global_sales,

        -- Cumulative share of global sales (%), ordered by total_sales DESC
        ROUND(
            100.0 * SUM(total_sales) OVER (
                ORDER BY total_sales DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / NULLIF(SUM(total_sales) OVER (), 0)
        , 2)                                         AS cumulative_pct_of_global_sales,

        -- Rank by total sales (1 = highest performing sales rep)
        RANK() OVER (ORDER BY total_sales DESC)      AS sales_rank
    FROM SalesRepEnriched
)

-- 5) Final output with ABC classification based on cumulative % of sales
SELECT
    employeeNumber,
    salesRepName,
    jobTitle,
    officeCode,
    office_country,
    office_territory,
    total_sales,
    total_units,
    num_orders,
    num_customers,
    num_customer_countries,
    avg_sales_per_order,
    avg_units_per_order,
    avg_sales_per_customer,
    pct_of_global_sales,
    cumulative_pct_of_global_sales,
    sales_rank,
    CASE
        WHEN cumulative_pct_of_global_sales <= 80 THEN 'A'   -- top reps
        WHEN cumulative_pct_of_global_sales <= 95 THEN 'B'   -- solid performers
        ELSE 'C'                                             -- long tail
    END AS abc_class
FROM SalesRepRanked
ORDER BY
    sales_rank;
