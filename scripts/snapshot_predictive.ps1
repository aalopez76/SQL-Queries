<#
.SYNOPSIS
  Generates and verifies snapshots of the predictive queries (04.predictive) to
  detect drift: if the DB or a query changes, the result stops matching.

.DESCRIPTION
  For each .sql in queries/04.predictive/sql/ it runs the query READ-ONLY
  and captures the result as CSV. The data rows are sorted in CANONICAL order
  (alphabetically) after the header, so the snapshot is deterministic even if
  different sqlite3 versions break ties in a different order. The snapshot does NOT
  reflect the query's business ORDER BY, but a stable regression order.

  Default mode: -Check (compares against the saved snapshots; fails if they differ).
  With -Update it regenerates the snapshots on disk (use it when the change is expected).

.EXAMPLE
  pwsh scripts/snapshot_predictive.ps1 -Update    # (re)generate the snapshots
.EXAMPLE
  pwsh scripts/snapshot_predictive.ps1            # verify (CI / regression)
#>
param(
  [string]$Database = "data/toys_and_models.sqlite",
  [string]$QueryDir = "queries/04.predictive/sql",
  [string]$SnapshotDir = "tests/snapshots/04.predictive",
  [switch]$Update
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
  Write-Error "'sqlite3' was not found in PATH."; exit 1
}
if (-not (Test-Path $Database)) { Write-Error "Database not found: $Database"; exit 1 }
if (-not (Test-Path $QueryDir)) { Write-Error "Query folder not found: $QueryDir"; exit 1 }

# Runs a query and returns its CSV with header + sorted data rows.
function Get-CanonicalCsv {
  param([string]$SqlFile)
  # -csv -header: CSV output with header; -readonly: guarantee not to mutate the DB.
  $lines = & sqlite3 -readonly -csv -header $Database ".read $SqlFile"
  if ($LASTEXITCODE -ne 0) { throw "sqlite3 failed while running $SqlFile" }
  if (-not $lines) { return @() }                 # no output
  $arr = @($lines)
  if ($arr.Count -le 1) { return $arr }           # header only (or empty)
  $header = $arr[0]
  $data = @($arr[1..($arr.Count - 1)]) | Sort-Object -CaseSensitive
  return @($header) + $data
}

if ($Update -and -not (Test-Path $SnapshotDir)) {
  New-Item -ItemType Directory -Path $SnapshotDir -Force | Out-Null
}

$sqlFiles = Get-ChildItem -Path $QueryDir -Filter "*.sql" | Sort-Object Name
if (-not $sqlFiles) { Write-Error "No .sql queries found in $QueryDir"; exit 1 }

$mode = if ($Update) { "UPDATE" } else { "VERIFY" }
Write-Host "== Predictive snapshots ($mode) ==" -ForegroundColor Cyan

$failed = 0
$updated = 0
foreach ($f in $sqlFiles) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $snapPath = Join-Path $SnapshotDir "$name.csv"
  $rows = Get-CanonicalCsv -SqlFile $f.FullName
  $dataRows = [math]::Max(0, $rows.Count - 1)
  # Canonical text with LF line endings and a trailing \n, for stable diffs.
  $current = ($rows -join "`n") + "`n"

  if ($Update) {
    Set-Content -Path $snapPath -Value $current -NoNewline -Encoding utf8
    "{0} {1,-40} {2,6} rows" -f "📸", $name, $dataRows
    $updated++
  }
  else {
    if (-not (Test-Path $snapPath)) {
      "{0} {1,-40} {2}" -f "🔴", $name, "no snapshot (run -Update)"
      $failed++; continue
    }
    $expected = Get-Content -Path $snapPath -Raw
    if ($expected -eq $current) {
      "{0} {1,-40} {2,6} rows" -f "✅", $name, $dataRows
    }
    else {
      "{0} {1,-40} {2}" -f "🔴", $name, "DRIFT detected (result != snapshot)"
      $failed++
    }
  }
}

if ($Update) {
  Write-Host "`n$updated snapshot(s) written to $SnapshotDir." -ForegroundColor Green
  exit 0
}

if ($failed -gt 0) {
  Write-Host "`n$failed query(ies) drifted. If the change is expected, run: pwsh scripts/snapshot_predictive.ps1 -Update" -ForegroundColor Red
  exit 1
}
Write-Host "`nAll snapshots match. No drift." -ForegroundColor Green
exit 0
