-- 02_employee_manager_flat_map.sql
-- Purpose:
--   Provide a flat (non-recursive) view of the reporting relationships
--   inside the organization:
--     - Each employee
--     - Their direct manager
--
--   This query maps the reporting chain at a single level of depth
--   (employee → immediate manager). It does not navigate the full hierarchy,
--   but offers a clean view of direct supervision relationships.
--
--   Useful for:
--     - organizational charts
--     - direct reporting validations
--     - structural consistency analysis
--
-- Dataset: toys_and_models.sqlite

SELECT
    e.firstName || ' ' || e.lastName AS employeeName,
    m.firstName || ' ' || m.lastName AS managerName,
    e.employeeNumber,
    e.reportsTo
FROM employees e
JOIN employees m
    ON e.reportsTo = m.employeeNumber
ORDER BY
    managerName,
    employeeName;
