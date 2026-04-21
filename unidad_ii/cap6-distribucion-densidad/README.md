<p align="left">
  <img src="Logo_GIEN.png" alt="GIEN - Grupo de Investigación en Ecología Neotropical" width="250">
</p>

# Capítulo 6 — Patrones de distribución y estimación de la densidad

Este capítulo desarrolla dos casos guiados orientados al análisis espacial de poblaciones ecológicas. El primero se centra en la evaluación de patrones de distribución mediante ajustes a distribuciones teóricas e índices de dispersión. El segundo aborda la estimación de la densidad poblacional con métodos basados en distancias.

Incluye:

- evaluación de patrones de distribución espacial
- ajuste a distribuciones de Poisson y Binomial Negativa
- cálculo e interpretación de índices de dispersión
- estimación de densidad mediante los métodos de Holgate, King y Hayne
- generación de tablas y reporte reproducible del capítulo

---

## 📁 Estructura del capítulo

```
cap6-distribucion-densidad/
├── README.md
├── run_cap6.R
├── limpiar_outputs.R
├── reporte_cap6.qmd
├── data/
│   └── raw/
│       └── datos.c6.xlsx
├── outputs/
│   ├── figuras/
│   ├── tablas/
│   └── reportes/
└── R/
    ├── 00_setup.R
    ├── 01_casoA_distribucion.R
    ├── 02_casoB_densidad.R
    ├── 03_funciones_auxiliares.R
    ├── 04_guardar_salidas_cap6.R
    └── 05_render_reporte.R
```

---

## 🧭 Descripción de los scripts

### Preparación

- `R/00_setup.R` — carga paquetes, define rutas de trabajo y verifica la estructura mínima del capítulo
- `R/03_funciones_auxiliares.R` — funciones de guardado: `guardar_figura()`, `guardar_xlsx()`, `guardar_rds()`

### Casos guiados

- `R/01_casoA_distribucion.R` — análisis de patrones de distribución espacial: frecuencias observadas, ajuste a Poisson, ajuste a Binomial Negativa e índices de dispersión
- `R/02_casoB_densidad.R` — estimación de densidad con los métodos de Holgate, King y Hayne

### Salidas y reporte

- `R/04_guardar_salidas_cap6.R` — exporta tablas y objetos consolidados del capítulo 6
- `R/05_render_reporte.R` — renderiza `reporte_cap6.qmd` y mueve el HTML a `outputs/reportes/`
- `run_cap6.R` — ejecuta el capítulo completo de forma secuencial
- `limpiar_outputs.R` — elimina salidas previas y recrea la estructura de `outputs/`

---

## 📊 Datos esperados

Archivo principal:

```
data/raw/datos.c6.xlsx
```

Hojas requeridas:

- `poisson`
- `densidad1`
- `densidad2`

---

## ▶️ Formas de ejecución

### Ejecutar todo el capítulo

```r
source("run_cap6.R")
```

### Ejecutar por casos

```r
source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")
source("R/01_casoA_distribucion.R")
source("R/02_casoB_densidad.R")
source("R/04_guardar_salidas_cap6.R")
source("R/05_render_reporte.R")
```

### Limpiar outputs y empezar desde cero

```r
source("limpiar_outputs.R")
```

---

## 📦 Resultados esperados

Al ejecutar este capítulo se generan:

- tablas en `outputs/tablas/`
- objetos consolidados `.rds` en `outputs/reportes/`
- reporte reproducible HTML en `outputs/reportes/`

> **Nota:** las figuras de este capítulo se renderizan directamente
> en el reporte HTML siguiendo el patrón pedagógico del libro.
> No se exportan como archivos `.png` independientes.

---

## 🧠 Enfoque pedagógico

Este capítulo integra dos perspectivas complementarias del análisis espacial en ecología de poblaciones:

1. **Cómo se distribuyen los individuos en el espacio** — mediante distribuciones teóricas e índices de dispersión
2. **Cómo estimar su densidad** — usando distancias medidas en campo y métodos clásicos de inferencia

Los scripts de casos guiados contienen toda la lógica de análisis visible y explícita, siguiendo fielmente el libro ANVIDEA. Los archivos auxiliares conservan solo funciones de guardado y procesos de exportación.

---

## 🔗 Relación con el libro

Este capítulo corresponde a la **Unidad II — Ecología de poblaciones** del libro ANVIDEA. Complementa el Capítulo 5 (tablas de vida y modelos matriciales) añadiendo la dimensión espacial del análisis poblacional, y sienta las bases para los análisis de comunidades de la Unidad III.
