# Unidad I — Análisis de datos ecológicos

Esta unidad introduce el flujo completo de análisis de datos ecológicos en R, integrando:

- importación de datos
- limpieza y transformación
- exploración gráfica
- análisis de patrones climáticos

Corresponde a la primera parte del manual **ANVIDEA** y sienta las bases para los análisis de poblaciones y comunidades en unidades posteriores.

---

## 🎯 Propósito de la unidad

Desarrollar competencias para:

- estructurar bases de datos ecológicos
- manipular datos con `tidyverse`
- explorar patrones mediante visualización gráfica
- interpretar variables climáticas en contexto ecológico

---

## 📁 Estructura de la unidad

- **cap1-datos/**  
  Manipulación y limpieza de datos ecológicos.

- **cap2-visualizacion-exploratoria/**  
  Exploración gráfica multivariada.

- **cap3-clima/**  
  Análisis de patrones climáticos y balance hídrico.

Cada capítulo contiene:

- scripts en `R/`
- datos en `data/raw/`
- resultados en `outputs/`

---

## 🗂️ Bases de datos utilizadas

| Capítulo | Archivos |
|----------|--------|
| Cap. 1 | `plancton.xlsx`, `invert.xlsx` |
| Cap. 2 | `plancton.xlsx`, `invert.xlsx` |
| Cap. 3 | `datos.xlsx`, `estaciones.xlsx`, `bal_hid.R` |

---

## ▶️ Formas de ejecución

### 🔹 Opción 1 — Ejecutar toda la unidad

```r
source("run_unidad1.R")
```