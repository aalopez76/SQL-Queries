# Handoff — sql-analytics-portfolio

> Documento de transferencia del proyecto. Generado: **2026-06-01** · Última actualización: **2026-06-02**.
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
- **Enlaces:**
  - Repositorio: https://github.com/aalopez76/SQL-Queries
  - Presentación pública (página personal): https://aalopez76.github.io/projects/SQL/ — es donde se
    muestra el proyecto a visitantes; el foco es **presentación profesional**, no técnica (ver §11).
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
| Lint / formato | **sqlfluff 4.2.1** (dialect `sqlite`) — instalado; config en `.sqlfluff`; lint en 0 violaciones |
| Host runtime | Python 3.11.9 — **solo** como host de sqlfluff; el proyecto no tiene código Python |
| Gestor de dependencias | **N/A** — no hay `pyproject.toml`/`requirements.txt`; nada que instalar salvo sqlfluff |
| Tracking de experimentos (MLflow) | **N/A** — no se entrenan modelos |
| Versionado de datos (DVC) | **N/A** — el dataset es un `.sqlite` versionado directamente en git (300 KB) |
| Documentación | Markdown — `README.md` raíz + `README.md` por módulo + `docs/data_report.md` |

---

## 2. Current Status

- **Fase:** portafolio **funcional y pulido** en consolidación. No es software en producción;
  no hay despliegue ni servicio. "Producción" aquí = el repositorio público presentable.
- **Último hito:** **sincronizado con GitHub** (2026-06-02). Merge `247df23` integró los 7 commits
  locales (workspace + P0 + P1) con 2 commits remotos (`update queries`, `Delete img/Shema`) y se hizo
  push a `origin/main`. Local y remoto están al día. P1 completada el 2026-06-01 — lint sqlfluff
  (`aea3dfa`), línea base de calidad (`1844966`), review predictivas + fix RFM (`fec4706`), trío
  salesrep (`44133f8`); base del workspace en `03e9cb9`; conciliación README en `0cfd0ed`.
- **Métricas del modelo / umbral de aceptación:** **N/A** — no hay modelo. El equivalente son los
  **umbrales de calidad** en `configs/thresholds.yaml` (máx. % nulos, compatibilidad SQLite, etc.),
  aplicados por las skills.
- **Calidad de datos (verificada el 2026-06-01 con `scripts/validate_db.ps1`):** 8 tablas,
  **0 huérfanos** en las 5 FKs comprobadas. La BD está íntegra.
- **Deuda técnica:** muy baja. Todas las P0 y P1 cerradas. Solo quedan las P2 opcionales
  (CI ligero, snapshots de resultados predictivos) — ver §8.

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
2. ~~**sqlfluff no instalado.**~~ ✅ **Resuelto** (P1.1, 2026-06-01): sqlfluff 4.2.1 instalado, `.sqlfluff`
   configurado, lint en 0 violaciones y hook PostToolUse operativo.
3. ~~**Posible duplicado de consultas** `06_customer_salesrep_map`.~~ ✅ **Resuelto** (P1.4, 2026-06-01):
   no eran duplicados sino tres consultas complementarias; documentadas explícitamente en el README del módulo.
6. **Bug de scoring RFM** (`06_customer_rfm_score`). ✅ **Resuelto** (P1.3, 2026-06-01): las dimensiones
   `NTILE` estaban invertidas; corregido y verificado con datos.
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

**Prioridad media** — ✅ todas completadas (P1)
3. ~~sqlfluff lint + estilo~~ ✅ P1.1 (`aea3dfa`).
4. ~~`/data_validation` → `docs/data_report.md`~~ ✅ P1.2 (`1844966`).
5. ~~`/query_review` de las 8 predictivas~~ ✅ P1.3 (`fec4706`) — incluyó fix del scoring RFM.
6. ~~Resolver `06_customer_salesrep_map(_01/_02)`~~ ✅ P1.4 — documentadas como complementarias.

**Prioridad baja** — infraestructura (únicas pendientes)
7. (Opcional, P2.1) CI ligero: un workflow que ejecute `validate_db` y `sqlfluff lint` en cada push.
8. (Opcional, P2.2) Snapshot de resultados esperados de las consultas predictivas para detección de derivas.

---

## 9. Next Recommended Action

> **Una sola cosa primero:** con todas las P0 y P1 cerradas, el único frente abierto son las P2
> opcionales de infraestructura. Si se quiere seguir, empezar por **P2.1 — CI ligero**: crear
> `.github/workflows/ci.yml` que en cada push ejecute la validación de la BD y el lint:
>
> ```yaml
> # esquema mínimo
> - run: sqlfluff lint queries --dialect sqlite
> - run: pwsh scripts/validate_db.ps1
> ```
>
> Si no, el portafolio ya está en estado presentable: lint limpio, calidad documentada y consultas revisadas.
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

---

## 11. Presentación pública (página personal)

> Página: **https://aalopez76.github.io/projects/SQL/** (no es el repo; es el escaparate del proyecto).
> Objetivo: **presentación profesional**, orientada a reclutadores/clientes — no un volcado técnico.
> El detalle técnico vive en el repo; aquí se cuenta la **historia y el valor**.

### Principio rector
Vender **resultados e impacto de negocio**, no SQL. Un visitante debe entender en 30 segundos *qué
problema se resolvió, qué se descubrió y qué capacidades demuestra*. El código es la prueba, no el
protagonista (se enlaza, no se pega).

### Estructura propuesta para enriquecer la página

1. **Titular + gancho (1 línea).** Ej.: *"Análisis SQL de extremo a extremo de un distribuidor global:
   de la calidad del dato a señales predictivas de negocio."*
2. **Contexto de negocio (2–3 frases).** Toys & Models Co., distribuidor global de modelos a escala;
   122 clientes, 110 productos, 28 países. La pregunta: *¿dónde está el valor y dónde el riesgo?*
3. **Enfoque en 5 capas (narrativa visual).** Descriptiva → Diagnóstica → Analítica → Predictiva →
   Estructural. Una frase por capa; presentarlo como un *framework*, no como una lista de archivos.
4. **Hallazgos clave (lo más vendible — usar números verificados):**
   - **Concentración de ingresos:** ~20 % de los SKUs generan >60 % de los ingresos (portafolio núcleo).
   - **Clientes de alto valor:** *Euro+ Shopping Channel* ($613.986, 20 pedidos) y *Mini Gifts* ($492.684)
     lideran; segmentación **RFM** de los 122 clientes para retención/churn.
   - **Rendimiento comercial:** brecha grande entre reps (top ~$962.660) → oportunidad de reasignar carteras.
   - **Calidad de datos verificada:** 0 huérfanos en 8 relaciones FK, 0 duplicados de PK, 0 negativos indebidos.
   - **Cross-sell:** análisis tipo *market basket* (support/confidence/lift) con cientos de pares de productos.
5. **Capacidades técnicas demostradas (como *badges*, breve):** window functions, CTEs recursivas
   (jerarquía organizativa), RFM y *lags* en SQL puro, NTILE/quartiles, market basket analysis.
6. **Visualizaciones.** Reutilizar las capturas `queries/**/img/*.png` (ya existen) como galería.
7. **Recomendaciones de negocio.** Las 7 del `README.md` (reasignar carteras, foco en países bottom-NTILE,
   priorizar SKUs núcleo, automatizar checks de integridad, usar RFM/lags para retención, vigilar riesgo, cross-sell).
8. **Cierre / CTA.** Enlace al repo (https://github.com/aalopez76/SQL-Queries) y al contacto.

### Notas de tono
- Cifras siempre **verificadas** (provienen de consultas reales — ver `docs/data_report.md` y
  `docs/query_review_predictive.md`). No redondear de forma engañosa.
- Mostrar **1–2 snippets** de SQL como muestra de oficio (p. ej. la CTE recursiva o el RFM), no más.
- Mantener coherencia con el `README.md`, que ya tiene Executive Summary, Insights y Recommendations
  listos para adaptar a un formato visual.

### Estado / pendiente
- **Pendiente (decisión del propietario):** redactar/maquetar el contenido enriquecido en la página.
  Este handoff deja la **propuesta de estructura y los insights verificados**; falta llevarlo al
  HTML/markdown de la página personal (repo aparte, no este).
