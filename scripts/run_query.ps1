<#
.SYNOPSIS
  Runs a .sql script against the project's SQLite database (read-only).
.EXAMPLE
  pwsh scripts/run_query.ps1 -Query queries/01.descriptive/sql/03_business_overview.sql
.EXAMPLE
  pwsh scripts/run_query.ps1 -Query queries/03.analytical/sql/02_products_deep_agg.sql -Database data/toys_and_models.sqlite
#>
param(
  [Parameter(Mandatory = $true)] [string]$Query,
  [string]$Database = "data/toys_and_models.sqlite"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
  Write-Error "'sqlite3' was not found in PATH. Install it or add it to PATH."
  exit 1
}
if (-not (Test-Path $Database)) { Write-Error "Database not found: $Database"; exit 1 }
if (-not (Test-Path $Query))    { Write-Error "Query not found: $Query"; exit 1 }

Write-Host "▶ Running $Query  against  $Database" -ForegroundColor Cyan
# -readonly guarantees that no query can modify the DB.
sqlite3 -readonly -header -column $Database ".read $Query"
