## Predictive SQL Queries

This module contains a set of SQL queries designed to support lightweight predictive analytics directly within the database.
Unlike the descriptive (“What is happening?”) and analytical (“Why is it happening?”) modules, the predictive layer focuses on:
- anticipating future behavior
- deriving forward-looking indicators
- identifying early trends
- producing features useful for forecasting and recommendation systems.

These scripts do not train predictive models—they provide predictive signals and engineered features that form the foundation for any downstream modeling or time-series analysis.

The module includes:
- time-series feature engineering
- demand trend flags
- RFM customer scoring
- next-order estimation
- product co-occurrence for cross-sell insights.

### Directory Contents

Below is the recommended execution order, designed to progress from high-level time series to advanced predictive signals.

- 01_company_monthly_timeseries.sql

  Build a monthly time-series table for the entire company, including:
  - total sales
  - total orders
  - active customers per month
  - average order value (AOV)
  - on-time delivery rate

  This query is foundational for forecasting, seasonality detection, and anomaly detection at the business level.

- 02_product_monthly_timeseries.sql

  Generate a monthly time-series dataset for each product (SKU), including:
  - units sold
  - sales revenue
  - one row per product × month
    
  Forms the base feature table for product-level forecasting and trend analysis.

- 03_product_lag_features.sql

  Create lag/lead features for each product:
  - sales_lag_1 → previous month
  - sales_lag_2 → two months prior
  - sales_lead_1 → next-month forward indicator

  These engineered features are essential for:
    - classical time-series modeling
    - feature-based forecasting
    - supervised ML models.

- 04_product_monthly_quartiles.sql

  Rank each product within its month using NTILE(4):
  - quartile 1 → lowest-selling products
  - quartile 4 → top performers

  This produces a relative performance feature, useful for spotting:
  - monthly shifts in demand
  - competitive movement among SKUs
  - early signs of decline or surge.

- 05_product_demand_trend_flag.sql

  Classify products into demand trends by comparing:
  - last 3 months average vs. previous 3 months average
  - growth thresholds (±15%)

  Trend classes:
    - GROWING
    - STABLE
    - DECLINING
    - INSUFFICIENT_DATA

  This query provides a forward-looking demand signal suitable for:
  - supply chain adjustments
  - inventory strategy
  - category management.

- 06_customer_rfm_score.sql

  Compute RFM scoring (Recency, Frequency, Monetary):
  - recency = days since last order
  - frequency = distinct orders
  - monetary = total customer sales
  - full RFM score = r + f + m ranking

  This query enables:
  - churn likelihood estimation
  - customer value segmentation
  - retention prioritization.

- 07_customer_next_order_prediction.sql

  Estimate the expected date of next customer order using:
  - inter-order gaps
  - average reorder interval
  - last order date

  This produces a simple, interpretable forecasting signal useful for:
    - proactive outreach
    - demand planning
    - customer lifecycle modeling.

- 08_product_cross_sell_pairs.sql

  Identify product pairs frequently purchased together using:
  - co-occurrence counts
  - support
  - confidence metrics
  - P(product2 | product1)
  - P(product1 | product2)

  This lays the groundwork for recommendation engines and cross-selling strategies.

## Module Objective

The Predictive module provides SQL-based answers to forward-looking business questions:
- Which products are gaining or losing momentum?
- Which customers are most likely to buy again soon?
- Which customers are drifting toward churn?
- What is the expected demand trajectory of each SKU?
- Which product combinations indicate cross-sell opportunities?
- How is the business trending over time?

These queries enable sophisticated predictive insights without requiring external ML libraries—leveraging SQL window functions, time-series aggregations, and behavioral patterns.
