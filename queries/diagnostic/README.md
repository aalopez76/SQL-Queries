## Diagnostic SQL Queries

This module contains diagnostic SQL queries designed to identify anomalies, outliers, and operational misalignments within the business. Its goal is to highlight patterns that may require:

- credit policy review
- risk assessment
- commercial intervention
- financial oversight.

While the descriptive and analytical modules explain what is happening and why,
this diagnostic module focuses on what should not be happening, what deviates from expected behavior, and which cases warrant immediate attention.

The queries leverage:

- ratio analysis (credit ↔ sales)
- outlier detection
- percentile-based classification
- geographic diagnostics
- recency and inactivity analysis
- rule-based risk flagging

### Directory Contents
- 01_geographic_credit_anomalies.sql

  Detects geographic anomalies by comparing credit allocation and realized sales at the country level. Identifies countries with:

  - High Credit vs Low Sales (potential over-crediting)
  - Low Credit vs High Sales (under-crediting or growth opportunity)
  - Credit-to-sales ratio analysis with extreme-tail detection (top/bottom 10%)

- 02_low_high_credit_outliers.sql

  Identifies pure credit outliers, both unusually low and unusually high.
  The script calculates:
  - Percentiles from 1 to 100
  - Bottom 5% → Low-Credit Outliers
  - Top 5% → High-Credit Outliers
  
- 03_credit_vs_sales_misalignment_ratio.sql

  Identifies customers whose credit limit is strongly misaligned with their realized sales using ratio-based thresholds:
  - High Credit / Low Sales: creditLimit ≥ 2 × totalSales
  - Low Credit / High Sales: totalSales ≥ 2 × creditLimit
  - Classifies customers into:
    - operational risk
    - credit policy inconsistencies
    - over/under-allocation of credit

- 04_high_risk_customers_ratio.sql

  Combines credit risk and operational risk into a unified diagnostic:

    1. Credit/Sales Misalignment (ratio ≥ 3×)
       - Excessive credit relative to sales
       - Excessive sales relative to credit

    2. Recency/Inactivity Risk
       - Last order ≥ 180 days
       - Or no order history at all

    3. Risk Flags
       - NO ORDERS / CREDIT ASSIGNED
       - STALE ACTIVITY
       - HIGH CREDIT / LOW SALES
       - LOW CREDIT / HIGH SALES

### Module Objective

This diagnostic module is designed to answer critical questions such as:
- Where are credit policies inconsistent or misaligned?
- Which customers have credit levels disproportionate to their realized sales?
- Which countries exhibit atypical credit/sales behavior?
- Which customers represent high operational or financial risk due to low activity + high credit?
- Which cases are clear outliers requiring manual review or corrective action?
- Where are the top opportunities to optimize credit allocation?

