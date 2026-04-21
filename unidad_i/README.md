<p align="center">
  <img src="Logo_GIEN.png" width="250">
  <img src="logoUM.png" width="120">
</p>

# 🌿 Unidad I — Análisis de datos ecológicos

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

```text
unidad_i/
├── run_unidad1.R
├── README.md
├── index.qmd
├── cap1-datos/
├── cap2-visualizacion-exploratoria/
└── cap3-clima/
```

Cada capítulo contiene:

```text
capX-nombre/
├── README.md
├── run_capX.R
├── limpiar_outputs.R
├── reporte_capX.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_caso*.R
│   ├── 02_caso*.R  (cap1 y cap2)
│   ├── 03_funciones_auxiliares.R  (cap1 y cap2)
│   ├── 03_guardar_salidas_capX.R  (cap3)
│   ├── 04_guardar_salidas_capX.R  (cap1 y cap2)
│   └── 05_render_reporte.R  (cap1 y cap2) / 04_render_reporte.R  (cap3)
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
| Cap. 1 | `plancton.xlsx`, `invert.xlsx` |
| Cap. 2 | `plancton.xlsx`, `invert.xlsx` |
| Cap. 3 | `datos.c3.xlsx`, `bal_hid.R` |

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

Desde la carpeta `unidad_i/`:

```r
source("run_unidad1.R")
```

Esto ejecuta automáticamente los tres capítulos en secuencia.

---

### 🔹 Opción 2 — Ejecutar por capítulo

Ingresa a la carpeta del capítulo y ejecuta:

```r
source("run_cap1.R")   # cap1-datos/
source("run_cap2.R")   # cap2-visualizacion-exploratoria/
source("run_cap3.R")   # cap3-clima/
```

---

### 🔹 Opción 3 — Ejecutar por partes

Dentro de cada capítulo:

```r
source("R/00_setup.R")
source("R/01_caso*.R")
source("R/04_guardar_salidas_capX.R")   # cap1 y cap2
source("R/05_render_reporte.R")          # cap1 y cap2
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
- Verifica que los paquetes necesarios estén instalados (`tidyverse`, `readxl`, `writexl`, `kableExtra`, `cowplot`, `viridis`)

---

## 🔗 Relación con el libro

Esta unidad corresponde a la base metodológica del libro ANVIDEA, donde se construyen las habilidades necesarias para:

- análisis de datos (Unidad I)
- modelos poblacionales (Unidad II)
- análisis de comunidades (Unidad III)

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
