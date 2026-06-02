SELECT
    c.customerName,
    e.firstName || ' ' || e.lastName AS employeeName
FROM
    customers c
JOIN
    employees e ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY
    employeeName, c.customerName;