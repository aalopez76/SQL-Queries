<#
.SYNOPSIS
  Genera y verifica snapshots de las consultas predictivas (04.predictive) para
  detectar derivas: si la BD o una consulta cambian, el resultado deja de coincidir.

.DESCRIPTION
  Por cada .sql en queries/04.predictive/sql/ ejecuta la consulta en SOLO LECTURA
  y captura el resultado en CSV. Las filas de datos se ordenan de forma CANÓNICA
  (alfabéticamente) tras la cabecera, de modo que el snapshot es determinista aun
  si distintas versiones de sqlite3 desempatan en orden distinto. El snapshot NO
  refleja el ORDER BY de negocio de la consulta, sino un orden estable de regresión.

  Modo por defecto: -Check (compara contra los snapshots guardados; falla si difieren).
  Con -Update regenera los snapshots en disco (úsalo cuando el cambio sea esperado).

.EXAMPLE
  pwsh scripts/snapshot_predictive.ps1 -Update    # (re)genera los snapshots
.EXAMPLE
  pwsh scripts/snapshot_predictive.ps1            # verifica (CI / regresión)
#>
param(
  [string]$Database = "data/toys_and_models.sqlite",
  [string]$QueryDir = "queries/04.predictive/sql",
  [string]$SnapshotDir = "tests/snapshots/04.predictive",
  [switch]$Update
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
  Write-Error "No se encontró 'sqlite3' en el PATH."; exit 1
}
if (-not (Test-Path $Database)) { Write-Error "Base de datos no encontrada: $Database"; exit 1 }
if (-not (Test-Path $QueryDir)) { Write-Error "Carpeta de consultas no encontrada: $QueryDir"; exit 1 }

# Ejecuta una consulta y devuelve su CSV con cabecera + filas de datos ordenadas.
function Get-CanonicalCsv {
  param([string]$SqlFile)
  # -csv -header: salida CSV con cabecera; -readonly: garantía de no mutar la BD.
  $lines = & sqlite3 -readonly -csv -header $Database ".read $SqlFile"
  if ($LASTEXITCODE -ne 0) { throw "sqlite3 falló al ejecutar $SqlFile" }
  if (-not $lines) { return @() }                 # sin salida
  $arr = @($lines)
  if ($arr.Count -le 1) { return $arr }           # solo cabecera (o vacío)
  $header = $arr[0]
  $data = @($arr[1..($arr.Count - 1)]) | Sort-Object -CaseSensitive
  return @($header) + $data
}

if ($Update -and -not (Test-Path $SnapshotDir)) {
  New-Item -ItemType Directory -Path $SnapshotDir -Force | Out-Null
}

$sqlFiles = Get-ChildItem -Path $QueryDir -Filter "*.sql" | Sort-Object Name
if (-not $sqlFiles) { Write-Error "No se encontraron consultas .sql en $QueryDir"; exit 1 }

$mode = if ($Update) { "ACTUALIZAR" } else { "VERIFICAR" }
Write-Host "== Snapshots predictivos ($mode) ==" -ForegroundColor Cyan

$failed = 0
$updated = 0
foreach ($f in $sqlFiles) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $snapPath = Join-Path $SnapshotDir "$name.csv"
  $rows = Get-CanonicalCsv -SqlFile $f.FullName
  $dataRows = [math]::Max(0, $rows.Count - 1)
  # Texto canónico con saltos de línea LF y un \n final, para diffs estables.
  $current = ($rows -join "`n") + "`n"

  if ($Update) {
    Set-Content -Path $snapPath -Value $current -NoNewline -Encoding utf8
    "{0} {1,-40} {2,6} filas" -f "📸", $name, $dataRows
    $updated++
  }
  else {
    if (-not (Test-Path $snapPath)) {
      "{0} {1,-40} {2}" -f "🔴", $name, "sin snapshot (corre -Update)"
      $failed++; continue
    }
    $expected = Get-Content -Path $snapPath -Raw
    if ($expected -eq $current) {
      "{0} {1,-40} {2,6} filas" -f "✅", $name, $dataRows
    }
    else {
      "{0} {1,-40} {2}" -f "🔴", $name, "DERIVA detectada (resultado != snapshot)"
      $failed++
    }
  }
}

if ($Update) {
  Write-Host "`n$updated snapshot(s) escritos en $SnapshotDir." -ForegroundColor Green
  exit 0
}

if ($failed -gt 0) {
  Write-Host "`n$failed consulta(s) con deriva. Si el cambio es esperado, corre: pwsh scripts/snapshot_predictive.ps1 -Update" -ForegroundColor Red
  exit 1
}
Write-Host "`nTodos los snapshots coinciden. Sin derivas." -ForegroundColor Green
exit 0
