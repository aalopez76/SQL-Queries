SELECT 
    'max' AS type,
    MAX(creditLimit) AS credit_limit
FROM customers
WHERE creditLimit > 0

UNION ALL
SELECT 
    'min',
    MIN(creditLimit)
FROM customers
WHERE creditLimit > 0

UNION ALL
SELECT 
    'avg',
    AVG(creditLimit)
FROM customers
WHERE creditLimit > 0;
