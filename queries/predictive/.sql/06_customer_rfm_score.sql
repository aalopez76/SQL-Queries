-- 06_customer_rfm_score.sql
-- Purpose:
--   Compute a simple RFM-style score (Recency, Frequency, Monetary) per customer
--   as a proxy for engagement / churn risk.
--
--   R: days since last order (lower = better)
--   F: number of orders (higher = better)
--   M: total sales (higher = better)
--
--   Each component is bucketed and combined into an RFM score.

-- 1) Aggregate basic R, F, M per customer
WITH CustomerRFM AS (
    SELECT
        c.customerNumber,
        c.customerName,
        c.country,
        COUNT(DISTINCT o.orderNumber)                      AS freq_orders,
        COALESCE(SUM(od.quantityOrdered * od.priceEach),0) AS monetary,
        MAX(o.orderDate)                                   AS last_order_date
    FROM customers c
    LEFT JOIN orders o
        ON c.customerNumber = o.customerNumber
    LEFT JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber,
        c.customerName,
        c.country
),

-- 2) Get global max order date to compute recency
GlobalMaxDate AS (
    SELECT MAX(orderDate) AS max_order_date
    FROM orders
),

-- 3) Compute days since last order (recency)
CustomerRecency AS (
    SELECT
        r.*,
        g.max_order_date,
        CASE
            WHEN r.last_order_date IS NOT NULL
            THEN CAST(julianday(g.max_order_date) - julianday(r.last_order_date) AS INTEGER)
            ELSE NULL
        END AS days_since_last_order
    FROM CustomerRFM r
    CROSS JOIN GlobalMaxDate g
),

-- 4) Rank/bucket R, F, M into simple quintiles (1–5)
CustomerRFMScored AS (
    SELECT
        customerNumber,
        customerName,
        country,
        freq_orders,
        monetary,
        last_order_date,
        days_since_last_order,

        -- Recency score: lower days_since_last_order → higher score
        NTILE(5) OVER (ORDER BY days_since_last_order ASC) AS r_score,

        -- Frequency score: more orders → higher score
        NTILE(5) OVER (ORDER BY freq_orders DESC)          AS f_score,

        -- Monetary score: higher total sales → higher score
        NTILE(5) OVER (ORDER BY monetary DESC)             AS m_score
    FROM CustomerRecency
)

-- 5) Final RFM view
SELECT
    customerNumber,
    customerName,
    country,
    freq_orders     AS total_orders,
    ROUND(monetary, 2) AS total_sales,
    last_order_date,
    days_since_last_order,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_score
FROM CustomerRFMScored
ORDER BY
    rfm_score DESC,
    total_sales DESC;
