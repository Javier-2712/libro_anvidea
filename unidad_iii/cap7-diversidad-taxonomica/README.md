<p align="left">
  <img src="../../Logo_GIEN.png" alt="GIEN - Grupo de Investigación en Ecología Neotropical" width="250">
</p>

# 🌿 Capítulo 7 — Diversidad taxonómica

Este capítulo desarrolla el flujo completo de análisis de la diversidad taxonómica en R, integrando enfoques clásicos, modelos estadísticos comparativos y marcos modernos basados en números efectivos de Hill.

Corresponde al primer capítulo de la **Unidad III — Análisis de comunidades** del manual ANVIDEA.

---

## 🎯 Propósito del capítulo

Desarrollar competencias para:

- estimar la diversidad alfa con índices clásicos (riqueza, Shannon, Simpson, Pielou)
- construir e interpretar curvas de distribución rango-abundancia (RAD)
- comparar ensamblajes con GLMs multivariados y PERMANOVAs
- identificar especies diagnóstico con SIMPER
- calcular diversidad alfa estandarizada con números de Hill (iNEXT, iNEXT.4steps, iNEXT.3D)
- estimar diversidad beta clásica (Jaccard, Sørensen, Whittaker)
- calcular SCBD y LCBD con `beta.div`
- descomponer beta en recambio y diferencia de riqueza (Podani & Schmera, 2011)
- estimar diversidad beta estandarizada con números de Hill (iNEXT.beta3D)

---

## 📁 Estructura del capítulo

```
cap7-diversidad-taxonomica/
├── README.md
├── run_cap7.R
├── limpiar_outputs.R
├── reporte_cap7.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_casoA_alfa_clasica_rad.R
│   ├── 02_casoA_alfa_glm_permanovas.R
│   ├── 03_casoA_alfa_hill.R
│   ├── 04_casoB_beta_clasica_varianza.R
│   ├── 05_casoB_beta_podani_recambio.R
│   ├── 06_casoB_beta_hill.R
│   ├── 07_funciones_auxiliares.R
│   ├── 08_guardar_salidas_cap7.R
│   └── 09_render_reporte.R
├── data/
│   └── raw/
│       └── datos.c7.xlsx
└── outputs/
    ├── figuras/
    ├── tablas/
    └── reportes/
```

---

## 🗂️ Base de datos utilizada

| Hoja | Contenido |
|------|-----------|
| `tax` | Abundancia de peces por sitio (Sitios × Especies) |
| `tax1` | Tabla de abreviaturas y nombres latinos |
| `amb` | Variables ambientales por sitio |
| `rasgos` | Rasgos funcionales de las especies |
| `coord` | Coordenadas geográficas de los sitios |

---

## ⚠️ Uso del material

Los scripts en R **no se ejecutan desde GitHub ni desde el portal web**.

Para utilizarlos:

1. Descarga la carpeta del capítulo o el repositorio completo
2. Ábrela en RStudio
3. Ejecuta los scripts desde tu computador

---

## ▶️ Formas de ejecución

### 🔹 Opción 1 — Ejecutar todo el capítulo

Desde la carpeta `cap7-diversidad-taxonomica/`:

```r
source("run_cap7.R")
```

Esto ejecuta automáticamente los seis casos, guarda las salidas y renderiza el reporte HTML.

---

### 🔹 Opción 2 — Ejecutar por casos

```r
source("R/00_setup.R")
source("R/07_funciones_auxiliares.R")

# Caso A — Diversidad alfa
source("R/01_casoA_alfa_clasica_rad.R")
source("R/02_casoA_alfa_glm_permanovas.R")
source("R/03_casoA_alfa_hill.R")

# Caso B — Diversidad beta
source("R/04_casoB_beta_clasica_varianza.R")
source("R/05_casoB_beta_podani_recambio.R")
source("R/06_casoB_beta_hill.R")

# Guardar y reportar
source("R/08_guardar_salidas_cap7.R")
source("R/09_render_reporte.R")
```

---

### 🔹 Opción 3 — Reiniciar salidas

```r
source("limpiar_outputs.R")
```

---

## 📦 Paquetes necesarios

```r
install.packages(c(
  "tidyverse", "readxl", "writexl",
  "vegan", "ggrepel", "viridis",
  "adespatial", "betapart", "ade4",
  "cluster", "factoextra", "gridExtra",
  "ggforce", "patchwork",
  "mvabund", "MASS", "glmmTMB", "RVAideMemoire",
  "MVN", "car", "corrplot", "kableExtra"
))

# Paquetes desde GitHub (Chao Lab):
# devtools::install_github("AnneChao/iNEXT")
# devtools::install_github("AnneChao/iNEXT.4steps")
# devtools::install_github("AnneChao/iNEXT.3D")
# devtools::install_github("AnneChao/iNEXT.beta3D")
```

---

## 💡 Recomendaciones

- Ejecuta los scripts en el orden propuesto: A.1 → A.2 → A.3 → B.1 → B.2 → B.3
- Los scripts A.2 y A.3 reutilizan objetos generados por A.1 (`biol1`, `biol1b`, `biol2`)
- Los scripts B.2 y B.3 reutilizan objetos generados por B.1 (`biol1`, `biol2`)
- Verifica que los paquetes de GitHub estén instalados antes de ejecutar

---

## 🔗 Relación con el libro

Este capítulo corresponde al análisis de **diversidad taxonómica** del libro ANVIDEA. Los scripts reproducen y extienden los casos guiados del libro, añadiendo:

- diagnóstico de supuestos (normalidad multivariada, homogeneidad, independencia)
- comparación de tres generaciones de paquetes iNEXT
- integración de métodos espaciales (LCBD georeferenciado, db-RDA)

---

## 📄 Licencia

- 💻 Código en R: MIT License
- 📘 Contenidos del libro: Creative Commons CC BY-NC 4.0

---

## ⬅️ Navegación

👉 Volver a la Unidad III:
[unidad_iii/](../../unidad_iii/)

👉 Volver al repositorio principal:
https://github.com/Javier-2712/libro_anvidea

👉 Volver al portal web:
https://javier-2712.github.io/libro_anvidea/
