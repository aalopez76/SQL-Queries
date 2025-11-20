-- 07_customer_next_order_prediction.sql
-- Purpose:
--   Estimate an expected next-order date per customer using
--   the average inter-order interval (in days).
--
--   For customers with >= 2 orders:
--     - Compute gaps between consecutive orders
--     - Average gap = expected reorder interval
--     - Next expected order date = last_order_date + avg_gap_days

-- 1) All orders per customer with row numbers
WITH CustomerOrders AS (
    SELECT
        c.customerNumber,
        c.customerName,
        c.country,
        o.orderNumber,
        o.orderDate,
        ROW_NUMBER() OVER (
            PARTITION BY c.customerNumber
            ORDER BY o.orderDate
        ) AS rn
    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
),

-- 2) Compute gaps between consecutive orders
OrderGaps AS (
    SELECT
        cur.customerNumber,
        cur.customerName,
        cur.country,
        cur.orderNumber,
        cur.orderDate,
        cur.rn,
        LAG(cur.orderDate) OVER (
            PARTITION BY cur.customerNumber
            ORDER BY cur.orderDate
        ) AS prev_order_date
    FROM CustomerOrders cur
),

-- 3) Calculate gap in days
GapDays AS (
    SELECT
        customerNumber,
        customerName,
        country,
        orderNumber,
        orderDate,
        rn,
        prev_order_date,
        CASE
            WHEN prev_order_date IS NOT NULL
            THEN CAST(julianday(orderDate) - julianday(prev_order_date) AS INTEGER)
            ELSE NULL
        END AS gap_days
    FROM OrderGaps
),

-- 4) Average gap per customer + last order date
CustomerGapStats AS (
    SELECT
        customerNumber,
        customerName,
        country,
        MAX(orderDate) AS last_order_date,
        AVG(gap_days)  AS avg_gap_days
    FROM GapDays
    WHERE gap_days IS NOT NULL
    GROUP BY
        customerNumber,
        customerName,
        country
)

-- 5) Final prediction: expected next order date
SELECT
    customerNumber,
    customerName,
    country,
    last_order_date,
    ROUND(avg_gap_days, 1) AS avg_gap_days,
    CASE
        WHEN avg_gap_days IS NOT NULL
        THEN date(last_order_date, '+' || CAST(avg_gap_days AS INTEGER) || ' days')
        ELSE NULL
    END AS expected_next_order_date
FROM CustomerGapStats
ORDER BY
    expected_next_order_date;
