# Query Review — 04.predictive layer

> Reviewed: **2026-06-01** · Engine: SQLite 3.51
> Scope: the 8 queries in `queries/04.predictive/sql/`.
> Axes evaluated: correctness (executes), SQLite dialect, performance (`EXPLAIN QUERY PLAN`),
> style (`sqlfluff`, 0 violations after P1.1) and business logic.

## Verdict summary

| # | Query | Rows | Verdict |
|---|----------|------:|----------|
| 01 | company_monthly_timeseries | 26 | ✅ APPROVED |
| 02 | product_monthly_timeseries | 2,070 | ✅ APPROVED |
| 03 | product_lag_features | 2,070 | ✅ APPROVED |
| 04 | product_monthly_quartiles | 2,070 | ✅ APPROVED |
| 05 | product_demand_trend_flag | 109 | ✅ APPROVED (with observation) |
| 06 | customer_rfm_score | 122 | ⚠️→✅ **FIXED** (scoring bug) |
| 07 | customer_next_order_prediction | 97 | ✅ APPROVED |
| 08 | product_cross_sell_pairs | 1,367 | ✅ APPROVED |

**Correctness and style:** all 8 execute without error, are SQLite-compatible (`STRFTIME`, `JULIANDAY`,
`NTILE`, `LAG/LEAD`, `DATE(..., '+N days')`) and pass `sqlfluff lint` with 0 violations.

**Performance (overall):** all are instantaneous. The database is small (max 2,649 rows in
`orderdetails`), so table `SCAN`s and the aggregation `USE TEMP B-TREE`s are cheap; PK joins use the
autoindexes. There are no user indexes, but none are needed at this volume.

## Main finding — 06_customer_rfm_score (fixed)

**Problem:** the three dimensions used `NTILE` with the direction **inverted** relative to their own
comments and to the RFM convention (best = 5):

```
NTILE(5) OVER (ORDER BY days_since_last_order ASC)  -- gave 1 to the most recent
NTILE(5) OVER (ORDER BY freq_orders DESC)           -- gave 1 to the most frequent
NTILE(5) OVER (ORDER BY monetary DESC)              -- gave 1 to the highest spender
```

**Evidence (before):** the best customer, *Euro+ Shopping Channel* (20 orders, $613,986), scored
`rfm_score = 4` (among the lowest) and landed at the bottom; *Alpha Cognac* (2 orders, $48,051) came
first with `rfm_score = 13`. The `ORDER BY rfm_score DESC` showed the worst customers at the top.

**Fix applied:** invert the three directions; for recency, `DESC NULLS FIRST` so that customers with
no orders (recency `NULL`) fall into the worst bucket (1):

```
NTILE(5) OVER (ORDER BY days_since_last_order DESC NULLS FIRST)  -- recent → 5
NTILE(5) OVER (ORDER BY freq_orders ASC)                        -- more orders → 5
NTILE(5) OVER (ORDER BY monetary ASC)                           -- more spend → 5
```

**Evidence (after):** *Euro+ Shopping Channel* and *Mini Gifts* score `rfm_score = 15` (r=f=m=5)
and top the ranking; customers with no orders fall into `r=f=m=1`.

## Minor observations (non-blocking)

- **05_product_demand_trend_flag:** `AVG(CASE WHEN months_ago BETWEEN 0 AND 2 THEN totalSales END)`
  averages only the months **with** sales; a month without sales produces no row (it does not count as 0),
  which may overestimate the mean for products with sporadic sales. Acceptable as a signal; document it
  if used for decisions. The `INSUFFICIENT_DATA` case (growth_rate `NULL`) is handled correctly.
- **08_product_cross_sell_pairs:** the comments "Rename to match the Pandas/Pages expectations" and
  "Align with aggregations.py" reference an `aggregations.py` that **does not exist** in this repo (a
  leftover from another project). The SQL logic is correct; those comments should be cleaned up. At large
  scale, the `OrderProducts` self-join is O(n²) per order — irrelevant at this volume, worth watching if it grows.
- **04_product_monthly_quartiles:** `NTILE(4) ... ORDER BY totalSales` (ascending) → Q4 = highest sales
  of the month. Correct; the direction should be made explicit in a comment.

## Conclusion

7/8 approved directly; 1 (RFM) had a scoring bug that was **demonstrated and fixed**. The entire
`04.predictive` layer is now reviewed, executable, SQLite-compatible and clean on style.
