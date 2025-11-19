## Descriptive SQL Queries

This module contains a set of SQL queries designed to explore, profile, and understand the *Toys & Models (Classic Models)* commercial database. Each script addresses a different aspect of the business: table structure, dimensions, customer profiles, sales, sales representative performance, and order composition.

The approach is fully descriptive and focused on producing key KPIs that serve as the foundation for more advanced analytical work.

### Directory Contents

- 01_table_exploration.sql

Explores the general structure of the database. Includes:

  - List of tables
  - Basic content review
  - General exploration

- 02_table_dimensions.sql

Retrieves the fundamental dimensions of the dataset:

- Number of rows per table
- Number of columns per table (via PRAGMA)

- 03_business_overview.sql

Provides a high-level business overview. Reports:

- Total number of customers
- Total number of products
- Total number of employees

- 04_customer_credit_profile.sql

Analyzes the credit profile of customers:

- Maximum, minimum, and average credit limit (Excluding zero-value limits)

- 05_sales_by_country.sql

Full sales report by country, including:

- Total sales
- Number of orders
- Average sales per customer
- Average order value (ticket size)
- Ranking by sales volume

- 06_customer_salesrep_map.sql

Relationship between customers and sales representatives. Includes:

- Customers without an assigned representative
- Customer count per representative
- Ordered customer–representative mapping

- 07_order_size_unique_products.sql

Detailed analysis of orders:

- Number of unique products per order
- Total order value
- Total units sold
- Ranking by order value

### Module Objective

This set of queries helps answer key business questions:

- What is the structure and distribution of the dataset?
- How large are the tables, and how are they related?
- What is the credit profile of customers?
- Which markets generate the highest sales volume?
- How many customers does each representative manage, and how are they distributed?
- Which orders stand out due to size or value, and what products do they include?
- How do orders contribute to the organization’s overall performance?
