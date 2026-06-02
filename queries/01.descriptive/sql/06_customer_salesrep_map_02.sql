SELECT
    c.customerName,
    e.firstName || ' ' || e.lastName AS employeeName
FROM
    customers AS c
INNER JOIN
    employees AS e
    ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY
    employeeName, c.customerName;
