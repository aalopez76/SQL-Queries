### Structural SQL Queries

This module focuses on the organizational and structural layout of the Classic Models dataset.
The Structural module answers:

“How is the system (organization + geography + coverage) structured?”

The queries in this folder are not about performance or KPIs.
They are about relationships, hierarchies, and coverage mapping across:
- employees and managers
- organizational hierarchy
- offices and territories
- sales representatives and their customers.



## Directory Contents

- 01_employee_hierarchy_recursive.sql

  Retrieve the full managerial chain for a given employee using a recursive CTE:
  - Employee → Manager → Manager’s Manager → … → Top-level manager

  What it shows: 

  For a specific employeeNumber, the query walks upward through the reportsTo chain.

  Returns each level of the hierarchy, with:
  - subordinate
  - managerName
  - level (1 = starting employee, increasing as you go up)

  Use cases:
  - Understanding where a given employee sits in the org chart
  - Validating reporting chains
  - Providing hierarchical context for performance or territory analysis


- 02_employee_manager_flat_map.sql

  Provide a flat, one-level map of direct reporting relationships:
  - Each employee
  - Their immediate manager

  What it shows:
  - employeeName → managerName
  - Includes employeeNumber and reportsTo for structural checks

  Use cases:
  - Building an org chart
  - QA of reportsTo relationships
  - Simple supervision reporting (who reports to whom directly)

  This query intentionally stays non-recursive: it focuses on direct reports, not full chains.

- 03_office_region_structure.sql

  Describe the geographic and organizational footprint of the company at the office level:
  - Office → Territory → Country → City
  - Number of employees per office
  - Number of customers served by each office (via assigned sales reps)

  What it shows:
  - officeCode, territory, country, city, phone
  - numEmployees (employees per office)
  - numCustomers (customers attached to reps based in that office)

  Use cases:
  - Understanding regional coverage
  - Mapping headcount and customer base per office
  - Supporting decisions around regional capacity and territory assignments


- 04_org_sales_coverage_map.sql

  Provide an end-to-end view of commercial coverage:
  - Office (territory / country / city)
  - Sales Representative (employee)
  - Customers assigned to each representative

  What it shows:
  - Office-level attributes: officeCode, territory, officeCountry, officeCity
  - Sales rep attributes: employeeNumber, employeeName, jobTitle
  - Customer attributes: customerNumber, customerName, customerCountry, customerCity

  Use cases:
  - Mapping who covers what geographically and commercially
  - Understanding how customers are distributed across offices and reps
  - Providing structural context for sales performance or territory realignment
  
  This is explicitly not a performance or KPI query; it is a coverage and organization map.

## Module Objective
The Structural module is designed to answer questions such as:
- How is the organizational hierarchy structured (employees, managers, chains of command)?
- How is the company geographically structured (offices, territories, regions)?
- Which offices serve which markets and customers?
- How is the sales organization mapped from office → rep → customer?

