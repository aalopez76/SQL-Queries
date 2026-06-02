-- 04_high_risk_customers_ratio.sql
-- Purpose:
--   Identify potentially high-risk customers based on:
--     - strong credit/sales misalignment (ratio-based)
--     - stale activity (recency-based)
--     - or no order history
--
-- Thresholds:
--   - High credit / low sales:  creditLimit >= 2 * totalSales
--   - Low credit / high sales:  totalSales >= 2 * creditLimit
--   - High recency risk:       daysSinceLastOrder >= 180 (adjustable)
--
-- Dataset: toys_and_models.sqlite

-- 1) Aggregate sales and last order date per customer
WITH CustomerActivity AS (
    SELECT
        c.customerNumber,
        c.customerName,
        c.country,
        c.creditLimit,

        COALESCE(SUM(od.quantityOrdered * od.priceEach), 0) AS totalSales,
        MAX(o.orderDate)                                    AS lastOrderDate
    FROM customers c
    LEFT JOIN orders o
        ON c.customerNumber = o.customerNumber
    LEFT JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber,
        c.customerName,
        c.country,
        c.creditLimit
),

-- 2) Global reference date (latest order in the system)
GlobalMaxDate AS (
    SELECT MAX(orderDate) AS maxOrderDate
    FROM orders
),

-- 3) Compute recency for each customer
CustomerRecency AS (
    SELECT
        ca.*,
        g.maxOrderDate,
        CASE
            WHEN ca.lastOrderDate IS NOT NULL
                 AND g.maxOrderDate IS NOT NULL
                THEN CAST(
                    julianday(g.maxOrderDate) - julianday(ca.lastOrderDate)
                    AS INTEGER
                )
            ELSE NULL
        END AS daysSinceLastOrder
    FROM CustomerActivity ca
    CROSS JOIN GlobalMaxDate g
),

-- 4) Compute credit/sales ratios
CustomerRatios AS (
    SELECT
        customerNumber,
        customerName,
        country,
        creditLimit,
        totalSales,
        lastOrderDate,
        daysSinceLastOrder,

        CASE
            WHEN totalSales > 0
                THEN creditLimit * 1.0 / totalSales
            ELSE NULL
        END AS credit_to_sales_ratio,

        CASE
            WHEN creditLimit > 0
                THEN totalSales * 1.0 / creditLimit
            ELSE NULL
        END AS sales_to_credit_ratio
    FROM CustomerRecency
    WHERE creditLimit IS NOT NULL
)

-- 5) Select high-risk customers based on ratios + recency
SELECT
    customerNumber,
    customerName,
    country,
    ROUND(creditLimit, 2)              AS creditLimit,
    ROUND(totalSales, 2)               AS totalSales,
    lastOrderDate,
    daysSinceLastOrder,
    ROUND(credit_to_sales_ratio, 2)    AS credit_to_sales_ratio,
    ROUND(sales_to_credit_ratio, 2)    AS sales_to_credit_ratio,

    CASE
        WHEN lastOrderDate IS NULL
            THEN 'NO ORDERS / CREDIT ASSIGNED'
        WHEN daysSinceLastOrder >= 180
            THEN 'STALE ACTIVITY (>= 180 days)'
        ELSE 'RECENT ACTIVITY'
    END AS activityFlag,

    CASE
        WHEN credit_to_sales_ratio >= 2 AND totalSales > 0 THEN 'HIGH CREDIT / LOW SALES'
        WHEN sales_to_credit_ratio >= 2 AND creditLimit > 0 THEN 'LOW CREDIT / HIGH SALES'
    END AS ratioFlag,

    -- Align with Pandas identify_high_risk_customers(): amount_at_risk
    ROUND(
        CASE
            WHEN (credit_to_sales_ratio >= 2 AND totalSales > 0) THEN creditLimit
            ELSE totalSales
        END
    , 2) AS amount_at_risk,

    'HIGH RISK CUSTOMER' AS riskCategory

FROM CustomerRatios
WHERE
    -- Ratio-based risk
    (credit_to_sales_ratio >= 2 AND totalSales > 0)
    OR
    (sales_to_credit_ratio >= 2 AND creditLimit > 0)
    OR
    -- Recency risk
    lastOrderDate IS NULL
    OR daysSinceLastOrder >= 180
ORDER BY
    riskCategory,
    country,
    daysSinceLastOrder DESC,
    customerName;
	
