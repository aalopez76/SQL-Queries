# SQL Queries: From Fundamental to Advanced

A complete SQL portfolio project: descriptive, analytical, diagnostic, predictive & structural analysis.

### Project Background

This project analyzes the operational and commercial performance of Toys & Models Co., a global distributor of collectible cars, motorcycles, planes, and scale models.

The company operates in the wholesale/retail hobbyist industry and has been active for over 20 years, serving customers across North America, Europe, and APAC. Its business model revolves around:

- Selling scale-model products (cars, planes, ships, motorcycles)
- Managing customer orders & payments
- Distributing inventory worldwide from regional offices
- A B2B commercial structure (customers have assigned sales representatives)
- Product-centric revenue driven by seasonal demand

From the perspective of a data analyst, this project evaluates:

- Sales performance
- Customer behavior
- Product demand patterns
- Operational quality & data integrity
- Organizational structure
- Forecasting-ready datasets

Insights and recommendations are provided on four key areas:

- Category 1: Customer & Geographic Insights
- Category 2: Product & Sales Performance
- Category 3: Operational Quality & Data Integrity
- Category 4: Employee & Organizational Structure

The SQL queries used for exploration, cleaning, analysis, and modeling are organized in:
- descriptive
- analytical
- diagnostic
- predictive
- structural
 
---
### Data Structure & Initial Checks

The main database contains 8 tables, with a total of:

- 122 customers
- 23 employees
- 7 product lines
- 110 products
- 326 orders
- 2,994 order details
- 273 payments
- 7 offices

#### Database Schema

- Table: customers (122 rows)
  - Customer details, sales representative, credit limit, location

- Table: employees (23 rows)
  - Employee info, job titles, reporting hierarchy

- Table: offices (7 rows)
  - Regional office locations & contact data

- Table: orders (326 rows)
  - Order header (dates, status, customer)

- Table: orderdetails (2994 rows)
  - Line item detail per order
  - Core of revenue calculation

- Table: payments (273 rows)
  - Customer payment history

- Table: products (110 rows)
  - Product catalog & pricing

- Table: productlines (7 rows)
  - Product line grouping / descriptions

**Database Schema:**

![Database Schema](img/toys_and_models-db.png)

---

## Executive Summary
Overview of Findings

The analysis shows that revenue is highly concentrated in a small subset of top-performing products, with significant geographic variation across countries. Customer workload among sales representatives is unevenly distributed, and operational checks reveal minor data inconsistencies related to referential integrity and missing values. Monthly performance exhibits predictable seasonality that can be leveraged for forecasting.

Three most important insights:

Sales are heavily concentrated: ~20% of products generate more than 60% of total revenue.

Geography matters: Certain countries consistently outperform others and show different purchasing patterns.

Sales reps have uneven customer loads, impacting performance, responsiveness, and operational balance.


---
This project focuses on identify trends, opportunities, and operational bottlenecks through structured SQL analysis to provide a comprehensive overview of the *Toys & Models* company operations.  

The database contains detailed information about employees, products, orders, customers, and payments — forming a realistic business ecosystem suitable for relational data modeling and advanced SQL querying.

**Database Schema:**

![Database Schema](img/toys_and_models-db.png)

---

### Project Summary

The goal of this project is to extract, and analyze key business insights by progressing from fundamental SQL operations to advanced analytical queries 

Each stage of the workflow builds upon the previous one:

1. **Database Connection**  
   A modular, Object-Oriented (OOP) connection layer is implemented to support multiple database engines (e.g., MySQL, PostgreSQL, SQLite).  
   This abstraction enables flexible and reusable interaction with diverse data sources.  
   The class definitions and credential configuration can be reviewed in the repository’s `SQL-Connection` module.

2. **Desciptive Queries**
3. **Analytical Queries**
4. **Diagnostic Queries**
5. **Predictive or Feature-Support Queries**
6. **Structural/Organizacional Queries**
   
   





