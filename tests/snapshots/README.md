# Regression snapshots

These files capture the **expected result** of the `queries/04.predictive/`
queries to **detect drift**: if the database or a query changes, the result
stops matching its snapshot and CI fails.

## What's here

- `04.predictive/<query>.csv` — CSV output of each predictive query.
  The data rows are sorted in **canonical order** (alphabetically) after the
  header, not in the query's business `ORDER BY`. This makes the snapshot
  deterministic even if different `sqlite3` versions break ties differently.
  They are regression artifacts, not presentation artifacts.

## How they are used

```powershell
# Verify (what CI does). Fails if any result has drifted:
pwsh scripts/snapshot_predictive.ps1

# Regenerate when the change is EXPECTED (e.g. you fixed a query
# or updated the database on purpose):
pwsh scripts/snapshot_predictive.ps1 -Update
```

## When to regenerate

Only when the result change is **intentional**. If CI flags an unexpected drift,
investigate before regenerating: it may be an accidental change in a query
or in `data/toys_and_models.sqlite`.
