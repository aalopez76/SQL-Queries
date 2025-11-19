SELECT
    e.employeeNumber,
    e.firstName || ' ' || e.lastName AS salesRepName,
    COUNT(c.customerNumber) AS numCustomers
FROM employees e
JOIN customers c
    ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY e.employeeNumber
ORDER BY numCustomers DESC;

