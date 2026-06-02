SELECT
    c.country,

    -- Total de ventas
    ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS total_sales,

    -- Número de pedidos
    COUNT(DISTINCT o.orderNumber) AS num_orders,

    -- Promedio de ventas por cliente
    ROUND(
        SUM(od.quantityOrdered * od.priceEach)
        / COUNT(DISTINCT c.customerNumber),
        2
    ) AS avg_sales_per_customer

FROM customers AS c
INNER JOIN orders AS o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails AS od ON o.orderNumber = od.orderNumber

GROUP BY
    c.country

ORDER BY
    total_sales DESC;
