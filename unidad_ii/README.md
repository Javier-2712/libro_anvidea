<p align="center">
  <img src="Logos.png" width="600">
</p>

# 🌿 Unidad II — Ecología de poblaciones

Esta unidad integra herramientas cuantitativas para el análisis de la dinámica poblacional, abordando procesos de crecimiento, estructura demográfica y organización espacial.

Corresponde a la segunda parte del manual **ANVIDEA** y desarrolla las herramientas de modelación poblacional necesarias para los análisis de comunidades de la Unidad III.

---

## 🎯 Propósito de la unidad

Desarrollar competencias para:

- modelar el crecimiento exponencial, discreto y logístico de poblaciones
- construir e interpretar tablas de vida por edades y por estados
- proyectar poblaciones estructuradas con modelos matriciales
- evaluar patrones de distribución espacial mediante pruebas estadísticas
- estimar la densidad poblacional con métodos basados en distancias

---

## 📁 Estructura de la unidad

```
unidad_ii/
├── run_unidad2.R
├── README.md
├── index.qmd
├── cap4-modelos-crecimiento/
├── cap5-tablas-vida/
└── cap6-distribucion-densidad/
```

Cada capítulo contiene:

```
capX-nombre/
├── README.md
├── run_capX.R
├── limpiar_outputs.R
├── reporte_capX.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_caso*.R
│   ├── ...
│   ├── funciones_auxiliares.R
│   ├── guardar_salidas_capX.R
│   └── render_reporte.R
├── data/raw/
└── outputs/
    ├── figuras/
    ├── tablas/
    └── reportes/
```

---

## 🗂️ Bases de datos utilizadas

| Capítulo | Archivos |
|----------|----------|
| Cap. 4 | datos del capítulo 4 |
| Cap. 5 | `datos.c5.xlsx` |
| Cap. 6 | `datos.c6.xlsx` |

---

## ⚠️ Uso del material

Los scripts en R **no se ejecutan desde GitHub ni desde el portal web**.

👉 Este material está diseñado para trabajarse en un entorno local.

Para utilizarlo:

1. Descarga la carpeta de la unidad o el repositorio completo
2. Ábrela en RStudio
3. Ejecuta los scripts en tu computador

---

## ▶️ Formas de ejecución

### 🔹 Opción 1 — Ejecutar toda la unidad

Desde la carpeta `unidad_ii/`:

```r
source("run_unidad2.R")
```

Esto ejecuta automáticamente los tres capítulos en secuencia.

---

### 🔹 Opción 2 — Ejecutar por capítulo

Ingresa a la carpeta del capítulo y ejecuta:

```r
source("run_cap4.R")   # cap4-modelos-crecimiento/
source("run_cap5.R")   # cap5-tablas-vida/
source("run_cap6.R")   # cap6-distribucion-densidad/
```

---

### 🔹 Opción 3 — Ejecutar por partes

Dentro de cada capítulo:

```r
source("R/00_setup.R")
source("R/01_caso*.R")
source("R/guardar_salidas_capX.R")
source("R/render_reporte.R")
```

---

### 🔹 Opción 4 — Reiniciar salidas

Desde la carpeta de cada capítulo:

```r
source("limpiar_outputs.R")
```

---

## 💡 Recomendaciones

- Ejecuta los scripts desde la carpeta raíz de cada capítulo
- No modifiques los nombres de los archivos de datos
- Mantén la estructura de carpetas (`R/`, `data/raw/`, `outputs/`)
- Verifica que los paquetes necesarios estén instalados (`tidyverse`, `readxl`, `writexl`, `kableExtra`, `patchwork`, `corrplot`, `broom`, `MASS`)

---

## 🔗 Relación con el libro

Esta unidad corresponde al núcleo de modelación de la **Unidad II — Ecología de poblaciones** del libro ANVIDEA, donde se desarrollan las herramientas para:

- modelos de crecimiento (Capítulo 4)
- demografía estructurada (Capítulo 5)
- análisis espacial y densidad (Capítulo 6)

---

## 📄 Licencia

Este proyecto distingue entre el código y los contenidos académicos:

- 💻 Código en R: Licenciado bajo MIT License
- 📘 Contenidos del libro y material pedagógico: Licenciados bajo Creative Commons CC BY-NC 4.0

Esto permite la reutilización académica y docente del material, evitando su uso comercial sin autorización del autor.

---

## ⬅️ Navegación

👉 Volver al repositorio principal:
https://github.com/Javier-2712/libro_anvidea

👉 Volver al portal web:
https://javier-2712.github.io/libro_anvidea/
