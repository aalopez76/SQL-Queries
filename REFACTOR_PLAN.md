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

### [x] P0.2 — Conciliar el README con la BD real ✅ 2026-06-01
**Problema** (`handoff.md` §7.5): el README citaba 326 orders / 2.994 orderdetails / 273 payments;
la BD real tiene 283 / 2.649 / 249. Cifras desactualizadas en un documento de portafolio.
**Resuelto:** sección "Totals" de `README.md` actualizada con los conteos reales (verificados con
`sqlite3`). Las demás cifras coincidían (customers 122, employees 23, products 110, productlines 7,
offices 7). Los insights del Executive Summary son cualitativos/porcentuales y no dependían de los
totales absolutos, por lo que no requirieron cambios. La BD es un subconjunto del classicmodels canónico.

---

## P1 — Calidad (delegable a skills)

### [x] P1.1 — Instalar sqlfluff y pasar el lint ✅ 2026-06-01
**Problema** (`handoff.md` §7.2): lint y hook de formateo inactivos.
**Resuelto:** sqlfluff 4.2.1 instalado; añadido `.sqlfluff` (dialect sqlite, keywords UPPER,
exclusión de `capitalisation.identifiers` por el camelCase del esquema classicmodels).
`sqlfluff fix` aplicó 502 correcciones de formato + se añadieron 43 alias `AS` a mano (regla AL03,
4 archivos de exploración). **Lint final: 0 violaciones.** Las 39 consultas siguen ejecutando sin error.
El hook PostToolUse queda operativo.

### [x] P1.2 — Generar la línea base de calidad de datos ✅ 2026-06-01
**Resuelto:** `docs/data_report.md` poblado con el diagnóstico real (8 tablas, 59 columnas).
Hallazgos: integridad perfecta (0 huérfanos en 8 FKs, 0 duplicados de PK, 0 valores negativos);
nulos > 20 % solo en campos opcionales (addressLine2, state, comments, htmlDescription, image);
22 clientes sin comercial asignado (segmento de negocio, no error). Dictamen: APROBADO con observaciones.

### [x] P1.3 — Revisar las consultas predictivas (las más complejas) ✅ 2026-06-01
**Resuelto:** las 8 consultas de `04.predictive` revisadas; dictámenes archivados en
`docs/query_review_predictive.md`. 7/8 aprobadas directamente. **Bug corregido en
`06_customer_rfm_score`:** las tres dimensiones `NTILE` tenían la dirección invertida (el mejor
cliente recibía el peor score); demostrado con datos y arreglado (mejor cliente Euro+ pasa de
`rfm_score=4` a `15`). Observaciones menores documentadas (05: medias ignoran meses sin venta;
08: comentarios vestigiales a un `aggregations.py` inexistente).

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
