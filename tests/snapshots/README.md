# Snapshots de regresión

Estos archivos capturan el **resultado esperado** de las consultas de
`queries/04.predictive/` para **detectar derivas**: si la base de datos o una
consulta cambian, el resultado deja de coincidir con su snapshot y el CI falla.

## Qué hay aquí

- `04.predictive/<consulta>.csv` — salida en CSV de cada consulta predictiva.
  Las filas de datos están **ordenadas de forma canónica** (alfabéticamente) tras
  la cabecera, no en el `ORDER BY` de negocio de la consulta. Esto hace el snapshot
  determinista aunque distintas versiones de `sqlite3` desempaten en orden distinto.
  Son artefactos de regresión, no de presentación.

## Cómo se usan

```powershell
# Verificar (lo que hace el CI). Falla si algún resultado ha derivado:
pwsh scripts/snapshot_predictive.ps1

# Regenerar cuando el cambio sea ESPERADO (p. ej. corregiste una consulta
# o actualizaste la BD a propósito):
pwsh scripts/snapshot_predictive.ps1 -Update
```

## Cuándo regenerar

Solo cuando el cambio de resultado sea **intencionado**. Si el CI marca una deriva
inesperada, investiga antes de regenerar: puede ser un cambio accidental en una
consulta o en `data/toys_and_models.sqlite`.
