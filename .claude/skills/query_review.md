---
name: query_review
description: Revisa un script .sql del portafolio (corrección, dialecto SQLite, rendimiento, estilo vs configs/thresholds.yaml) y emite un dictamen aprobado / necesita revisión. Reemplaza model_review para este proyecto SQL.
---

# Skill: query_review

Skill de **revisión de consultas SQL** para `sql-analytics-portfolio`.

> Nota: la plantilla original pedía una skill `model_review` (modelos ML, MLflow, DVC).
> Este proyecto **no entrena modelos** — es analítica SQL pura. La capacidad equivalente
> y útil aquí es revisar la **calidad de las consultas**, que es lo que hace esta skill.

## Invocación

```
/query_review <ruta_a_consulta.sql>
```

También admite una carpeta (revisa todos los `.sql` que contenga).

## Objetivo

Evaluar una consulta contra los **umbrales mínimos** definidos en
`configs/thresholds.yaml` (sección `query_quality`) y emitir un dictamen claro:
**aprobado** / **necesita revisión**.

## Procedimiento

### 1. Cargar la consulta y su contexto
- Leer el `.sql`. Identificar a qué capa pertenece (descriptive, diagnostic,
  analytical, predictive, structural) por su ruta.
- Si existe, leer el `README.md` del módulo para entender la intención declarada.

### 2. Corrección (ejecutabilidad)
- Ejecutar la consulta en modo seguro contra la BD del proyecto:
  `sqlite3 data/toys_and_models.sqlite ".read <archivo.sql>"` (o vía `scripts/run_query.ps1`).
- Debe ejecutar sin error y devolver filas coherentes con la intención.
- Verificar que las tablas/columnas referenciadas existen en el esquema.

### 3. Dialecto SQLite
- Confirmar compatibilidad con SQLite: sin sintaxis exclusiva de otros motores
  (`TOP`, `LIMIT n,m` vs `LIMIT/OFFSET`, funciones de fecha propias de MySQL/Postgres).
- Fechas con `strftime(...)`, no `DATE_FORMAT`/`EXTRACT`.

### 4. Rendimiento
- Revisar el plan: `EXPLAIN QUERY PLAN <consulta>`.
- Señalar `SCAN` de tablas grandes sin índice, subconsultas correlacionadas
  evitables, `SELECT *` en agregaciones, joins sin condición.

### 5. Estilo y legibilidad (vs umbrales)
- Comparar con `thresholds.query_quality`: longitud máxima, uso de CTEs en vez de
  subconsultas anidadas profundas, alias explícitos, palabras clave en mayúsculas,
  comentario/cabecera que explique el propósito.
- Si `sqlfluff` está instalado, ejecutarlo: `sqlfluff lint <archivo.sql> --dialect sqlite`.

### 6. Emitir dictamen
Formato de salida:

```markdown
## Revisión: <archivo.sql>
- Corrección:   ✅ / 🔴   (ejecuta y devuelve N filas / error: ...)
- Dialecto:     ✅ / ⚠️    (SQLite-compatible)
- Rendimiento:  ✅ / ⚠️    (plan: ...)
- Estilo:       ✅ / ⚠️    (sqlfluff: X issues / umbrales)

### Hallazgos
1. ...
2. ...

### Dictamen: ✅ APROBADO  |  ⚠️ NECESITA REVISIÓN
```

Criterio: **necesita revisión** si falla la corrección, usa sintaxis no-SQLite,
o incumple un umbral marcado como `blocking: true` en `thresholds.yaml`.

## Reglas
- **Solo lectura** sobre la BD (`SELECT`/`PRAGMA`/`EXPLAIN`). Nunca `INSERT/UPDATE/DELETE/DROP`.
- No reescribir el `.sql` salvo que el usuario lo pida; el dictamen es asesor.
- Basar cada veredicto en una comprobación ejecutada o una regla concreta del YAML.
