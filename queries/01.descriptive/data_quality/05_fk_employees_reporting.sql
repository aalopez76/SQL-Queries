-- 05_fk_employees_reporting.sql
-- Purpose:
--   Identify employees who reference a non-existent manager in reportsTo.
--   Detects broken hierarchy links.

SELECT
    e.employeeNumber,
    e.firstName || ' ' || e.lastName AS employeeName,
    e.reportsTo
FROM employees e
LEFT JOIN employees m
    ON e.reportsTo = m.employeeNumber
WHERE e.reportsTo IS NOT NULL
  AND m.employeeNumber IS NULL;
