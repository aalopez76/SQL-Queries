# REFACTOR_PLAN — sql-analytics-portfolio

> Roadmap de mejora priorizado. Generado: **2026-06-01**.
> Fuentes: `AUDIT.md` (diagnóstico) y `handoff.md` §7–§8 (issues y pendientes).
> Convención de estado: `[ ]` pendiente · `[~]` en curso · `[x]` hecho.
> Todos los comandos se ejecutan **desde la raíz** en **PowerShell (Windows)**.

---

## P0 — Bloqueantes (hacer primero)

### [x] P0.1 — Cerrar la reorganización de carpetas en git ✅ 2026-06-01
**Problema** (`handoff.md` §7.1): las carpetas antiguas figuraban como *deleted* y las nuevas
(`queries/01.descriptive/`…) como *untracked*. El renombrado no estaba commiteado y git no lo veía como *rename*.
**Resuelto:** commit `03e9cb9` — git detectó los 78 movimientos como *renames* al 100 %
(incluido el typo `revenu`→`revenue` en `.sql` y `.png`). Working tree limpio.

### [ ] P0.2 — Conciliar el README con la BD real
**Problema** (`handoff.md` §7.5): el README cita 326 orders / 2.994 orderdetails; la BD real tiene
283 orders / 2.649 orderdetails. Cifras desactualizadas en un documento de portafolio.
**Acción**
```powershell
pwsh scripts/validate_db.ps1     # obtener los conteos reales por tabla
```
Actualizar la sección "Totals" de `README.md` con esos números. Revisar si algún insight del
Executive Summary dependía de los totales antiguos.
**Hecho cuando:** los totales del README coinciden con la salida de `validate_db.ps1`.

---

## P1 — Calidad (delegable a skills)

### [ ] P1.1 — Instalar sqlfluff y pasar el lint
**Problema** (`handoff.md` §7.2): lint y hook de formateo inactivos.
**Acción**
```powershell
pip install sqlfluff
sqlfluff lint queries --dialect sqlite
sqlfluff fix  queries --dialect sqlite   # revisar el diff antes de aceptar
```
**Hecho cuando:** `sqlfluff lint` no reporta errores bloqueantes y el hook PostToolUse queda operativo.

### [ ] P1.2 — Generar la línea base de calidad de datos
**Acción:** invocar la skill
```
/data_validation data/toys_and_models.sqlite
```
**Hecho cuando:** `docs/data_report.md` contiene esquema, nulos, cardinalidad e integridad reales.

### [ ] P1.3 — Revisar las consultas predictivas (las más complejas)
**Acción:** pasar la skill `/query_review` por las 8 consultas de `queries/04.predictive/sql/`
y archivar los dictámenes. Empezar por:
```
/query_review queries/04.predictive/sql/06_customer_rfm_score.sql
/query_review queries/04.predictive/sql/07_customer_next_order_prediction.sql
```
**Hecho cuando:** las 8 consultas tienen dictamen *APROBADO* o sus hallazgos corregidos.

### [ ] P1.4 — Resolver el duplicado customer_salesrep_map
**Problema** (`handoff.md` §7.3): `06_customer_salesrep_map.sql` coexiste con `_01` y `_02` en
`queries/01.descriptive/sql/`.
**Acción:** decidir si los tres son necesarios; si `_01/_02` son iteraciones, consolidar y eliminar.
**Hecho cuando:** no hay consultas redundantes sin justificación documentada en el README del módulo.

---

## P2 — Infraestructura (opcional, mejora a futuro)

### [ ] P2.1 — CI ligero
Workflow `.github/workflows/ci.yml` que en cada push ejecute `validate_db` y `sqlfluff lint`.
**Hecho cuando:** el push dispara la verificación y falla si hay huérfanos o errores de lint.

### [ ] P2.2 — Snapshot de resultados predictivos
Guardar salidas esperadas de las consultas de `04.predictive` para detectar derivas si la BD cambia.
**Hecho cuando:** existe un mecanismo de comparación (golden files) para esas consultas.

---

## Mantenimiento de este archivo
Al cerrar una tarea, marca `[x]` y refleja el cambio en `handoff.md` (§2 Current Status y §8 Pending),
tal como exige `CLAUDE.md` ("Keep handoff.md Updated"). Cuando todas las P0/P1 estén `[x]`,
este plan puede archivarse o reescribirse con el siguiente ciclo de mejoras.
