# AUDIT.md — Auditoría del proyecto

> Fecha: 2026-06-01 · Rama: `main` · Tipo: **proyecto existente** (no es nuevo)

## 1. Resumen ejecutivo

Este es un proyecto de **analítica 100 % SQL** sobre una base de datos SQLite
(`data/toys_and_models.sqlite`, el clásico esquema *classicmodels*). **No contiene
código Python, ni modelos de machine learning, ni pipeline de entrenamiento.**
El trabajo consiste en consultas SQL organizadas por capas analíticas, con capturas
de resultados (`.png`) y `README.md` por módulo.

## 2. Stack real detectado

| Área | Realidad del repo |
|------|-------------------|
| Lenguaje | SQL (dialecto **SQLite**: `UNION ALL`, CTEs, window functions, recursivas) |
| Motor | SQLite — fichero único `data/toys_and_models.sqlite` |
| ML / entrenamiento | **Ninguno** (los análisis "predictivos" son *features* en SQL: RFM, lags, NTILE) |
| Gestor de dependencias | **Ninguno** (no hay `pyproject.toml`, `requirements.txt`, `package.json`) |
| Tracking / versionado de datos | **Ninguno** (no hay DVC ni MLflow) |
| Documentación | `README.md` raíz muy completo + `README.md` por módulo |
| Visualización | Capturas PNG por consulta |

## 3. Estructura

```
data/toys_and_models.sqlite      # BD SQLite (classicmodels)
img/toys_and_models-db.png       # diagrama del esquema
queries/
  01.descriptive/   (+ data_quality/)   9 SQL + 6 checks
  02.diagnostic/                         4 SQL
  03.analytical/                         8 SQL
  04.predictive/                         8 SQL
  05.structural/                         4 SQL
README.md  LICENSE  .gitignore
```

Esquema de datos: 8 tablas (customers, employees, offices, orders, orderdetails,
payments, products, productlines) · 122 clientes · 283 pedidos · 2.649 líneas.

## 4. Hallazgos relevantes

1. **Reorganización a medias (acción requerida).** Las carpetas `queries/<categoría>/`
   figuran como **borradas** en el working tree y existen copias nuevas con prefijo
   numérico (`queries/01.descriptive/`, `02.diagnostic/`, …) **sin rastrear** por git.
   El renombrado se hizo en disco pero **no se ha hecho `git add`/`commit`**. Git aún
   no detecta los movimientos como *renames*.
2. **Carpeta `.sql/` oculta.** Los scripts viven en subcarpetas `.sql/` (con punto
   inicial → ocultas). Es inusual y puede confundir herramientas y al propio usuario.
3. **Nombre con typo:** `08_salesrep_rank_by_revenu.sql` (falta la `e` final de *revenue*).
4. **Posible duplicado:** `06_customer_salesrep_map` existe como base, `_01` y `_02`.
5. **`.gitignore` prácticamente vacío** (1 línea) — el binario `.sqlite` está versionado.
6. **No hay forma reproducible de ejecutar las consultas** (ni script ni runner).

## 5. Desalineación con la plantilla solicitada ⚠️

La plantilla de configuración pedida asume un proyecto de **ML en Python**
(poetry, scikit-learn, MLflow, DVC, `make train/evaluate`, hooks `ruff`/`black`,
skill `model_review` sobre modelos entrenados). **Nada de eso aplica a un proyecto
SQL/SQLite.** Aplicarla tal cual crearía configuración muerta (comandos que no
existen, hooks que fallan, una skill de revisión de modelos sin modelos).

**Recomendación:** adaptar la "fábrica" de Claude Code al stack real:
- `data_validation` → validar el esquema/integridad del **SQLite** (nulos, FKs, cardinalidad).
- `model_review` → reemplazar por `query_review` (revisión de SQL: corrección, rendimiento, estilo, dialecto SQLite).
- Hooks → formateo/lint de **SQL** (p. ej. `sqlfluff`) en lugar de `ruff`/`black`.
- Comandos → un runner real de SQLite, no `make train`.

Esta decisión se confirma en la Fase 1.
