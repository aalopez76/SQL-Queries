# Data quality report — toys_and_models.sqlite

> Generated: **2026-06-01** · Engine: SQLite 3.51
> Database: `data/toys_and_models.sqlite` · 8 tables · 59 columns · 3,450 rows
> Applied thresholds: `configs/thresholds.yaml` (`max_null_pct = 0.20`, `low_cardinality_max = 20`)

## Summary

| Check | Result |
|---|---|
| Tables present (vs `expected_tables`) | ✅ 8 / 8 |
| Tables without a primary key | ✅ none |
| PK duplicates (customers / orders / products) | ✅ 0 / 0 / 0 |
| Referential integrity (8 FK relationships) | ✅ 0 orphans |
| Improper negative values (`forbid_negative_in`) | ✅ 0 |
| Columns with nulls > 20% | ⚠️ 7 (all in optional fields) |

**Overall verdict: ✅ APPROVED with observations.** The database is structurally sound
(no orphans, no duplicates, no negative values). The only observations are nulls in
optional fields (secondary addresses, comments, HTML/image descriptions), consistent
with the *Assumptions & Caveats* in the README.

## Row counts per table

| Table | Rows | Columns |
|---|---|---|
| customers | 122 | 13 |
| employees | 23 | 8 |
| offices | 7 | 9 |
| orders | 283 | 7 |
| orderdetails | 2,649 | 5 |
| payments | 249 | 4 |
| products | 110 | 9 |
| productlines | 7 | 4 |

## Nulls (only columns with nulls > 0)

| Table | Column | % nulls | Nulls | Status |
|---|---|---:|---:|---|
| customers | addressLine2 | 82.0% | 100 | 🔴 > threshold — optional field |
| customers | state | 59.8% | 73 | 🔴 > threshold — not applicable to many countries |
| customers | salesRepEmployeeNumber | 18.0% | 22 | ⚠️ *missing rep assignments* (business insight) |
| customers | postalCode | 5.7% | 7 | ✅ low |
| employees | reportsTo | 4.3% | 1 | ✅ expected (1 = president, root of the hierarchy) |
| offices | addressLine2 | 28.6% | 2 | 🔴 > threshold — optional field |
| offices | state | 42.9% | 3 | 🔴 > threshold — not applicable to non-US offices |
| orders | shippedDate | 1.8% | 5 | ✅ orders not yet shipped (On Hold/Cancelled) |
| orders | comments | 76.7% | 217 | 🔴 > threshold — optional free-text field |
| productlines | htmlDescription | 100% | 7 | 🔴 fully empty column |
| productlines | image | 100% | 7 | 🔴 fully empty column |

> **Note:** the 22 nulls in `salesRepEmployeeNumber` confirm the README's observation about
> *"missing rep assignments"*. These are not FK orphans (the 100 assigned reps do exist in
> `employees`); they are customers with no assigned sales rep — relevant for sales-coverage analysis.

## Categorical cardinality (low_cardinality_max = 20)

| Table | Column | Distinct | Type |
|---|---|---:|---|
| orders | status | 4 | categorical (Shipped, Resolved, Cancelled, On Hold) |
| offices | territory | 4 | categorical |
| employees | jobTitle | 7 | categorical |
| products | productLine | 7 | categorical |
| customers | country | 28 | medium |
| productlines | image / htmlDescription | 0 | constant (empty) |

Detected identifiers (cardinality ≈ row count): `customerNumber`, `orderNumber`,
`productCode`, `employeeNumber`, `officeCode` — consistent with their primary keys.

## Extreme values (numeric columns, `iqr_multiplier = 1.5`)

| Column | Min | Max | Mean | Negatives |
|---|---:|---:|---:|---:|
| customers.creditLimit | 0 | 227,600 | 67,659.02 | 0 |
| orderdetails.quantityOrdered | 20 | 59 | 34.75 | 0 |
| orderdetails.priceEach | 26.55 | 214.30 | 91.01 | 0 |
| payments.amount | 1,128.20 | 116,208.40 | 31,941.11 | 0 |
| products.buyPrice | 15.91 | 103.42 | 54.40 | 0 |
| products.MSRP | 33.19 | 214.30 | 100.44 | 0 |

> **Observation:** 24 customers have `creditLimit = 0`. This is not a data error — they are
> accounts with no credit line (typically customers without an assigned sales rep). Useful for the
> risk analysis in the `02.diagnostic` layer.

## Referential integrity

| Relationship (child → parent) | Orphans |
|---|---:|
| orderdetails.orderNumber → orders | ✅ 0 |
| orderdetails.productCode → products | ✅ 0 |
| orders.customerNumber → customers | ✅ 0 |
| payments.customerNumber → customers | ✅ 0 |
| customers.salesRepEmployeeNumber → employees | ✅ 0 |
| employees.reportsTo → employees | ✅ 0 |
| products.productLine → productlines | ✅ 0 |
| employees.officeCode → offices | ✅ 0 |

## Recommended actions

1. **Do not impute** empty addresses/states: they are optional by design (international
   customers/offices). Document them as *expected nulls*.
2. Consider **dropping** `productlines.htmlDescription` and `productlines.image` (100% empty)
   if they will not be used, or mark them explicitly as unpopulated.
3. Treat the 22 customers without `salesRepEmployeeNumber` as a **business segment** (sales
   coverage), not an error — it feeds recommendation #1 in the README (reassign portfolios).
