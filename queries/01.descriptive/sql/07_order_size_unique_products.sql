SELECT
    orderNumber,
    COUNT(DISTINCT productCode) AS uniqueProducts,
	ROUND(SUM(quantityOrdered * priceEach), 2) AS orderValue,
    SUM(quantityOrdered) AS totalUnits
FROM orderdetails
GROUP BY orderNumber
ORDER BY orderValue DESC;
