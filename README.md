<p align="center">
  <img src="Logos.png" width="250">
</p>

# ANVIDEA — Material reproducible

Repositorio oficial de materiales reproducibles asociados al libro:

**"Análisis y Visualización de Datos Ecológicos y Ambientales — ANVIDEA"**

Este repositorio está diseñado para que estudiantes, docentes e investigadores puedan:

- Reproducir los análisis presentados en el libro
- Explorar los datos utilizados en los casos guiados
- Ejecutar scripts organizados por unidades y capítulos
- Adaptar los flujos de trabajo a sus propios datos

---

## 📁 Estructura general

```
libro_anvidea/
├── index.qmd           ← página principal del portal web
├── _quarto.yml         ← configuración del sitio web
├── run_libro.R         ← ejecución completa (análisis + sitio)
├── README.md
├── styles.css
├── Logo_GIEN.png
├── docs/               ← sitio web generado (GitHub Pages)
├── unidad_i/
├── unidad_ii/
└── unidad_iii/
```

Cada unidad contiene:

- `README.md` → descripción de la unidad
- `run_unidadX.R` → ejecución completa de la unidad
- carpetas por capítulo (`capX-nombre/`)

Cada capítulo contiene:

- `README.md` → explicación del contenido
- `run_capX.R` → ejecución del capítulo
- `R/` → scripts del análisis
- `data/raw/` → datos de entrada
- `outputs/figuras/`, `outputs/tablas/`, `outputs/reportes/`

---

## ⚠️ Uso del material

Los scripts en R **no se ejecutan desde GitHub ni desde el portal web**.

Para trabajar con el material:

1. Descarga el repositorio (ZIP) o clónalo
2. Descomprímelo en tu computador
3. Abre la carpeta raíz en RStudio
4. Ejecuta los scripts de forma local

---

## ▶️ Formas de ejecución

### Opción 1 — Ejecución completa (análisis + sitio web)

Desde la raíz `libro_anvidea/`:

```r
source("run_libro.R")
```

Esto ejecuta las tres unidades en secuencia y luego renderiza el sitio en `docs/`.

---

### Opción 2 — Ejecutar por unidad

```r
# Desde libro_anvidea/
setwd("unidad_i");  source("run_unidad1.R"); setwd("..")
setwd("unidad_ii"); source("run_unidad2.R"); setwd("..")
setwd("unidad_iii"); source("run_unidad3.R"); setwd("..")
```

---

### Opción 3 — Ejecutar por capítulo

Desde la carpeta del capítulo:

```r
source("run_cap7.R")   # desde cap7-diversidad-taxonomica/
source("run_cap8.R")   # desde cap8-diversidad-funcional-filogenetica/
```

---

### Opción 4 — Actualizar solo el portal web

Desde la raíz `libro_anvidea/`, sin re-correr los análisis:

```r
system("quarto render")
```

O desde la terminal:

```bash
quarto render
```

---

### Opción 5 — Publicar en GitHub Pages

Después de renderizar:

```bash
git add docs/
git commit -m "Actualizar sitio"
git push
```

El portal se actualiza en segundos en:
👉 [javier-2712.github.io/libro_anvidea](https://javier-2712.github.io/libro_anvidea/)

---

## 📊 Datos

Cada capítulo incluye sus propios datos en `data/raw/`. No modifiques los nombres de archivos para garantizar la reproducibilidad.

---

## 📦 Paquetes necesarios

Los paquetes requeridos se detallan en el README de cada capítulo. Los comunes a toda la Unidad III son:

```r
install.packages(c("tidyverse", "readxl", "writexl", "vegan",
                   "FD", "ape", "taxize", "ade4", "kableExtra"))
remotes::install_github("AnneChao/iNEXT.3D")
remotes::install_github("AnneChao/iNEXTbeta3D")
```

---

## 🌐 Portal web

👉 [javier-2712.github.io/libro_anvidea](https://javier-2712.github.io/libro_anvidea/)

---

## 🧠 Enfoque pedagógico

| Unidad | Temática |
|---|---|
| **Unidad I** | Manipulación, visualización y análisis de datos ecológicos |
| **Unidad II** | Dinámica y estructura poblacional |
| **Unidad III** | Diversidad taxonómica, funcional y filogenética |

---

## 👨‍🏫 Autor

**Javier Rodríguez-Barrios**

---

## 📄 Licencia

- 💻 Código en R: MIT License
- 📘 Contenidos del libro: Creative Commons CC BY-NC 4.0

---

## 🚀 Estado del proyecto

✔ Estructura base implementada  
✔ Scripts organizados por unidades y capítulos  
✔ Portal web activo en GitHub Pages  
✔ Material listo para uso educativo y reproducible
