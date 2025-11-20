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
