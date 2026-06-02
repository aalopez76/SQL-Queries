# PostToolUse hook: formatea con sqlfluff el archivo .sql recién escrito/editado.
# Defensivo: si sqlfluff no está instalado o el archivo no es .sql, sale 0 sin hacer nada,
# para no interrumpir nunca el flujo de edición.
$ErrorActionPreference = 'SilentlyContinue'

# Claude Code entrega el contexto del hook como JSON por stdin.
$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }

try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }

$file = $payload.tool_input.file_path
if (-not $file) { exit 0 }
if ($file -notmatch '\.sql$') { exit 0 }      # solo SQL
if (-not (Test-Path $file)) { exit 0 }

# ¿Está sqlfluff disponible?
if (-not (Get-Command sqlfluff -ErrorAction SilentlyContinue)) { exit 0 }

# Formatear in-place con el dialecto del proyecto.
sqlfluff fix $file --dialect sqlite --force *> $null
exit 0
