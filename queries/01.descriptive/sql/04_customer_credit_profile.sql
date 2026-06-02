SELECT
    'max' AS type,
    MAX(creditLimit) AS credit_limit
FROM customers
WHERE creditLimit > 0
UNION ALL
SELECT
    'min' AS type,
    MIN(creditLimit) AS credit_limit
FROM customers
WHERE creditLimit > 0
UNION ALL
SELECT
    'avg' AS type,
    AVG(creditLimit) AS credit_limit
FROM customers
WHERE creditLimit > 0;
