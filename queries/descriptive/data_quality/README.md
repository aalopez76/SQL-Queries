### Data Quality Checks

This module contains a structured set of SQL queries used to evaluate the foundational health of the dataset, focusing on the three core pillars of data quality:

1. Completeness – ensuring mandatory fields are populated
2. Uniqueness – verifying primary key consistency
3. Referential Integrity – validating that relationships between tables are intact

These checks form the baseline validation layer before any descriptive, analytical, or diagnostic work is performed.
They reflect standard practices in data engineering, data warehousing, and enterprise data governance.

## Directory Contents

Below is the recommended sequence for executing data quality checks, ordered by dependency and severity.

- 01_null_checks.sql

  Ensures data completeness across core dimension and fact tables.

  Checks for missing values in mandatory fields:
  - customers: customerNumber, customerName, creditLimit
  - orders: orderNumber, customerNumber, orderDate, status
  - employees: employeeNumber, firstName, lastName, jobTitle

  These validations detect incomplete records, which may indicate ingestion issues, upstream data errors, or schema violations.

- 02_duplicate_checks.sql

  Validates uniqueness of primary keys:
  - Duplicate customerNumber
  - Duplicate orderNumber
  - Duplicate productCode

  Duplicate PKs compromise joins, aggregations, and any downstream modeling.
  This file ensures key business entities conform to entity integrity standards.

- 03_fk_orderdetails_orders.sql

  Checks referential integrity between:
  ```
  orderdetails.orderNumber  →  orders.orderNumber

  ```
  Flags order lines referencing non-existent orders, indicating:
  - Broken transactional records
  - Deleted or corrupted parent rows
  - ETL or ingestion inconsistencies

  This is critical for transactional accuracy.

- 04_fk_orderdetails_products.sql

  Validates:
  ```
  orderdetails.productCode  →  products.productCode

  ```
  Identifies order lines that reference products not present in the product catalog.
  Common causes include:
  - Legacy data
  - Incorrect product imports
  - Orphaned rows due to data deletions

  Ensures catalog integrity and consistency in SKU-level reporting.

- 05_fk_employees_reporting.sql

  Evaluates the hierarchical integrity of the employee structure:
  ```
  employees.reportsTo  →  employees.employeeNumber

  ```
  Detects employees assigned to non-existent managers, which may reveal:
  - Broken org charts
  - Incorrect HR data
  - Incomplete employee onboarding/inactivation processes

  This is essential for sales hierarchy analysis, commission structures, and HR reporting.

- 06_fk_customers_salesrep.sql

  Validates assignment of customers to sales representatives:
  ```
  customers.salesRepEmployeeNumber  →  employees.employeeNumber

  ```
  Detects customers assigned to missing or invalid reps, indicating:
  - CRM inconsistencies
  - Personnel turnover not reflected in the data
  - Structural gaps in account ownership

  Ensures the dataset supports reliable commercial analytics and segmentation.

## Module Objective

This module is designed to answer core questions about structural data health:
- Are mandatory fields populated?
- Are primary keys unique and reliable?
- Are transactional tables correctly linked to their parent dimensions?
- Are hierarchies and reporting chains intact?
- Are account ownership and sales rep assignments valid?

By validating completeness, uniqueness, and referential integrity, this module enables:
- confidence in downstream analysis
- prevention of cascading data issues
- governance-aligned quality assurance
- reliable business metrics and dashboards

It represents the baseline quality floor required before deeper descriptive, analytical, or diagnostic insights.
