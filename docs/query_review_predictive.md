# Query Review — capa 04.predictive

> Revisión por la skill `/query_review` · **2026-06-01** · Motor: SQLite 3.51
> Alcance: las 8 consultas de `queries/04.predictive/sql/`.
> Ejes evaluados: corrección (ejecuta), dialecto SQLite, rendimiento (`EXPLAIN QUERY PLAN`),
> estilo (`sqlfluff`, 0 violaciones tras P1.1) y lógica de negocio.

## Resumen de dictámenes

| # | Consulta | Filas | Dictamen |
|---|----------|------:|----------|
| 01 | company_monthly_timeseries | 26 | ✅ APROBADO |
| 02 | product_monthly_timeseries | 2.070 | ✅ APROBADO |
| 03 | product_lag_features | 2.070 | ✅ APROBADO |
| 04 | product_monthly_quartiles | 2.070 | ✅ APROBADO |
| 05 | product_demand_trend_flag | 109 | ✅ APROBADO (con observación) |
| 06 | customer_rfm_score | 122 | ⚠️→✅ **CORREGIDO** (bug de scoring) |
| 07 | customer_next_order_prediction | 97 | ✅ APROBADO |
| 08 | product_cross_sell_pairs | 1.367 | ✅ APROBADO |

**Corrección y estilo:** las 8 ejecutan sin error, son SQLite-compatibles (`STRFTIME`, `JULIANDAY`,
`NTILE`, `LAG/LEAD`, `DATE(..., '+N days')`) y pasan `sqlfluff lint` con 0 violaciones.

**Rendimiento (global):** todas son instantáneas. La BD es pequeña (máx. 2.649 filas en
`orderdetails`), por lo que los `SCAN` de tablas y los `USE TEMP B-TREE` de agregación son baratos;
las uniones por PK usan los autoíndices. No hay índices de usuario, pero no hacen falta a este volumen.

## Hallazgo principal — 06_customer_rfm_score (corregido)

**Problema:** las tres dimensiones usaban `NTILE` con la dirección **invertida** respecto a sus
propios comentarios y a la convención RFM (mejor = 5):

```
NTILE(5) OVER (ORDER BY days_since_last_order ASC)  -- daba 1 al más reciente
NTILE(5) OVER (ORDER BY freq_orders DESC)           -- daba 1 al más frecuente
NTILE(5) OVER (ORDER BY monetary DESC)              -- daba 1 al de mayor gasto
```

**Evidencia (antes):** el mejor cliente, *Euro+ Shopping Channel* (20 pedidos, $613.986), obtenía
`rfm_score = 4` (de los más bajos) y quedaba al final; *Alpha Cognac* (2 pedidos, $48.051) salía
primero con `rfm_score = 13`. El `ORDER BY rfm_score DESC` mostraba a los peores clientes arriba.

**Corrección aplicada:** invertir las tres direcciones; en recency, `DESC NULLS FIRST` para que los
clientes sin pedidos (recency `NULL`) caigan en el peor bucket (1):

```
NTILE(5) OVER (ORDER BY days_since_last_order DESC NULLS FIRST)  -- reciente → 5
NTILE(5) OVER (ORDER BY freq_orders ASC)                        -- más pedidos → 5
NTILE(5) OVER (ORDER BY monetary ASC)                           -- más gasto → 5
```

**Evidencia (después):** *Euro+ Shopping Channel* y *Mini Gifts* obtienen `rfm_score = 15` (r=f=m=5)
y encabezan el ranking; los clientes sin pedidos quedan en `r=f=m=1`.

## Observaciones menores (no bloqueantes)

- **05_product_demand_trend_flag:** `AVG(CASE WHEN months_ago BETWEEN 0 AND 2 THEN totalSales END)`
  promedia solo los meses **con** ventas; un mes sin ventas no genera fila (no cuenta como 0), lo que
  puede sobreestimar la media de productos con ventas esporádicas. Aceptable como señal; documentarlo
  si se usa para decisiones. El caso `INSUFFICIENT_DATA` (growth_rate `NULL`) está bien manejado.
- **08_product_cross_sell_pairs:** el comentario "Rename to match the Pandas/Pages expectations" y
  "Align with aggregations.py" referencian un `aggregations.py` que **no existe** en este repo (vestigio
  de otro proyecto). La lógica SQL es correcta; conviene limpiar esos comentarios. A gran escala, el
  self-join de `OrderProducts` es O(n²) por pedido — irrelevante a este volumen, a vigilar si crece.
- **04_product_monthly_quartiles:** `NTILE(4) ... ORDER BY totalSales` (ascendente) → Q4 = mayores
  ventas del mes. Correcto; convendría explicitar la dirección en un comentario.

## Conclusión

7/8 aprobadas directamente; 1 (RFM) tenía un bug de scoring **demostrado y corregido**. Toda la capa
`04.predictive` queda revisada, ejecutable, SQLite-compatible y con estilo limpio.
