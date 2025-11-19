-- 07_product_sales_mom_trend.sql
-- Purpose:
--   Deep time-series analysis of product-level monthly sales:
--   - monthly total sales per product
--   - month-over-month (MoM) change and % change
--   - year-over-year (YoY) change and % change (when applicable)
--   - 3-month rolling average of sales
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)
--
-- Notes:
--   - This script is currently focused on a single product:
--       '1992 Ferrari 360 Spider red'
--     but can easily be adapted to any other product by changing the WHERE clause.
--   - Date granularity: month (YYYY-MM)

-- 1) Monthly aggregated sales for a specific product
WITH MonthlyProductSales AS (
    SELECT
        p.productCode,
        p.productName,
        strftime('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orders o
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    JOIN products p
        ON p.productCode = od.productCode
    WHERE
        -- Focus on a specific product
        -- You can change this filter to any other productName or productCode
        p.productName = '1992 Ferrari 360 Spider red'
        -- Example alternative:
        -- p.productCode = 'S18_4668'
    GROUP BY
        p.productCode,
        p.productName,
        salesMonth
),

-- 2) Time-series enrichment: MoM, YoY, rolling average
MonthlyWithWindows AS (
    SELECT
        productCode,
        productName,
        salesMonth,
        totalSales,

        -- Previous month sales (for MoM)
        LAG(totalSales) OVER (ORDER BY salesMonth) AS prevMonthSales,

        -- Same month last year sales (YoY comparison)
        LAG(totalSales, 12) OVER (ORDER BY salesMonth) AS prevYearSales,

        -- 3-month rolling average (current month + 2 previous months)
        ROUND(
            AVG(totalSales) OVER (
                ORDER BY salesMonth
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            )
        , 2) AS rolling3M_avg
    FROM MonthlyProductSales
)

-- 3) Final output with MoM & YoY metrics
SELECT
    productCode,
    productName,
    salesMonth,
    ROUND(totalSales, 2) AS totalSales,

    -- MoM absolute change
    (totalSales - prevMonthSales) AS mom_change,

    -- MoM % change
    ROUND(
        100.0 * (totalSales - prevMonthSales)
        / NULLIF(prevMonthSales, 0)
    , 2) AS mom_pct,

    -- YoY absolute change (vs same month previous year)
    (totalSales - prevYearSales) AS yoy_change,

    -- YoY % change
    ROUND(
        100.0 * (totalSales - prevYearSales)
        / NULLIF(prevYearSales, 0)
    , 2) AS yoy_pct,

    -- Rolling 3-month average of sales
    rolling3M_avg

FROM MonthlyWithWindows
ORDER BY
    salesMonth;
