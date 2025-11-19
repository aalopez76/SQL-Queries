SELECT
    c.customerName,
    e.firstName || ' ' || e.lastName AS salesRepName
FROM
    customers c
JOIN
    employees e ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY
    salesRepName, c.customerName;