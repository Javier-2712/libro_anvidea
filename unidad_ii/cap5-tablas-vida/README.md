<p align="left">
  <img src="Logo_GIEN.png" alt="GIEN - Grupo de Investigación en Ecología Neotropical" width="250">
</p>

# Capítulo 5 — Tablas de vida y modelos matriciales

Este capítulo desarrolla herramientas demográficas para analizar la estructura de poblaciones por **edades** y por **estados**, integrando tablas de vida, parámetros demográficos y modelos matriciales clásicos.

A diferencia del Capítulo 4, aquí el trabajo se organiza en **casos guiados**, de modo que el lector avance desde la descripción de la supervivencia hasta la proyección de poblaciones estructuradas.

---

## 🎯 Propósito

Desarrollar competencias para:

- construir tablas de vida por edades a partir de datos reales
- interpretar parámetros demográficos como supervivencia, fecundidad y esperanza de vida
- formalizar la transición desde tablas de vida hacia modelos matriciales
- construir y analizar matrices de Leslie
- construir y analizar matrices de Lefkovitch
- relacionar estructura poblacional, proyección y dinámica demográfica

---

## 🧠 Enfoque pedagógico

La progresión conceptual del capítulo sigue cuatro bloques:

1. **Caso A1** — tabla de vida por edades a partir de datos empíricos
2. **Caso A2** — tabla de vida clásica y estimadores demográficos
3. **Caso B** — modelo matricial de Leslie por edades
4. **Caso C** — modelo matricial de Lefkovitch por estados

Esta secuencia permite pasar desde la descripción demográfica básica hasta la modelación poblacional estructurada.

---

## 📁 Estructura del capítulo

```
cap5-tablas-vida/
├── README.md
├── run_cap5.R
├── limpiar_outputs.R
├── reporte_cap5.qmd
├── data/
│   └── raw/
│       └── datos.c5.xlsx
├── outputs/
│   ├── figuras/
│   ├── tablas/
│   └── reportes/
└── R/
    ├── 00_setup.R
    ├── 01_casoA1_tabla_vida_edad.R
    ├── 02_casoA2_tabla_vida_gotelli.R
    ├── 03_casoB_modelo_leslie.R
    ├── 04_casoC_modelo_lefkovitch.R
    ├── 05_funciones_auxiliares.R
    ├── 06_render_reporte.R
    └── 07_guardar_salidas_cap5.R
```

---

## 📊 Datos esperados

Archivo principal:

```
data/raw/datos.c5.xlsx
```

Hojas esperadas:

- `cement1`
- `cement2`
- `gotelli`
- `t.vida`
- `caltropis`

---

## ▶️ Formas de ejecución

### Ejecutar todo el capítulo

```r
source("run_cap5.R")
```

### Ejecutar por casos

```r
source("R/00_setup.R")
source("R/05_funciones_auxiliares.R")
source("R/01_casoA1_tabla_vida_edad.R")
source("R/02_casoA2_tabla_vida_gotelli.R")
source("R/03_casoB_modelo_leslie.R")
source("R/04_casoC_modelo_lefkovitch.R")
source("R/07_guardar_salidas_cap5.R")
source("R/06_render_reporte.R")
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

## 🔗 Relación con el libro

Este capítulo corresponde al núcleo demográfico de la **Unidad II — Ecología de poblaciones** del libro ANVIDEA. Su función es conectar la estructura por edades y estados con la proyección de poblaciones en contextos ecológicos reales. Constituye la base conceptual para los análisis de distribución espacial y estimación de densidad desarrollados en el Capítulo 6.
