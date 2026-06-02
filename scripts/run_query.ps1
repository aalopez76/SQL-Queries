<#
.SYNOPSIS
  Ejecuta un script .sql contra la base de datos SQLite del proyecto (solo lectura).
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
  Write-Error "No se encontró 'sqlite3' en el PATH. Instálalo o añádelo al PATH."
  exit 1
}
if (-not (Test-Path $Database)) { Write-Error "Base de datos no encontrada: $Database"; exit 1 }
if (-not (Test-Path $Query))    { Write-Error "Consulta no encontrada: $Query"; exit 1 }

Write-Host "▶ Ejecutando $Query  sobre  $Database" -ForegroundColor Cyan
# -readonly garantiza que ninguna consulta pueda modificar la BD.
sqlite3 -readonly -header -column $Database ".read $Query"
