<p align="left">
  <img src="Logo_GIEN.png" alt="GIEN - Grupo de Investigación en Ecología Neotropical" width="250">
</p>

# 📈 Capítulo 4 — Modelos de crecimiento poblacional

Este capítulo introduce los fundamentos cuantitativos de la dinámica poblacional mediante modelos matemáticos clásicos. A través de simulaciones y visualizaciones reproducibles, el lector explora cómo cambian las poblaciones en el tiempo bajo distintos supuestos ecológicos.

---

## 🎯 Propósito

Desarrollar competencias para:

- interpretar el crecimiento exponencial continuo y discreto
- estimar e interpretar los parámetros **r** y **λ**
- comprender el papel de la capacidad de carga (**K**)
- analizar el crecimiento logístico y sus equilibrios
- relacionar modelos matemáticos con procesos ecológicos reales

---

## 🧠 Enfoque pedagógico

A diferencia de otros capítulos basados en bases de datos empíricas, aquí se trabaja con **modelos de simulación**. Esto permite comprender la lógica de los procesos poblacionales antes de abordar estructuras demográficas más complejas en el capítulo siguiente.

La progresión del capítulo sigue tres niveles:

1. **Cambio en el tiempo** → crecimiento exponencial continuo
2. **Cambio por generaciones** → crecimiento exponencial discreto
3. **Restricción ambiental y regulación** → crecimiento logístico

---

## 📁 Estructura del capítulo

```
cap4-modelos-poblacionales/
├── README.md
├── run_cap4.R
├── limpiar_outputs.R
├── reporte_cap4.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_modelo_exponencial_continuo.R
│   ├── 02_modelo_exponencial_discreto.R
│   ├── 03_modelo_logistico.R
│   ├── 04_render_reporte.R
│   ├── 05_guardar_salidas_cap4.R
│   └── 06_funciones_auxiliares.R
├── data/
│   └── raw/
└── outputs/
    ├── figuras/
    ├── tablas/
    └── reportes/
```

---

## ▶️ Formas de ejecución

### Ejecutar todo el capítulo

```r
source("run_cap4.R")
```

### Ejecutar por bloques

```r
source("R/00_setup.R")
source("R/06_funciones_auxiliares.R")
source("R/01_modelo_exponencial_continuo.R")
source("R/02_modelo_exponencial_discreto.R")
source("R/03_modelo_logistico.R")
source("R/05_guardar_salidas_cap4.R")
source("R/04_render_reporte.R")
```

### Limpiar outputs y empezar desde cero

```r
source("limpiar_outputs.R")
```

---

## 📊 Resultados esperados

Al ejecutar este capítulo se generan:

- tablas de parámetros y escenarios en `outputs/tablas/`
- objeto consolidado `.rds` en `outputs/reportes/`
- reporte reproducible HTML en `outputs/reportes/`

> **Nota:** las figuras de este capítulo se generan por simulación y se renderizan
> directamente en el reporte HTML. No se exportan como archivos `.png` independientes.

---

## 🔗 Relación con el libro

Este capítulo corresponde al inicio de la **Unidad II — Ecología de poblaciones** del libro ANVIDEA. Constituye la base conceptual para comprender tablas de vida, matrices poblacionales y estructura demográfica desarrolladas en el Capítulo 5.
