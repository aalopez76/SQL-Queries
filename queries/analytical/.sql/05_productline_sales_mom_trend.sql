-- 05_productline_sales_mom_trend.sql
-- Purpose:
--   Time-series analysis of monthly sales by product line (product family):
--   - monthly total sales per productLine
--   - month-over-month (MoM) change and % change
--   - year-over-year (YoY) change and % change (when applicable)
--   - 3-month rolling average of sales
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)
--
-- Notes:
--   - This script can be run for all product lines at once,
--     or filtered to a specific productLine in the WHERE clause.
--   - Date granularity: month (YYYY-MM)

-- 1) Monthly aggregated sales per product line
WITH MonthlyProductLineSales AS (
    SELECT
        p.productLine,
        strftime('%Y-%m', o.orderDate) AS salesMonth,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM orders o
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    JOIN products p
        ON p.productCode = od.productCode
    -- Optional filter: uncomment to focus on a single productLine
    -- WHERE p.productLine = 'Classic Cars'
    GROUP BY
        p.productLine,
        salesMonth
),

-- 2) Time-series enrichment by product line: MoM, YoY, rolling average
MonthlyWithWindows AS (
    SELECT
        productLine,
        salesMonth,
        totalSales,

        -- Previous month sales for this productLine
        LAG(totalSales) OVER (
            PARTITION BY productLine
            ORDER BY salesMonth
        ) AS prevMonthSales,

        -- Same month last year sales for this productLine
        LAG(totalSales, 12) OVER (
            PARTITION BY productLine
            ORDER BY salesMonth
        ) AS prevYearSales,

        -- 3-month rolling average per productLine
        ROUND(
            AVG(totalSales) OVER (
                PARTITION BY productLine
                ORDER BY salesMonth
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            )
        , 2) AS rolling3M_avg
    FROM MonthlyProductLineSales
)

-- 3) Final output with MoM & YoY metrics per product line
SELECT
    productLine,
    salesMonth,
    ROUND(totalSales, 2) AS totalSales,

    -- MoM absolute change
    (totalSales - prevMonthSales) AS mom_change,

    -- MoM % change
    ROUND(
        100.0 * (totalSales - prevMonthSales)
        / NULLIF(prevMonthSales, 0)
    , 2) AS mom_pct,

    -- YoY absolute change
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
    productLine,
    salesMonth;
