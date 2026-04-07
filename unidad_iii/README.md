# 🌿 Unidad III — Ecología de comunidades

La Unidad III integra herramientas modernas para el análisis de la biodiversidad, combinando enfoques taxonómicos, funcionales y filogenéticos en un marco cuantitativo y reproducible en R.

Esta unidad representa la transición desde la descripción de ensamblajes biológicos hacia la **comprensión de los mecanismos ecológicos que estructuran la biodiversidad**.

---

## 🎯 Objetivo de la unidad

Desarrollar habilidades para:

- analizar la diversidad biológica a múltiples escalas (α, β, γ)
- comparar ensamblajes entre sitios o zonas
- integrar abundancias, rasgos funcionales y relaciones filogenéticas
- interpretar patrones de diversidad en un contexto ecológico
- generar resultados reproducibles en R con enfoque aplicado

---

## 📚 Capítulos incluidos

### 🌱 Capítulo 7 — Diversidad taxonómica

Aborda la biodiversidad desde la identidad de las especies.

Incluye:

- diversidad alfa (q = 0, 1, 2)
- curvas rango–abundancia (RAD)
- diversidad beta y gamma
- disimilitud (Jaccard)
- contribución local a la diversidad beta (LCBD)

📁 Carpeta:

```text
cap7-diversidad-taxonomica/
```

---

### 🌱 Capítulo 8 — Diversidad funcional y filogenética

Extiende el análisis incorporando:

- rasgos funcionales (FD)
- relaciones evolutivas (PD)

Incluye:

- CWM (Community Weighted Means)
- métricas funcionales (FRic, FEve, FDiv, FDis)
- descomposición de diversidad con Rao
- iNEXT.3D (FD y PD)
- iNEXTbeta3D (diversidad beta funcional y filogenética)
- alineación entre matrices de abundancia y árboles filogenéticos

📁 Carpeta:

```text
cap8-diversidad-funcional-filogenetica/
```

---

## ▶️ Ejecución

### 🔹 Ejecutar toda la unidad

```r
source("run_unidad3.R")
```

### 🔹 Ejecutar por capítulos

```r
# Capítulo 7
source("cap7-diversidad-taxonomica/R/01_casoA_TD_alfa_y_Hill.R")
source("cap7-diversidad-taxonomica/R/02_casoB_TD_beta_y_recambio.R")

# Capítulo 8
source("cap8-diversidad-funcional-filogenetica/R/01_casoA_FD_PD_alfa.R")
source("cap8-diversidad-funcional-filogenetica/R/02_casoB_PD_beta_y_alineacion.R")
source("cap8-diversidad-funcional-filogenetica/R/03_casoC_FD_beta.R")
```

---

## 📦 Archivos de entrada

Cada capítulo contiene su propia carpeta `data/raw/`.

### Capítulo 7
- `datos.c7.xlsx`

### Capítulo 8
- `datos.c8.xlsx`
- `arbol_filo_alfa.rds`
- `arbol_filo_beta.rds`

---

## 📊 Salidas

Cada capítulo genera automáticamente:

- `outputs/figuras/`
- `outputs/tablas/`

Estas salidas están listas para:

- docencia
- informes
- manuscritos científicos
- integración en Quarto

---

## 🔬 Enfoque metodológico

La Unidad III integra tres dimensiones de la biodiversidad:

| Dimensión | Descripción |
|----------|------------|
| **Taxonómica (TD)** | Identidad y abundancia de especies |
| **Funcional (FD)** | Rasgos ecológicos y estrategias de vida |
| **Filogenética (PD)** | Historia evolutiva compartida |

Se emplean enfoques complementarios:

- números de Hill (q = 0, 1, 2)
- descomposición de diversidad (α, β, γ)
- entropía cuadrática de Rao
- rarefacción y extrapolación (iNEXT)
- análisis basado en cobertura

---

## 🔁 Integración conceptual

```text
Diversidad taxonómica (TD)
            ↓
Diversidad funcional (FD)
            ↓
Diversidad filogenética (PD)
```

permitiendo una interpretación integral de la biodiversidad.

---

## 📖 Libro asociado

Esta unidad hace parte del libro:

**ANVIDEA — Análisis y Visualización de Datos Ecológicos y Ambientales**

---

## 💡 Recomendaciones de uso

- Ejecutar primero cada capítulo por separado
- Verificar salidas antes de ejecutar toda la unidad
- Revisar coherencia entre datos de entrada y scripts
- Usar esta unidad como base para análisis propios

---

## ⚠️ Nota técnica

La Unidad III es metodológicamente más exigente que las anteriores, ya que integra:

- múltiples tipos de datos (abundancia, rasgos, filogenia)
- estructuras de datos complejas
- métodos estadísticos avanzados

Se recomienda tener conocimientos previos de:

- manipulación de datos en R (tidyverse)
- ecología de comunidades
- conceptos de diversidad biológica
