# CLAUDE.md – Single source of truth

## Mandatory Context Loading

Before performing any task in this repository:

- Read `handoff.md` first.
- If `handoff.md` does not exist, ask me to provide the current project summary before making any changes.
- Treat `handoff.md` as the authoritative summary of the current project state.
- Also read `AUDIT.md` and `REFACTOR_PLAN.md` when they are present; they contain the diagnostic and the prioritized improvement roadmap.
- Do not assume context from previous Claude conversations.
- Do not reconstruct project history by scanning the entire repository unless strictly necessary for the current task.
- Only inspect additional files when required by the task at hand.
- If information in `handoff.md` conflicts with the actual repository contents, surface the discrepancy and ask for clarification before making major changes.

## Important: Keep handoff.md Updated

After completing a significant task (feature, refactor, fix), update `handoff.md` to reflect:

- What was just done.
- Any new known issues or limitations.
- The next recommended actions.

This ensures the next session starts with an accurate picture of the project.


> Configuración adaptada al stack **real** del proyecto: analítica **SQL sobre SQLite**.
> La plantilla original (poetry / scikit-learn / MLflow / DVC / `make train`) era para un
> proyecto de ML en Python; aquí no hay modelos que entrenar, así que cada pieza se ha
> sustituido por su equivalente útil en SQL. Ver `AUDIT.md` para el detalle.

```yaml
project: sql-analytics-portfolio
stack:
  language: sql
  engine: sqlite          # data/toys_and_models.sqlite (esquema classicmodels)
  runner: sqlite3 CLI     # binario sqlite3 (v3.51+)
  lint_format: sqlfluff   # dialect: sqlite — requiere `pip install sqlfluff`
  host_runtime: python    # solo como host de sqlfluff (3.11+)
  docs: markdown          # README por módulo + docs/data_report.md
```

## Comandos (PowerShell — estás en Windows)

> Sustituyen a `make train/evaluate/...` de la plantilla, que no aplica a un proyecto SQL.

| Acción | Comando |
|--------|---------|
| Validar la BD (esquema, nulos, FKs) | `pwsh scripts/validate_db.ps1` |
| Ejecutar una consulta | `pwsh scripts/run_query.ps1 -Query queries/01.descriptive/sql/03_business_overview.sql` |
| Lint de SQL | `sqlfluff lint queries --dialect sqlite` |
| Formatear SQL | `sqlfluff fix queries --dialect sqlite` |
| Informe de datos | invocar skill `/data_validation data/toys_and_models.sqlite` |
| Revisar una consulta | invocar skill `/query_review <archivo.sql>` |

## Skills (en `.claude/skills/`)

| Skill | Archivo | Qué hace |
|-------|---------|----------|
| `data_validation` | `.claude/skills/data_validation.md` | Valida esquema/integridad del SQLite → `docs/data_report.md` |
| `query_review` | `.claude/skills/query_review.md` | Revisa un `.sql` (corrección, dialecto, rendimiento, estilo) y da dictamen |

> Nota: `model_review` de la plantilla se reemplazó por `query_review` (este proyecto no
> entrena modelos ML; los análisis "predictive" son *features* en SQL: RFM, lags, NTILE).

## Hooks

Los hooks **se ejecutan automáticamente** y por eso viven en `.claude/settings.json`
(no en este archivo — un bloque YAML aquí es solo documentación, no se ejecuta).
La configuración real instalada es:

```jsonc
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        // formatea con sqlfluff los .sql editados; no-op si sqlfluff no está instalado
        "hooks": [{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/sql_format.ps1" }]
      }
    ]
  }
}
```

- El hook es **defensivo**: si `sqlfluff` no está instalado, no hace nada y no rompe la edición.
- No se configura ningún hook `PreCommit` que ejecute pruebas: no hay suite de tests
  en un proyecto SQL. La verificación de calidad se hace con `/query_review` y `sqlfluff lint`.

## Convenciones del proyecto

- **Solo lectura** sobre la base de datos: las consultas son `SELECT`/`PRAGMA`/`EXPLAIN`.
  Nunca `INSERT/UPDATE/DELETE/DROP` sobre `data/toys_and_models.sqlite`.
- Consultas organizadas por capa: `01.descriptive` → `02.diagnostic` → `03.analytical`
  → `04.predictive` → `05.structural`.
- Dialecto **SQLite**: fechas con `strftime`, no funciones de MySQL/Postgres.
- Cada módulo mantiene su `README.md` y sus capturas en `img/`.
- Umbrales de calidad centralizados en `configs/thresholds.yaml`.


## End of Session

Before ending a significant work session:

- Summarize completed work.
- Update handoff.md.
- Record pending tasks.
- Record recommended next actions.

