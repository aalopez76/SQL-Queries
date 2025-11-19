## Analytical SQL Queries

This module contains a set of analytical SQL queries designed to deepen business understanding through trends, patterns, comparative analysis, and performance metrics.

While *queries/descriptive/* answers **what is happening**,
this module answers **why it is happening** and what factors explain the behavior observed.

The queries leverage:

- Window functions
- Hierarchical CTEs
- Rolling averages
- MoM and YoY comparisons
- ABC segmentation
- Multidimensional KPIs
- Geographic, portfolio, customer, and salesforce analytics

### Directory Contents
- 01_sales_by_country_vs_region.sql
  
  Multilevel geographic deep dive (territorial analysis and commercial expansion strategies):
  - Sales by country and region
  - Regional and global totals
  - % share of regional sales
  - % share of global sales
  - Within-region ranking
  - “Market coverage” style analysis

- 02_products_deep_agg.sql
  
  Deep dive into product performance (A complete SKU-level portfolio analysis):
  - Total sales
  - Units sold
  - Orders and customers
  - Average ticket metrics
  - Global % contribution
  - Pareto cumulative %
  - ABC segmentation
  
- 03_customer_deep_agg_phase2.sql
  
  Deep dive into customer performance (Critical for segmentation, CRM, marketing, and customer value analysis):
  - Sales, units, and distinct products purchased
  - Average ticket metrics
  - Global % contribution
  - Customer-level ABC segmentation
  - Ranking.

- 04_salesrep_performance_deep_agg.sql
  
  Comprehensive salesforce performance analysis (a full 360° view of the sales organization):
  - Total sales
  - Units and orders
  - Customer count
  - Countries covered
  - Office and territory context
  - Average ticket metrics
  - Global ranking and ABC classification

- 05_productline_sales_mom_trend.sql
  
  Time-series analysis by product family (productLine):
  - Monthly sales
  - MoM (absolute and %)
  - YoY comparisons
  - 3-month rolling averages
  - Within-line comparisons

- 06_top_bottom_product_by_productline.sql
  
  Top and bottom performers within each product line (prioritization and lifecycle decisions):
  - Best-selling product per line
  - Least-selling product per line
  - Internal ranking by product line
  - Driver vs. tail product analysis

- 07_product_sales_mom_trend.sql
  
  Monthly trend analysis for a specific SKU (monitoring premium or strategic products):
  - MoM
  - YoY
  - Rolling averages
  - Granular SKU-level diagnostics

- 08_salesrep_rank_by_revenue.sql
  
  Lean but robust ranking of sales representatives:
  - Total sales
  - Number of customers
  - Number of countries
  - Number of orders
  - Average ticket
  - Descending performance ranking

### Module Objective

This collection of analytical queries is designed to answer key business questions:
- What explains performance differences across products, customers, countries, and sales reps?
- Which product lines are driving growth?
- Which products sustain each line?
- Which customers and products follow the 80/20 rule?
- Where are the opportunities for territorial expansion?
- What is the impact of each sales representative?
- How does each entity behave over time (MoM, YoY, rolling trends)?
