---
name: data_validation
description: Valida el esquema y la integridad de una base de datos SQLite (nulos, FKs, cardinalidad de categóricas, valores extremos) y genera un informe en docs/data_report.md.
---

# Skill: data_validation

Skill reutilizable de **validación de datos** para el portafolio `sql-analytics-portfolio`.
Trabaja sobre la base de datos **SQLite** del proyecto (por defecto `data/toys_and_models.sqlite`).

## Invocación

```
/data_validation <ruta_a_la_bd.sqlite>
```

Si no se pasa ruta, usar `data/toys_and_models.sqlite`.

## Objetivo

Producir un diagnóstico reproducible de la calidad e integridad de los datos y
escribir un informe legible en `docs/data_report.md`. Los umbrales de aceptación
se leen de `configs/thresholds.yaml` (sección `data_quality`).

## Procedimiento

### 1. Cargar el dataset y descubrir el esquema
- Verificar que el fichero existe. Si no, detener y avisar.
- Listar tablas: `SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;`
- Para cada tabla, obtener columnas y tipos con `PRAGMA table_info(<tabla>);`
  y el conteo de filas con `SELECT COUNT(*) FROM <tabla>;`.

### 2. Comprobar esquema (columnas y tipos)
- Para cada tabla, registrar columna, tipo declarado, `notnull`, `pk`.
- Señalar columnas sin tipo declarado o tablas sin clave primaria.

### 3. Reportar nulos
- Para cada columna: `SELECT COUNT(*) - COUNT(<col>) AS nulos FROM <tabla>;`
- Calcular `% nulos = nulos / total`. Marcar 🔴 si supera `thresholds.max_null_pct`.

### 4. Reportar cardinalidad de categóricas
- Para columnas de tipo texto / con pocos valores: `SELECT COUNT(DISTINCT <col>) FROM <tabla>;`
- Clasificar: constante (1), baja-cardinalidad (≤ `thresholds.low_cardinality_max`),
  alta-cardinalidad, o probable identificador (cardinalidad ≈ nº filas).

### 5. Reportar valores extremos (numéricas)
- Para columnas numéricas relevantes (p. ej. `creditLimit`, `quantityOrdered`,
  `priceEach`, `amount`): `MIN`, `MAX`, `AVG`, y outliers por regla de cuartiles
  (valores fuera de `[Q1 - 1.5·IQR, Q3 + 1.5·IQR]`, calculable con `NTILE`/percentiles en SQL).
- Marcar valores negativos donde no deban existir (precios, cantidades, créditos).

### 6. Integridad referencial (FKs del esquema classicmodels)
Verificar huérfanos en las relaciones conocidas:
- `orderdetails.orderNumber` → `orders.orderNumber`
- `orderdetails.productCode` → `products.productCode`
- `orders.customerNumber` → `customers.customerNumber`
- `payments.customerNumber` → `customers.customerNumber`
- `customers.salesRepEmployeeNumber` → `employees.employeeNumber`
- `employees.reportsTo` → `employees.employeeNumber`
- `products.productLine` → `productlines.productLine`
- `employees.officeCode` → `offices.officeCode`

Patrón: `SELECT COUNT(*) FROM hijo h LEFT JOIN padre p ON h.fk = p.pk WHERE p.pk IS NULL AND h.fk IS NOT NULL;`

### 7. Generar el informe `docs/data_report.md`
Estructura sugerida:

```markdown
# Informe de calidad de datos — <bd>
> Generado: <fecha> · Tablas: N · Filas totales: M

## Resumen
| Comprobación | Resultado |
|---|---|
| Tablas sin PK | ... |
| Columnas con nulos > umbral | ... |
| FKs con huérfanos | ... |
| Valores negativos indebidos | ... |

## Detalle por tabla
... (esquema, nulos %, cardinalidad)

## Integridad referencial
... (cada FK con nº de huérfanos)

## Dictamen
✅ OK  /  ⚠️ Con observaciones  /  🔴 Problemas críticos
```

## Cómo ejecutar las consultas
Usar el binario `sqlite3` o el script `scripts/validate_db.ps1`:

```powershell
sqlite3 data/toys_and_models.sqlite "PRAGMA table_info(customers);"
pwsh scripts/validate_db.ps1 -Db data/toys_and_models.sqlite
```

## Reglas
- **Solo lectura**: nunca modificar la base de datos. Usar únicamente `SELECT`/`PRAGMA`.
- No inventar cifras: toda métrica del informe debe provenir de una consulta ejecutada.
- Si una tabla/columna esperada no existe, anotarlo en el informe en vez de fallar.
