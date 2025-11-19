## Descriptive SQL Queries

Este módulo contiene un conjunto de consultas SQL descriptivas diseñadas para explorar y analizar la base comercial toys_and_models.sqlite. Todas las consultas están orientadas al análisis exploratorio de datos (EDA), reporte de KPIs y comprensión del negocio desde diversas perspectivas: tablas, clientes, representantes, países y pedidos.

- Objetivo del módulo

Estas consultas permiten responder preguntas clave como:
- ¿Cuál es la estructura de la base?
- ¿Qué tan grande es cada tabla?
- ¿Cómo se distribuye el crédito entre los clientes?
- ¿Qué países generan más ventas?
- ¿Cuántos clientes tiene cada representante?
- ¿Qué órdenes son más grandes y rentables?
- ¿Cómo aportan los pedidos al total del negocio?


  ### Contenido del directorio
  - 01_table_exploration.sql
    
    Consulta que explora la estructura de la base de datos.
    Incluye:
    - Listado de tablas
    - Revisión de contenido básico
    - Exploración general

  - 02_table_dimensions.sql
    
    Script para obtener las dimensiones de la base:
    - Número de filas por tabla
    - Número de columnas por tabla (via PRAGMA)

  - 03_business_overview.sql
    
    Proporciona indicadores descriptivos clave para entender el tamaño del negocio:
    - Total de clientes
    - Total de productos
    - Total de empleados

  - 04_customer_credit_profile.sql
    
    Analiza el comportamiento de crédito de los clientes:
    - Máximo, mínimo y promedio del credit limit (Exclusión de valores cero9

  - 05_sales_by_country.sql
    
    Reporte completo de ventas por país, incluyendo:
    - Ventas totales
    - Número de pedidos
    - Ventas promedio por cliente
    - Ticket promedio
    - Ranking por volumen de ventas

  - 06_customer_salesrep_map.sql
    
    Relación entre clientes y representantes de ventas.
    Muestra:
    - Clientes sin representante
    - Conteo de clientes por representante
    - Mapa ordenado cliente–representante

  - 07_order_size_unique_products.sql
    
    Reporte detallado de composición de pedidos:
    - Cantidad de productos distintos por pedido
    - Valor total del pedido
    - Total de unidades vendidas
    - Ranking por valor de orden
