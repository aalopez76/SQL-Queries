# Informe de calidad de datos — toys_and_models.sqlite

> Generado por la skill `/data_validation` · **2026-06-01** · Motor: SQLite 3.51
> Base de datos: `data/toys_and_models.sqlite` · 8 tablas · 59 columnas · 3.450 filas
> Umbrales aplicados: `configs/thresholds.yaml` (`max_null_pct = 0.20`, `low_cardinality_max = 20`)

## Resumen

| Comprobación | Resultado |
|---|---|
| Tablas presentes (vs `expected_tables`) | ✅ 8 / 8 |
| Tablas sin clave primaria | ✅ ninguna |
| Duplicados de PK (customers / orders / products) | ✅ 0 / 0 / 0 |
| Integridad referencial (8 relaciones FK) | ✅ 0 huérfanos |
| Valores negativos indebidos (`forbid_negative_in`) | ✅ 0 |
| Columnas con nulos > 20 % | ⚠️ 7 (todas en campos opcionales) |

**Dictamen global: ✅ APROBADO con observaciones.** La base es estructuralmente íntegra
(sin huérfanos, sin duplicados, sin valores negativos). Las únicas observaciones son nulos en
campos opcionales (direcciones secundarias, comentarios, descripciones HTML/imagen), coherentes
con los *Assumptions & Caveats* del README.

## Conteos por tabla

| Tabla | Filas | Columnas |
|---|---|---|
| customers | 122 | 13 |
| employees | 23 | 8 |
| offices | 7 | 9 |
| orders | 283 | 7 |
| orderdetails | 2.649 | 5 |
| payments | 249 | 4 |
| products | 110 | 9 |
| productlines | 7 | 4 |

## Nulos (solo columnas con nulos > 0)

| Tabla | Columna | % nulos | Nulos | Estado |
|---|---|---:|---:|---|
| customers | addressLine2 | 82.0 % | 100 | 🔴 > umbral — campo opcional |
| customers | state | 59.8 % | 73 | 🔴 > umbral — no aplica a muchos países |
| customers | salesRepEmployeeNumber | 18.0 % | 22 | ⚠️ *missing rep assignments* (insight de negocio) |
| customers | postalCode | 5.7 % | 7 | ✅ bajo |
| employees | reportsTo | 4.3 % | 1 | ✅ esperado (1 = presidente, raíz de la jerarquía) |
| offices | addressLine2 | 28.6 % | 2 | 🔴 > umbral — campo opcional |
| offices | state | 42.9 % | 3 | 🔴 > umbral — no aplica a oficinas no-US |
| orders | shippedDate | 1.8 % | 5 | ✅ pedidos aún no enviados (On Hold/Cancelled) |
| orders | comments | 76.7 % | 217 | 🔴 > umbral — campo libre opcional |
| productlines | htmlDescription | 100 % | 7 | 🔴 columna totalmente vacía |
| productlines | image | 100 % | 7 | 🔴 columna totalmente vacía |

> **Nota:** los 22 nulos de `salesRepEmployeeNumber` confirman la observación del README sobre
> *"missing rep assignments"*. No son huérfanos FK (los 100 asignados sí existen en `employees`),
> sino clientes sin comercial asignado — relevante para análisis de cobertura comercial.

## Cardinalidad de categóricas (low_cardinality_max = 20)

| Tabla | Columna | Distintos | Tipo |
|---|---|---:|---|
| orders | status | 4 | categórica (Shipped, Resolved, Cancelled, On Hold) |
| offices | territory | 4 | categórica |
| employees | jobTitle | 7 | categórica |
| products | productLine | 7 | categórica |
| customers | country | 28 | media |
| productlines | image / htmlDescription | 0 | constante (vacía) |

Identificadores detectados (cardinalidad ≈ nº filas): `customerNumber`, `orderNumber`,
`productCode`, `employeeNumber`, `officeCode` — consistentes con sus claves primarias.

## Valores extremos (columnas numéricas, `iqr_multiplier = 1.5`)

| Columna | Mín | Máx | Media | Negativos |
|---|---:|---:|---:|---:|
| customers.creditLimit | 0 | 227.600 | 67.659,02 | 0 |
| orderdetails.quantityOrdered | 20 | 59 | 34,75 | 0 |
| orderdetails.priceEach | 26,55 | 214,30 | 91,01 | 0 |
| payments.amount | 1.128,20 | 116.208,40 | 31.941,11 | 0 |
| products.buyPrice | 15,91 | 103,42 | 54,40 | 0 |
| products.MSRP | 33,19 | 214,30 | 100,44 | 0 |

> **Observación:** 24 clientes tienen `creditLimit = 0`. No es un error de datos — son cuentas
> sin línea de crédito (típicamente clientes sin comercial asignado). Útil para el análisis de riesgo
> de la capa `02.diagnostic`.

## Integridad referencial

| Relación (hijo → padre) | Huérfanos |
|---|---:|
| orderdetails.orderNumber → orders | ✅ 0 |
| orderdetails.productCode → products | ✅ 0 |
| orders.customerNumber → customers | ✅ 0 |
| payments.customerNumber → customers | ✅ 0 |
| customers.salesRepEmployeeNumber → employees | ✅ 0 |
| employees.reportsTo → employees | ✅ 0 |
| products.productLine → productlines | ✅ 0 |
| employees.officeCode → offices | ✅ 0 |

## Acciones recomendadas

1. **No imputar** las direcciones/estados vacíos: son opcionales por diseño (clientes/oficinas
   internacionales). Documentar como *expected nulls*.
2. Considerar **eliminar** `productlines.htmlDescription` e `productlines.image` (100 % vacías)
   si no se usarán, o marcarlas explícitamente como no pobladas.
3. Tratar los 22 clientes sin `salesRepEmployeeNumber` como **segmento de negocio** (cobertura
   comercial), no como error — alimenta la recomendación nº 1 del README (reasignar carteras).
