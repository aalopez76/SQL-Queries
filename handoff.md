# Handoff — sql-analytics-portfolio

> Documento de transferencia del proyecto. Generado: **2026-06-01**.
> Autor saliente: Senior Data Scientist (sesión Claude Code). Para: colega entrante / futura instancia de Claude Code.
>
> ⚠️ **Lee esto primero.** La plantilla de handoff asumía un proyecto **ML en Python** (DVC, MLflow,
> Makefile, `src/`, `tests/`, CI). **Este proyecto NO es eso.** Es un **portafolio de analítica 100 % SQL
> sobre SQLite**. Donde una sección no aplica, lo digo explícitamente como `N/A` con la razón — no hay
> nada oculto ni pendiente de descubrir en esos frentes. La fuente de verdad operativa es `CLAUDE.md`
> y la auditoría inicial es `AUDIT.md` (ambos en la raíz).

---

## 1. Project Overview

- **Nombre:** `sql-analytics-portfolio`
- **Propietario:** aalopez (git user) · aalpzp@gmail.com
- **Problema de negocio:** analizar el desempeño operativo, comercial y organizativo de
  *Toys & Models Co.*, distribuidor global de modelos a escala coleccionables (esquema *classicmodels*).
- **Objetivo:** construir un portafolio de analítica SQL **multi-capa** de calidad profesional
  (descriptiva → diagnóstica → analítica → predictiva → estructural), presentable a reclutadores/clientes.
- **KPIs analizados** (no son KPIs de un modelo, son los del negocio que las consultas iluminan):
  concentración de ventas por producto/cliente, ingresos por país/región, estacionalidad de demanda,
  carga de trabajo de comerciales, integridad/calidad de datos, cobertura territorial.
- **Naturaleza "predictiva":** las consultas de `04.predictive` generan *features* en SQL
  (RFM, lags, NTILE, cross-sell), **no entrenan modelos**. No hay predicciones de ML.

### Stack tecnológico exacto

| Componente | Realidad |
|---|---|
| Lenguaje | **SQL** (dialecto **SQLite**: CTEs, window functions, recursivas, `strftime`) |
| Motor / datos | **SQLite 3.51** — fichero único `data/toys_and_models.sqlite` (~300 KB) |
| Runner | binario `sqlite3` CLI (verificado: v3.51.0) |
| Lint / formato | **sqlfluff** (dialect `sqlite`) — *opcional*, requiere `pip install sqlfluff` (**NO instalado** aún) |
| Host runtime | Python 3.11.9 — **solo** como host de sqlfluff; el proyecto no tiene código Python |
| Gestor de dependencias | **N/A** — no hay `pyproject.toml`/`requirements.txt`; nada que instalar salvo sqlfluff |
| Tracking de experimentos (MLflow) | **N/A** — no se entrenan modelos |
| Versionado de datos (DVC) | **N/A** — el dataset es un `.sqlite` versionado directamente en git (300 KB) |
| Documentación | Markdown — `README.md` raíz + `README.md` por módulo + `docs/data_report.md` |

---

## 2. Current Status

- **Fase:** portafolio **funcional y pulido** en consolidación. No es software en producción;
  no hay despliegue ni servicio. "Producción" aquí = el repositorio público presentable.
- **Último hito (commit):** `03e9cb9` — *"Reorganizar queries por capa numerada y añadir workspace
  de Claude Code"* — **2026-06-01**. Incluye la reorganización (78 renames), la "fábrica" de Claude Code
  y las correcciones de auditoría. (Commit previo: `c4d86cf` — *"update files"* — 2025-12-18.)
- **Métricas del modelo / umbral de aceptación:** **N/A** — no hay modelo. El equivalente son los
  **umbrales de calidad** en `configs/thresholds.yaml` (máx. % nulos, compatibilidad SQLite, etc.),
  aplicados por las skills.
- **Calidad de datos (verificada el 2026-06-01 con `scripts/validate_db.ps1`):** 8 tablas,
  **0 huérfanos** en las 5 FKs comprobadas. La BD está íntegra.
- **Deuda técnica:** baja. Reorganización git cerrada (`03e9cb9`) y totales del README conciliados (P0.2).
  Pendiente principal: sqlfluff sin instalar (hook/lint inactivos hasta entonces) — ver §7.

---

## 3. Completed Work

### Consultas SQL (contenido analítico — preexistente)
| Capa | Carpeta | Nº de `.sql` | Contenido |
|---|---|---|---|
| Descriptiva | `queries/01.descriptive/` | 15 | exploración, KPIs, perfil de crédito + `data_quality/` (nulos, duplicados, 4 checks FK) |
| Diagnóstica | `queries/02.diagnostic/` | 4 | anomalías de crédito geográfico, outliers, ratio crédito/ventas, clientes de riesgo |
| Analítica | `queries/03.analytical/` | 8 | deep-dives país/región/producto/cliente/comercial, tendencias MoM, ranking |
| Predictiva | `queries/04.predictive/` | 8 | RFM, lags, quartiles mensuales, flag de tendencia, next-order, cross-sell |
| Estructural | `queries/05.structural/` | 4 | jerarquía recursiva de empleados, mapa manager, estructura de oficinas, cobertura |

**Total: 39 consultas**, cada módulo con su `README.md` y capturas en `img/`.

### Configuración de Claude Code instalada esta sesión ("la fábrica")
- **Skills** (`.claude/skills/`):
  - `data_validation.md` — valida esquema/integridad del SQLite → `docs/data_report.md`.
  - `query_review.md` — revisa un `.sql` (corrección, dialecto, rendimiento, estilo) → dictamen.
    *(Reemplaza la `model_review` de la plantilla, que no aplica sin modelos.)*
- **Hooks** (`.claude/settings.json` + `.claude/hooks/sql_format.ps1`): `PostToolUse` sobre `Write|Edit`
  que auto-formatea `.sql` con sqlfluff. **Defensivo:** no-op si sqlfluff no está instalado.
- **`CLAUDE.md`** — single source of truth (stack, comandos, hooks, skills, convenciones).
- **`configs/thresholds.yaml`** — umbrales de calidad para datos y consultas.
- **Scripts** (`scripts/`): `run_query.ps1` (runner read-only), `validate_db.ps1` (validador rápido).
- **`AUDIT.md`** — auditoría inicial del repo.
- **`.gitignore`** ampliado, **`README.md`** con sección de reproducibilidad.

### Correcciones de auditoría aplicadas
- Typo `08_salesrep_rank_by_revenu.sql` → `...revenue.sql`.
- Carpetas ocultas `queries/**/.sql/` → `queries/**/sql/` (las 5 capas).
- Bug PowerShell: parámetro `-Db` colisionaba con alias de `-Debug` → renombrado a `-Database`.

### Pipelines automatizados (Makefile, CI)
**N/A** — no hay Makefile ni `.github/workflows/`. La "automatización" son los scripts PowerShell
y el hook de formateo. CI no se ha configurado (no es necesario para un portafolio SQL estático;
si se desea, ver §8).

### Sub-agentes definidos
**Ninguno** específico del proyecto. Se puede delegar exploración a los agentes genéricos de Claude Code,
pero no se ha definido ningún sub-agente custom.

---

## 4. Architecture

### Flujo de datos (no hay flujo de "entrenamiento")

```
                        data/toys_and_models.sqlite   (SQLite, esquema classicmodels)
                                     │  (solo lectura: SELECT / PRAGMA / EXPLAIN)
                                     ▼
        ┌────────────────────────────────────────────────────────────┐
        │  queries/  — 5 capas analíticas, ejecutadas con sqlite3     │
        │                                                            │
        │  01.descriptive ─► 02.diagnostic ─► 03.analytical          │
        │            ─► 04.predictive ─► 05.structural               │
        └────────────────────────────────────────────────────────────┘
             │                          │                      │
             ▼                          ▼                      ▼
   scripts/run_query.ps1     scripts/validate_db.ps1    img/*.png (resultados)
   (ejecuta una consulta)    (integridad + conteos)     + README.md por módulo
             │                          │
             ▼                          ▼
   /query_review <sql>        /data_validation <bd> ─► docs/data_report.md
   (skill: dictamen)          (skill: informe de calidad)
```

### Estructura de carpetas comentada

```
sql-analytics-portfolio/
├─ data/
│   └─ toys_and_models.sqlite   # ÚNICA fuente de datos. Versionada en git (300 KB). SOLO LECTURA.
├─ queries/                     # Corazón del proyecto: las 39 consultas, agrupadas por capa analítica.
│   ├─ 01.descriptive/
│   │   ├─ sql/                 #   scripts .sql de exploración/KPIs (antes carpeta oculta ".sql")
│   │   ├─ data_quality/        #   checks de nulos, duplicados e integridad FK
│   │   ├─ img/                 #   capturas de resultados
│   │   └─ README.md            #   narrativa del módulo
│   ├─ 02.diagnostic/  03.analytical/  04.predictive/  05.structural/   (misma estructura sql/ + img/)
├─ scripts/                     # Automatización en PowerShell (Windows).
│   ├─ run_query.ps1            #   ejecuta un .sql contra la BD en modo -readonly
│   └─ validate_db.ps1          #   conteos por tabla + comprobación de FKs huérfanas
├─ configs/
│   └─ thresholds.yaml          # Umbrales de calidad que consumen las skills (datos + consultas).
├─ docs/
│   └─ data_report.md           # Informe de calidad (lo genera la skill /data_validation).
├─ img/
│   └─ toys_and_models-db.png   # Diagrama del esquema de la BD.
├─ .claude/                     # "Fábrica" de Claude Code.
│   ├─ skills/                  #   data_validation.md, query_review.md
│   ├─ hooks/sql_format.ps1     #   formateo SQL post-edición (defensivo)
│   └─ settings.json            #   registro del hook PostToolUse
├─ CLAUDE.md                    # Single source of truth (stack, comandos, hooks, skills).
├─ AUDIT.md                     # Auditoría inicial del repositorio.
├─ handoff.md                   # ESTE documento.
├─ README.md                    # Narrativa ejecutiva + sección de reproducibilidad.
└─ .gitignore
```

### Justificación de decisiones

- **¿Por qué SQLite y SQL puro?** El objetivo es demostrar dominio de SQL avanzado (window functions,
  CTEs recursivas, RFM/lags en SQL). SQLite da una BD portable de un fichero, sin servidor, ideal
  para un portafolio reproducible en cualquier máquina.
- **¿Por qué NO Python/DVC/MLflow?** No hay entrenamiento de modelos. Añadir ese stack sería
  configuración muerta. Se sustituyó conscientemente: `model_review`→`query_review`, `ruff/black`→`sqlfluff`,
  `make train`→scripts PowerShell. Detalle en `AUDIT.md` §5.
- **¿Por qué la separación en 5 capas numeradas?** Refleja el framework analítico estándar
  (qué pasó → por qué → análisis profundo → qué podría pasar → cómo se organiza) y fuerza un orden
  de lectura claro para quien revisa el portafolio.
- **¿Por qué `-readonly` en el runner?** Garantía dura de que ninguna consulta del portafolio
  pueda mutar el dataset de referencia.

---

## 5. Tooling

> Todos los comandos se ejecutan **desde la raíz del proyecto** en **PowerShell (Windows)**.

### Activar el entorno
No hay entorno virtual obligatorio. Requisitos:
```powershell
sqlite3 --version          # debe ser 3.51+  (ya disponible)
# Opcional, para lint/formato y para activar el hook:
pip install sqlfluff
```

### Comandos disponibles (sustituyen al Makefile inexistente)
```powershell
# Validar la BD (tablas, conteos, FKs huérfanas)
pwsh scripts/validate_db.ps1

# Ejecutar una consulta concreta (solo lectura)
pwsh scripts/run_query.ps1 -Query queries/01.descriptive/sql/03_business_overview.sql

# (con BD explícita)
pwsh scripts/run_query.ps1 -Query queries/03.analytical/sql/08_salesrep_rank_by_revenue.sql -Database data/toys_and_models.sqlite

# Lint / formato SQL (requiere sqlfluff)
sqlfluff lint queries --dialect sqlite
sqlfluff fix  queries --dialect sqlite
```

### Comandos / skills de Claude Code
| Invocación | Qué hace |
|---|---|
| `/data_validation data/toys_and_models.sqlite` | Genera informe de calidad en `docs/data_report.md` |
| `/query_review queries/03.analytical/sql/02_products_deep_agg.sql` | Revisa una consulta y emite dictamen aprobado/necesita revisión |

> No existen `/train`, `/evaluate`, `/model_review` — eran de la plantilla ML y **no aplican** aquí.

### Hooks configurados
- **`PostToolUse` (Write|Edit)** → `.claude/hooks/sql_format.ps1`: tras escribir/editar un `.sql`,
  lo formatea con sqlfluff. **No hace nada si sqlfluff no está instalado** (no rompe la edición).
- **Pre-commit:** **N/A** — no hay `.pre-commit-config.yaml`. La verificación de calidad es manual
  vía `/query_review` y `sqlfluff lint`.

### MLflow / DVC
- **MLflow UI:** **N/A** (sin experimentos). No ejecutar `mlflow ui` — no hay `mlruns/`.
- **DVC:** **N/A** (sin pipelines de datos). No ejecutar `dvc pull/repro` — no hay `.dvc/`.

---

## 6. Test Coverage

- **Cobertura medida:** **N/A** — no hay framework de tests (no `tests/`, no pytest), porque no hay
  código de aplicación que testear.
- **Lo que hace de "tests" en este proyecto:**
  - `scripts/validate_db.ps1` → comprobaciones de integridad referencial (5 FKs) y conteos.
    Última ejecución (2026-06-01): **0 huérfanos**, 8 tablas presentes. ✅
  - `queries/01.descriptive/data_quality/` → 6 consultas de calidad (nulos, duplicados, 4 FK checks).
  - `/query_review` → "test" de cada consulta: ejecutabilidad + dialecto + estilo.
- **Cómo ejecutar las verificaciones:**
  ```powershell
  pwsh scripts/validate_db.ps1
  pwsh scripts/run_query.ps1 -Query queries/01.descriptive/data_quality/01_null_checks.sql
  ```
- **Puntos débiles no cubiertos:**
  - No hay verificación **automatizada en CI** (todo es manual / bajo demanda).
  - Las consultas `04.predictive` no tienen aserciones de regresión (si la BD cambiara, no hay
    snapshot que detecte derivas en los resultados).
  - El hook de formateo no valida semántica, solo estilo.

---

## 7. Known Issues

1. ~~**Reorganización git a medio cerrar.**~~ ✅ **Resuelto** en commit `03e9cb9` (2026-06-01):
   git registró los 78 movimientos como *renames* al 100 %. Working tree limpio.
2. **sqlfluff no instalado (principal pendiente).** El lint y el hook de formateo están inactivos hasta `pip install sqlfluff`.
   No es un bug — es un requisito opcional pendiente.
3. **Posible duplicado de consultas:** `06_customer_salesrep_map.sql` coexiste con `_01` y `_02`
   en `01.descriptive/sql/`. Revisar si los tres son necesarios o si `_01/_02` son iteraciones.
4. **El binario `.sqlite` está versionado en git.** Aceptable por su tamaño (300 KB) y por ser el
   dataset de referencia de un portafolio, pero implica que cualquier cambio de datos ensucia el diff.
5. ~~**Conteos del dataset desactualizados.**~~ ✅ **Resuelto** (P0.2, 2026-06-01): los totales del
   README se conciliaron con la BD real — orders 326→283, order details 2.994→2.649, payments 273→249
   (customers, employees, products, productlines y offices ya coincidían). Esta BD es un **subconjunto**
   del classicmodels canónico, de ahí la diferencia.

---

## 8. Pending Tasks

> No existen `docs/REFACTOR_PLAN.md` ni `docs/TODO.md`. Esta lista se deriva de `AUDIT.md` y del estado real.

**Prioridad alta** — ✅ todas completadas
1. ~~**Cerrar la reorganización en git**~~ ✅ Hecho (commit `03e9cb9`, 2026-06-01).
2. ~~**Conciliar el README con la BD real**~~ ✅ Hecho (P0.2, 2026-06-01). Siguiente frente: las P1 (calidad).

**Prioridad media** — delegables a skills
3. `pip install sqlfluff` y ejecutar `sqlfluff lint queries --dialect sqlite`; corregir estilo.
4. Correr **`/data_validation data/toys_and_models.sqlite`** para poblar `docs/data_report.md`.
5. Pasar **`/query_review`** por las 8 consultas de `04.predictive` (las más complejas) y archivar dictámenes.
6. Resolver el duplicado `06_customer_salesrep_map(_01/_02)` (§7.3).

**Prioridad baja** — infraestructura
7. (Opcional) CI ligero: un workflow que ejecute `validate_db` y `sqlfluff lint` en cada push.
8. (Opcional) Snapshot de resultados esperados de las consultas predictivas para detección de derivas.

---

## 9. Next Recommended Action

> **Una sola cosa primero:** poblar el informe de calidad como línea base verificable.
>
> ```
> /data_validation data/toys_and_models.sqlite
> ```
>
> Genera `docs/data_report.md` con esquema, nulos, cardinalidad e integridad reales. Es read-only
> y te da el estado objetivo de los datos. A partir de ahí, las P1 de calidad (§8): instalar sqlfluff
> y pasar el lint (P1.1), y revisar las consultas predictivas con `/query_review` (P1.3).
>
> _(Las dos P0 ya están cerradas: reorganización git `03e9cb9` y conciliación del README P0.2.)_

---

## 10. Notes For Future Sessions

### Lecciones aprendidas
- **La plantilla ≠ el proyecto.** La configuración inicial pedía un stack ML/Python que no encajaba.
  La decisión correcta fue **adaptar, no imponer**: cada pieza ML se sustituyó por su equivalente SQL
  útil. Si en el futuro alguien vuelve a pedir "configura como ML", confróntalo con `AUDIT.md §5`.
- **Bug PowerShell recurrente:** nunca nombrar un parámetro `-Db` (colisiona con el alias de `-Debug`).
  Usar `-Database`. Vale para cualquier script `.ps1` nuevo.

### Reglas de negocio / del proyecto importantes
- **La BD es SOLO LECTURA.** Toda consulta usa `SELECT`/`PRAGMA`/`EXPLAIN`. El runner fuerza `-readonly`.
  Nunca `INSERT/UPDATE/DELETE/DROP` sobre `data/toys_and_models.sqlite`.
- **Dialecto SQLite estricto:** fechas con `strftime`, no `DATE_FORMAT`/`EXTRACT`; paginación con
  `LIMIT/OFFSET`; nada de `TOP`.
- **Ingresos** se calculan como `quantityOrdered * priceEach` (métrica autoritativa del proyecto).
- **No inventar cifras:** todo número en un informe debe venir de una consulta ejecutada (regla de las skills).

### Cómo trabajar con Claude Code en este proyecto
- Empieza siempre leyendo `CLAUDE.md` (single source of truth) y `AUDIT.md`.
- Para entender el estado de los datos: skill **`/data_validation`**.
- Para revisar/mejorar una consulta antes de darla por buena: skill **`/query_review`**.
- Para búsquedas amplias por el repo, delega en los agentes de exploración genéricos; **no hay
  sub-agentes custom** que invocar.
- Pide confirmación antes de operaciones git destructivas o de instalar dependencias.

### Ubicación de credenciales
- **No hay credenciales, secretos ni `.env`.** El proyecto es totalmente local: una BD SQLite de
  fichero sin autenticación. Si en el futuro se añade una fuente remota, usar `.env` (referenciado,
  nunca commiteado) o un gestor de secretos — jamás en texto plano en el repo.
