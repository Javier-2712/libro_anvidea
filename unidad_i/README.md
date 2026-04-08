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
  Manipulación y limpieza de datos ecológicos  

- **cap2-visualizacion-exploratoria/**  
  Exploración gráfica multivariada  

- **cap3-clima/**  
  Análisis de patrones climáticos y balance hídrico  

Cada capítulo contiene:

- `README.md` → explicación del capítulo  
- `R/` → scripts del análisis  
- `data/raw/` → datos de entrada  
- `outputs/` → resultados generados  

---

## 🗂️ Bases de datos utilizadas

| Capítulo | Archivos |
|----------|--------|
| Cap. 1 | `plancton.xlsx`, `invert.xlsx` |
| Cap. 2 | `plancton.xlsx`, `invert.xlsx` |
| Cap. 3 | `datos.xlsx`, `estaciones.xlsx`, `bal_hid.R` |

---

## ⚠️ Uso del material

Los scripts en R **no se ejecutan desde GitHub ni desde el portal web**.

👉 Este material está diseñado para trabajarse en un entorno local.

Para utilizarlo:

1. Descarga la carpeta de la unidad o el repositorio completo  
2. Ábrelo en RStudio o Quarto  
3. Ejecuta los scripts en tu computador  

---

## ▶️ Formas de ejecución

### 🔹 Opción 1 — Ejecutar toda la unidad

```r
source("run_unidad1.R")
```

---

### 🔹 Opción 2 — Ejecutar por capítulo

Ingresa a la carpeta del capítulo y ejecuta:

```r
source("R/00_setup.R")
source("R/01_casoA_*.R")
```

---

## 💡 Recomendaciones

- Ejecuta los scripts en el orden propuesto  
- No modifiques los nombres de los archivos de datos  
- Mantén la estructura de carpetas (`R/`, `data/raw/`, `outputs/`)  
- Verifica que los paquetes necesarios estén instalados  

---

## 🔗 Relación con el libro

Esta unidad corresponde a la base metodológica del libro ANVIDEA, donde se construyen las habilidades necesarias para:

- análisis de datos (Unidad I)  
- modelos poblacionales (Unidad II)  
- análisis de comunidades (Unidad III)  

---

## ⬅️ Navegación

👉 Volver al repositorio principal:  
https://github.com/Javier-2712/libro_anvidea

👉 Volver al portal web:  
https://javier-2712.github.io/libro_anvidea/
