## SQL Queries: From Fundamental to Advanced

A complete end-to-end SQL analytics project: descriptive, analytical, diagnostic, predictive, and structural analysis.

### Project Background

This project analyzes the operational, commercial, and organizational performance of Toys & Models Co., a global distributor of collectible scale models.
The analysis is performed entirely with SQL, following a professional multi-layer analytics framework.

The company operates across North America, Europe, and APAC, maintaining:
- A global product catalog (cars, motorcycles, aircraft, ships)
- A sales-rep–driven B2B commercial structure
- Regionally distributed offices
- A diverse customer base
- Multi-stage order processing
- Credit- and payment-dependent workflows.

The SQL work in this project builds a comprehensive view of sales, customers, products, operations, data quality, risk, forecasting signals, and organizational structure, all from the perspective of a senior data analyst/data scientist.

From the perspective of a data scientist, this project evaluates:
- Sales performance & revenue distribution
- Customer behavior, engagement, and value
- Product demand cycles, seasonality, and portfolio concentration
- Geographic patterns & regional variation
- Sales representative performance & workload
- Data quality, integrity, and referential consistency
- Organizational hierarchy, office structure, and coverage
- Predictive-ready features for forecasting and customer retention

Insights and recommendations are provided on four key areas:

1. Customer & Geographic Insights
2. Product & Sales Performance
3. Operational Quality & Data Integrity
4. Employee Performance & Organizational Structure

The SQL queries used for exploration, cleaning, analysis, and modeling are organized in:

- descriptive — data exploration, KPIs, completeness, uniqueness, and integrity checks
- analytical — deep dives by country, region, product, customer, and sales rep
- diagnostic — anomaly detection, outliers, misalignment, and risk analysis
- predictive — RFM scoring, demand trends, next-order estimation, time-series features, cross-sell
- structural — organizational hierarchy, office–territory mapping, coverage structure

Each module contains production-grade SQL with documentation, window functions, CTEs, recursive queries, advanced aggregations, and business logic embedded directly in SQL.

## Data Structure & Initial Checks

The dataset contains detailed relational information on customers, products, orders, payments, offices, and employees.
A full set of data quality checks (nulls, duplicates, FK integrity, hierarchy integrity) confirms the dataset is well-structured with a few minor issues (e.g., missing rep assignments, orphan order details).

Database Schema

![Database Schema](img/toys_and_models-db.png)

The schema includes:
- customers — customer details, assigned sales reps, credit limits
- employees — hierarchical reporting chain, job roles
- offices — geographic distribution of sales offices
- orders — order-level metadata
- orderdetails — line-item transactional detail
- payments — customer payments
- products — catalog & pricing
- productlines — category grouping

Totals:
- 122 customers
- 23 employees
- 110 products
- 326 orders
- 2,994 order details
- 273 payments
- 7 product lines
- 7 offices

## Executive Summary
Overview of Findings

Across all analysis layers, the business shows:
- Highly concentrated sales among a small subset of products and customers
- Geographic imbalance, with certain countries dominating revenue
- Predictable seasonality, seen clearly through lag/lead trends
- Uneven workload among sales representatives
- Mostly clean data, with minor referential and assignment inconsistencies
- Strong correlation between credit limit, purchase volume, and engagement
- Clear organizational structure, with multi-level management and territorial coverage

Most important insights:

1. Product concentration drives performance
~20% of SKUs generate >60% of revenue, forming a clear “core portfolio.”

2. Sales rep management impacts customer revenue
Customers assigned to active sales reps consistently generate higher revenue and show lower recency gaps.

3. Demand shows strong monthly cycles
Lag/lead time-series analysis reveals consistent patterns ideal for forecasting inventory and promotions.

Insights Deep Dive

Category 1 — Customer & Geographic Insights
  - Revenue is heavily concentrated in top markets (Western Europe and North America).
  - NTILE segmentation identifies bottom-quartile countries with very low revenue → strategic expansion candidates.
  - Customers with larger credit limits place significantly larger or more frequent orders.
  - Geographic contribution to total sales varies from <1% to >20% per country.
  - Sales rep assignment directly increases customer revenue by 20–30%.

Category 2 — Product & Sales Performance
  - Top-selling products dominate revenue; bottom quartile contributes minimally.
  - Monthly time-series features (lags, quartiles) show repeated spikes around specific months.
  - Product lines show distinct patterns: some consistently growing, others declining.
  - Quartile segmentation reveals which SKUs consistently outperform peers within each month.
  - Cross-sell analysis identifies strong product pairings based on order co-occurrence.

Category 3 — Operational Quality & Data Integrity
  - Outlier detection reveals bottom 5% and top 5% credit assignments → useful for risk & VIP identification.
  - FK integrity checks find occasional orphan orderdetails → candidates for cleaning.
  - Null checks reveal address and representative assignment gaps.
  - Duplicate checks confirm primary key integrity across customers, orders, and products.
  - Credit vs. sales misalignment (ratio-based) reveals accounts with disproportionate credit or low performance.

Category 4 — Employee Performance & Organizational Structure

  - Sales reps differ widely in:
    - total revenue
    - assigned customers
    - assigned countries
    - ticket size

  - Ranking and percentiles highlight top/bottom 5% performers.
  - Recursive CTE reveals 3+ levels of management hierarchy.
  - Office/territory mapping shows how customer coverage is distributed globally.
  - Coverage maps reveal clear regional specialization among offices.

## Recommendations
Based on the findings:

1. Reassign customer portfolios to balance workload across sales reps.
2. Increase focus on underperforming countries—bottom NTILE 25% could support targeted expansion efforts.
3. Prioritize high-value SKUs for inventory planning and marketing.
4. Automate FK integrity and null checks to prevent operational inconsistencies.
5. Use predictive features (lags, trends, RFM) to support forecasting and customer retention strategies.
6. Monitor high-risk customers using credit/sales ratios and recency thresholds.
7. Leverage cross-sell product pairs for bundled promotions and upsell initiatives.

## Assumptions & Caveats

1. Missing address fields were treated as non-critical and excluded from analysis.
2. High credit limits may reflect legitimate VIP or strategic customers.
3. Shipping performance was evaluated only where dates were available.
4. Revenue calculations assumed quantityOrdered * priceEach as the authoritative metric.
5. Historical sales were not adjusted for inflation or currency effects.
6. Predictive features provide signals, not full ML model predictions.

