-- 06_top_bottom_product_by_productline.sql
-- Purpose:
--   Identify both the top-selling and least-selling products within each product line.
--   Includes:
--   - total sales per product
--   - rank (descending) for best sellers
--   - reverse rank (ascending) for worst sellers
--   - final output shows one top and one bottom product per productLine
--
-- Dataset: toys_and_models.sqlite (Classic Models schema)

-- 1) Compute total sales per product per product line
WITH ProductLineSales AS (
    SELECT
        p.productLine,
        p.productCode,
        p.productName,
        SUM(od.quantityOrdered * od.priceEach) AS totalSales
    FROM products p
    JOIN orderdetails od
        ON p.productCode = od.productCode
    GROUP BY
        p.productLine,
        p.productCode,
        p.productName
),

-- 2) Rank products within each product line (best and worst)
RankedProducts AS (
    SELECT
        productLine,
        productCode,
        productName,
        ROUND(totalSales, 2) AS totalSales,

        -- Highest-selling product = rank 1
        RANK() OVER (
            PARTITION BY productLine
            ORDER BY totalSales DESC
        ) AS salesRankDesc,

        -- Lowest-selling product = rank 1 (ascending)
        RANK() OVER (
            PARTITION BY productLine
            ORDER BY totalSales ASC
        ) AS salesRankAsc
    FROM ProductLineSales
)

-- 3) Final output: best-selling and worst-selling product per product line
SELECT
    productLine,
    productCode,
    productName,
    totalSales,
    CASE
        WHEN salesRankDesc = 1 THEN 'Top Seller'
        WHEN salesRankAsc = 1 THEN 'Worst Seller'
    END AS category
FROM RankedProducts
WHERE
    salesRankDesc = 1  -- top-selling
    OR
    salesRankAsc = 1   -- least-selling
ORDER BY
    productLine,
    category DESC;  -- ensures Top Seller appears before Worst Seller
