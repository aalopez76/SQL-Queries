-- 01_employee_hierarchy_recursive.sql
-- Purpose:
--   Retrieve the full managerial chain (hierarchy) for a given employee.
--   Uses a recursive CTE to walk upward through the reporting structure:
--     - Employee → Manager → Manager’s Manager → ... (until CEO/top level)
--
--   This query reveals the vertical structure of the organization for any employee,
--   and helps answer:
--     "Who does this person report to, all the way up the chain?"
--
-- Notes:
--   Replace :employee_id with the desired employeeNumber.
--
-- Dataset: toys_and_models.sqlite

WITH RECURSIVE EmployeeHierarchy AS (

    -- Base case: start from the selected employee
    SELECT
        employeeNumber,
        reportsTo,
        firstName || ' ' || lastName AS employeeName,
        1 AS level
    FROM employees
    WHERE employeeNumber = 1370

    UNION ALL

    -- Recursive step: climb up through the managers
    SELECT
        e.employeeNumber,
        e.reportsTo,
        e.firstName || ' ' || e.lastName AS employeeName,
        h.level + 1 AS level
    FROM employees e
    JOIN EmployeeHierarchy h
        ON e.employeeNumber = h.reportsTo
)

-- Final hierarchical output
SELECT
    level,
    employeeName AS subordinate,
    (
        SELECT firstName || ' ' || lastName
        FROM employees
        WHERE employeeNumber = h.reportsTo
    ) AS managerName
FROM EmployeeHierarchy h
ORDER BY
    level DESC;   -- Top-level manager at bottom, starting employee at top
