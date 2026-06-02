<#
.SYNOPSIS
  Validación rápida de la base de datos SQLite: tablas, conteos y FKs huérfanas.
  Para el informe completo usa la skill /data_validation. Este script es el atajo de línea de comandos.
.EXAMPLE
  pwsh scripts/validate_db.ps1
  pwsh scripts/validate_db.ps1 -Db data/toys_and_models.sqlite
#>
param(
  [string]$Database = "data/toys_and_models.sqlite"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
  Write-Error "No se encontró 'sqlite3' en el PATH."; exit 1
}
if (-not (Test-Path $Database)) { Write-Error "Base de datos no encontrada: $Database"; exit 1 }

Write-Host "== Tablas y nº de filas ==" -ForegroundColor Cyan
$tables = sqlite3 -readonly $Database "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
foreach ($t in $tables) {
  if (-not $t) { continue }
  $n = sqlite3 -readonly $Database "SELECT COUNT(*) FROM `"$t`";"
  "{0,-16} {1,8}" -f $t, $n
}

Write-Host "`n== Integridad referencial (huérfanos) ==" -ForegroundColor Cyan
$fkChecks = @(
  @{ name = "orderdetails->orders";    sql = "SELECT COUNT(*) FROM orderdetails od LEFT JOIN orders o ON od.orderNumber=o.orderNumber WHERE o.orderNumber IS NULL;" },
  @{ name = "orderdetails->products";  sql = "SELECT COUNT(*) FROM orderdetails od LEFT JOIN products p ON od.productCode=p.productCode WHERE p.productCode IS NULL;" },
  @{ name = "orders->customers";       sql = "SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customerNumber=c.customerNumber WHERE c.customerNumber IS NULL;" },
  @{ name = "customers->salesRep";     sql = "SELECT COUNT(*) FROM customers c LEFT JOIN employees e ON c.salesRepEmployeeNumber=e.employeeNumber WHERE c.salesRepEmployeeNumber IS NOT NULL AND e.employeeNumber IS NULL;" },
  @{ name = "employees->reportsTo";    sql = "SELECT COUNT(*) FROM employees e LEFT JOIN employees m ON e.reportsTo=m.employeeNumber WHERE e.reportsTo IS NOT NULL AND m.employeeNumber IS NULL;" }
)
foreach ($c in $fkChecks) {
  $orphans = sqlite3 -readonly $Database $c.sql
  $flag = if ([int]$orphans -gt 0) { "🔴" } else { "✅" }
  "{0} {1,-26} huérfanos: {2}" -f $flag, $c.name, $orphans
}
