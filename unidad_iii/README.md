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

- **cap7-diversidad-taxonomica/**  
  Diversidad taxonómica  

- **cap8-diversidad-funcional-filogenetica/**  
  Diversidad funcional y filogenética  

Cada capítulo contiene:

- `README.md` → explicación del capítulo  
- `R/` → scripts del análisis  
- `data/raw/` → datos de entrada  
- `outputs/` → resultados generados  

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
source("run_unidad3.R")
```

---

### 🔹 Opción 2 — Ejecutar por capítulo

#### Capítulo 7
```r
source("cap7-diversidad-taxonomica/R/01_casoA_TD_alfa_y_Hill.R")
source("cap7-diversidad-taxonomica/R/02_casoB_TD_beta_y_recambio.R")
```

#### Capítulo 8
```r
source("cap8-diversidad-funcional-filogenetica/R/01_casoA_FD_PD_alfa.R")
source("cap8-diversidad-funcional-filogenetica/R/02_casoB_PD_beta_y_alineacion.R")
source("cap8-diversidad-funcional-filogenetica/R/03_casoC_FD_beta.R")
```

---

## 📊 Datos utilizados

- Capítulo 7: `data/raw/datos.c7.xlsx`  
- Capítulo 8:  
  - `data/raw/datos.c8.xlsx`  
  - `arbol_filo_alfa.rds`  
  - `arbol_filo_beta.rds`  

---

## 💡 Recomendaciones

- Ejecuta los capítulos en el orden propuesto  
- No modifiques los nombres de archivos de datos  
- Mantén la estructura de carpetas (`R/`, `data/raw/`, `outputs/`)  
- Verifica que los paquetes necesarios estén instalados  

---

## 🧠 Enfoque pedagógico

La unidad integra tres dimensiones de la biodiversidad:

| Dimensión | Descripción |
|----------|------------|
| **Taxonómica (TD)** | Identidad y abundancia de especies |
| **Funcional (FD)** | Rasgos ecológicos y estrategias de vida |
| **Filogenética (PD)** | Historia evolutiva compartida |

La progresión conceptual es:

**Taxonomía → Función → Filogenia**

---

## 🔗 Relación con el libro

Esta unidad corresponde al componente de **ecología de comunidades** del libro ANVIDEA, integrando enfoques modernos para el análisis de la biodiversidad.

---

## ⚠️ Nota técnica

Esta unidad requiere mayor nivel técnico, ya que integra:

- múltiples tipos de datos (abundancia, rasgos, filogenia)  
- estructuras de datos complejas  
- métodos estadísticos avanzados  

Se recomienda contar con conocimientos previos en:

- manipulación de datos en R (`tidyverse`)  
- ecología de comunidades  
- conceptos de diversidad biológica  

---

## ⬅️ Navegación

👉 Volver al repositorio principal:  
https://github.com/Javier-2712/libro_anvidea  

👉 Volver al portal web:  
https://javier-2712.github.io/libro_anvidea/
