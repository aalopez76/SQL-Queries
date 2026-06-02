SELECT
    e.employeeNumber,
    e.firstName || ' ' || e.lastName AS employeeName,
    COUNT(c.customerNumber) AS numCustomers
FROM employees AS e
INNER JOIN customers AS c
    ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY e.employeeNumber
ORDER BY numCustomers DESC;
