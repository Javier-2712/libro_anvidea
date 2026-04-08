# Unidad II — Ecología de poblaciones

Esta unidad integra herramientas cuantitativas para el análisis de la dinámica poblacional, abordando procesos de crecimiento, estructura demográfica y organización espacial.

Incluye tres capítulos articulados:

- Modelos de crecimiento poblacional  
- Estructura por edades y estados  
- Patrones espaciales y estimación de densidad  

---

## 🎯 Propósito de la unidad

Desarrollar competencias para:

- modelar el crecimiento poblacional  
- interpretar parámetros demográficos (r, λ, K)  
- analizar la estructura poblacional por edades y estados  
- evaluar patrones espaciales y estimar densidad  

---

## 📁 Estructura de la unidad

- **cap4-modelos-poblacionales/**  
  Modelos de crecimiento poblacional  

- **cap5-tablas-vida/**  
  Estructura demográfica y modelos matriciales  

- **cap6-distribucion-densidad/**  
  Patrones espaciales y estimación de densidad  

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
source("run_unidad2.R")
```

---

### 🔹 Opción 2 — Ejecutar por capítulo

#### Capítulo 4
```r
source("cap4-modelos-poblacionales/R/01_casoA_modelo_exponencial.R")
source("cap4-modelos-poblacionales/R/02_casoB_modelo_logistico.R")
```

#### Capítulo 5
```r
source("cap5-tablas-vida/R/01_casoA1_tabla_vida_edad.R")
source("cap5-tablas-vida/R/02_casoA2_tabla_vida_gotelli.R")
source("cap5-tablas-vida/R/03_casoB_modelo_leslie.R")
source("cap5-tablas-vida/R/04_casoC_modelo_lefkovitch.R")
```

#### Capítulo 6
```r
source("cap6-distribucion-densidad/R/01_casoA_patrones_distribucion.R")
source("cap6-distribucion-densidad/R/02_casoB_estimacion_densidad.R")
```

---

## 📊 Datos utilizados

- Capítulo 4: simulaciones o datos generados en script  
- Capítulo 5: `data/raw/datos.c5.xlsx`  
- Capítulo 6: `data/raw/datos.c6.xlsx`  

---

## 💡 Recomendaciones

- Ejecuta los capítulos en el orden propuesto  
- No modifiques los nombres de archivos de datos  
- Mantén la estructura de carpetas (`R/`, `data/raw/`, `outputs/`)  
- Verifica que los paquetes necesarios estén instalados  

---

## 🧠 Enfoque pedagógico

La unidad sigue una progresión conceptual:

1. **Tiempo** → crecimiento poblacional  
2. **Estructura** → organización por edades y estados  
3. **Espacio** → distribución y densidad  

Esto permite integrar modelos matemáticos con interpretación ecológica en diferentes escalas.

---

## 🔗 Relación con el libro

Esta unidad corresponde al componente de **ecología de poblaciones** del libro ANVIDEA, conectando los fundamentos analíticos con aplicaciones ecológicas reales.

---

## ⬅️ Navegación

👉 Volver al repositorio principal:  
https://github.com/Javier-2712/libro_anvidea  

👉 Volver al portal web:  
https://javier-2712.github.io/libro_anvidea/
