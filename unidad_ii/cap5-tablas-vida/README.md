# Capítulo 5 — Tablas de vida y modelos matriciales

Plantillas derivadas del capítulo sobre análisis demográfico estructurado, incluyendo:

- Tablas de vida por edades
- Modelos matriciales de Leslie (por edades)
- Modelos de Lefkovitch (por estados)

---

## 📁 Estructura de scripts

### Preparación
- `00_setup.R`
- `05_funciones_auxiliares.R`

### Casos guiados

#### A. Tablas de vida
- `01_casoA1_tabla_vida_edad.R`  
  (Datos de cementerios — análisis empírico)

- `02_casoA2_tabla_vida_gotelli.R`  
  (Datos clásicos — construcción completa + transición a matrices)

#### B. Modelo de Leslie (por edades)
- `03_casoB_modelo_leslie.R`  
  (Derivado del caso A2)

#### C. Modelo de Lefkovitch (por estados)
- `04_casoC_modelo_lefkovitch.R`

---

## 📊 Datos esperados

Archivo:  
`data/raw/datos.c5.xlsx`

Hojas requeridas:

- `cement1`
- `cement2`
- `gotelli`
- `t.vida`
- `calotropis`

---

## 🔁 Flujo recomendado de ejecución

```r
source("R/01_casoA1_tabla_vida_edad.R")
source("R/02_casoA2_tabla_vida_gotelli.R")
source("R/03_casoB_modelo_leslie.R")
source("R/04_casoC_modelo_lefkovitch.R")
```

---

## 🧠 Nota pedagógica

Este capítulo sigue una progresión conceptual:

1. Datos reales → tablas de vida  
2. Formalización → parámetros demográficos  
3. Modelos matriciales por edades (Leslie)  
4. Generalización por estados (Lefkovitch)

---

## ⚠️ Nota técnica

Los nombres de columnas esperados fueron definidos para mantener consistencia con el flujo del capítulo en el libro ANVIDEA.
