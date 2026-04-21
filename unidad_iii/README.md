<p align="center">
  <img src="Logos.png" width="600">
</p>

# 🌿 Unidad III — Ecología de comunidades

La Unidad III integra herramientas modernas para el análisis de la biodiversidad, combinando enfoques taxonómicos, funcionales y filogenéticos en un marco cuantitativo y reproducible en R.

Esta unidad representa la transición desde la descripción de ensamblajes biológicos hacia la **comprensión de los mecanismos ecológicos que estructuran la biodiversidad**.

---

## 🎯 Propósito de la unidad

Desarrollar habilidades para:

- analizar la diversidad biológica a múltiples escalas (α, β, γ)
- comparar ensamblajes entre sitios o zonas
- integrar abundancias, rasgos funcionales y relaciones filogenéticas
- interpretar patrones de diversidad en un contexto ecológico
- generar resultados reproducibles en R con enfoque aplicado

---

## 📁 Estructura de la unidad

```
unidad_iii/
├── run_unidad3.R
├── README.md
├── index.qmd
├── cap7-diversidad-taxonomica/
│   ├── README.md
│   ├── run_cap7.R
│   ├── R/
│   ├── data/raw/
│   └── outputs/
└── cap8-diversidad-funcional-filogenetica/
    ├── README.md
    ├── run_cap8.R
    ├── R/
    ├── data/raw/
    └── outputs/
```

---

## 🗂️ Capítulos

### 📗 Capítulo 7 — Diversidad taxonómica

Flujo completo de análisis taxonómico con índices clásicos, modelos comparativos y números de Hill.

| Caso | Contenido |
|---|---|
| A.1 | Diversidad alfa clásica y curvas rango-abundancia (RAD) |
| A.2 | GLMs multivariados y PERMANOVAs |
| A.3 | Números de Hill alfa (iNEXT, iNEXT.4steps, iNEXT.3D) |
| B.1 | Diversidad beta clásica y descomposición de varianza |
| B.2 | Beta de Podani: recambio y diferencia de riqueza |
| B.3 | Números de Hill beta (iNEXTbeta3D) |

### 📘 Capítulo 8 — Diversidad funcional y filogenética

Integración de rasgos funcionales y árboles filogenéticos con métricas clásicas y números de Hill.

| Caso | Contenido |
|---|---|
| A | Métricas funcionales alfa: FRic, FEve, FDiv, FDis, RaoQ; partición de Rao (TD, FD, PD) |
| B.1 | Números de Hill alfa funcional y filogenético (iNEXT.3D) |
| B.2 | Números de Hill beta funcional y filogenético (iNEXTbeta3D) |

---

## ⚠️ Uso del material

Los scripts en R **no se ejecutan desde GitHub ni desde el portal web**.

Para utilizarlos:

1. Descarga la carpeta de la unidad o el repositorio completo
2. Ábrela en RStudio
3. Establece el directorio de trabajo en `unidad_iii/`
4. Ejecuta los scripts en tu computador

---

## ▶️ Formas de ejecución

### 🔹 Opción 1 — Ejecutar toda la unidad

Desde la carpeta `unidad_iii/`:

```r
source("run_unidad3.R")
```

Esto ejecuta los dos capítulos en secuencia, guarda las salidas y renderiza los reportes HTML.

---

### 🔹 Opción 2 — Ejecutar por capítulo

Cada capítulo tiene su propio script de entrada. Ejecútalos desde la carpeta raíz de cada capítulo:

```r
# Desde cap7-diversidad-taxonomica/
source("run_cap7.R")

# Desde cap8-diversidad-funcional-filogenetica/
source("run_cap8.R")
```

---

### 🔹 Opción 3 — Ejecutar por casos (dentro de cada capítulo)

**Capítulo 7**, desde `cap7-diversidad-taxonomica/`:

```r
source("R/00_setup.R")
source("R/07_funciones_auxiliares.R")

source("R/01_casoA_alfa_clasica_rad.R")      # A.1 — alfa clásica y RAD
source("R/02_casoA_alfa_glm_permanovas.R")   # A.2 — GLMs y PERMANOVAs
source("R/03_casoA_alfa_hill.R")             # A.3 — números de Hill alfa
source("R/04_casoB_beta_clasica_varianza.R") # B.1 — beta clásica
source("R/05_casoB_beta_podani_recambio.R")  # B.2 — Podani y recambio
source("R/06_casoB_beta_hill.R")             # B.3 — números de Hill beta

source("R/08_guardar_salidas_cap7.R")
source("R/09_render_reporte.R")
```

**Capítulo 8**, desde `cap8-diversidad-funcional-filogenetica/`:

```r
source("R/00_setup.R")
source("R/04_funciones_auxiliares.R")
source("R/05_alineador.R")

source("R/01_casoA_clasica.R")    # A — FD y PD clásica + Rao
source("R/02_casoB1_alfa_hill.R") # B.1 — números de Hill alfa
source("R/03_casoB2_beta_hill.R") # B.2 — números de Hill beta

source("R/07_guardar_salidas_cap8.R")
source("R/08_render_reporte.R")
```

---

### 🔹 Opción 4 — Reiniciar salidas

Desde la carpeta raíz de cada capítulo:

```r
source("limpiar_outputs.R")
```

---

## 📦 Paquetes necesarios

```r
# Capítulo 7
install.packages(c(
  "tidyverse", "readxl", "writexl", "vegan", "ggrepel", "viridis",
  "adespatial", "betapart", "ade4", "cluster", "factoextra",
  "ggforce", "patchwork", "mvabund", "MASS", "glmmTMB",
  "RVAideMemoire", "MVN", "car", "corrplot", "kableExtra"
))

# Capítulo 8
install.packages(c(
  "tidyverse", "readxl", "writexl", "FD", "ape", "taxize",
  "vegan", "ggrepel", "RColorBrewer", "factoextra",
  "ade4", "kableExtra"
))

# Paquetes desde GitHub (ambos capítulos):
remotes::install_github("AnneChao/iNEXT.3D")
remotes::install_github("AnneChao/iNEXTbeta3D")

# Solo capítulo 7:
remotes::install_github("AnneChao/iNEXT")
remotes::install_github("AnneChao/iNEXT.4steps")
```

---

## 🧠 Enfoque pedagógico

La unidad integra tres dimensiones de la biodiversidad en progresión conceptual:

| Dimensión | Descripción | Capítulo |
|---|---|---|
| **Taxonómica (TD)** | Identidad y abundancia de especies | 7 |
| **Funcional (FD)** | Rasgos ecológicos y estrategias de vida | 8 |
| **Filogenética (PD)** | Historia evolutiva compartida | 8 |

**Taxonomía → Función → Filogenia**

---

## ⚠️ Nota técnica — Capítulo 8

El Capítulo 8 requiere que tres fuentes de información estén perfectamente alineadas a nivel de especie: **abundancias**, **rasgos funcionales** y **árbol filogenético**. Los desajustes entre matrices son la causa más frecuente de errores. Consulta el README del Capítulo 8 y las páginas 497–498 del libro antes de adaptar el flujo a datos propios.

---

## 💡 Recomendaciones

- Ejecuta los capítulos en el orden propuesto: **Capítulo 7 → Capítulo 8**
- No modifiques los nombres de los archivos de datos
- Mantén la estructura de carpetas (`R/`, `data/raw/`, `outputs/`)
- Verifica que los paquetes necesarios estén instalados antes de ejecutar

---

## 🔗 Relación con el libro

Esta unidad corresponde a los capítulos 7 y 8 del libro **ANVIDEA — Unidad III: Ecología de comunidades**. Los scripts reproducen y organizan los casos guiados del libro en una estructura operativa para el repositorio y el portal web.

---

## 📄 Licencia

- 💻 Código en R: MIT License
- 📘 Contenidos del libro: Creative Commons CC BY-NC 4.0

---

## ⬅️ Navegación

👉 Volver al repositorio principal:
[libro_anvidea](https://github.com/Javier-2712/libro_anvidea)

👉 Volver al portal web:
[javier-2712.github.io/libro_anvidea](https://javier-2712.github.io/libro_anvidea/)
