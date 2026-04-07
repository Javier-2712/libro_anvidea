# Unidad II — Ecología de poblaciones

Esta unidad integra herramientas cuantitativas para el análisis de la dinámica poblacional, abordando procesos de crecimiento, estructura demográfica y organización espacial.

Incluye tres capítulos articulados:

- Modelos de crecimiento poblacional
- Estructura por edades y estados
- Patrones espaciales y estimación de densidad

---

## 📁 Estructura de la unidad

### Capítulo 4 — Modelos poblacionales
- Crecimiento exponencial (continuo y discreto)
- Modelo logístico
- Interpretación ecológica de parámetros (r, λ, K)

### Capítulo 5 — Tablas de vida y modelos matriciales
- Tablas de vida por edades
- Parámetros demográficos (R₀, T, r, λ)
- Modelos matriciales de Leslie (por edades)
- Modelos de Lefkovitch (por estados)

### Capítulo 6 — Patrones de distribución y densidad
- Patrones espaciales (aleatorio, agregado, uniforme)
- Ajuste a Poisson y Binomial Negativa
- Índices de dispersión
- Estimación de densidad (Holgate, King, Hayne)

---

## 📂 Organización de carpetas

Cada capítulo sigue la estructura:

```
capX-nombre-del-capitulo/
├── R/
│   ├── 00_setup.R
│   ├── funciones_auxiliares.R
│   ├── scripts de casos
├── data/raw/
├── outputs/
│   ├── figuras/
│   └── tablas/
```

---

## ▶️ Ejecución de la unidad

Archivo principal:

```r
source("run_unidad2.R")
```

Este script ejecuta de forma secuencial:

1. Capítulo 4  
2. Capítulo 5  
3. Capítulo 6  

---

## 🔁 Ejecución por capítulos

También puedes ejecutar cada capítulo de forma independiente:

### Capítulo 4
```r
source("cap4-modelos-poblacionales/R/01_casoA_modelo_exponencial.R")
source("cap4-modelos-poblacionales/R/02_casoB_modelo_logistico.R")
```

### Capítulo 5
```r
source("cap5-tablas-vida-modelos-matriciales/R/01_casoA1_tabla_vida_edad.R")
source("cap5-tablas-vida-modelos-matriciales/R/02_casoA2_tabla_vida_gotelli.R")
source("cap5-tablas-vida-modelos-matriciales/R/03_casoB_modelo_leslie.R")
source("cap5-tablas-vida-modelos-matriciales/R/04_casoC_modelo_lefkovitch.R")
```

### Capítulo 6
```r
source("cap6-distribucion-densidad/R/01_casoA_patrones_distribucion.R")
source("cap6-distribucion-densidad/R/02_casoB_estimacion_densidad.R")
```

---

## 📊 Datos esperados

Cada capítulo utiliza su propio archivo de datos:

- Capítulo 4: datos internos en scripts o simulación  
- Capítulo 5: `data/raw/datos.c5.xlsx`  
- Capítulo 6: `data/raw/datos.c6.xlsx`  

---

## 🧠 Enfoque pedagógico

La unidad sigue una progresión conceptual:

1. **Tiempo** → crecimiento poblacional  
2. **Estructura** → organización por edades y estados  
3. **Espacio** → distribución y densidad  

Esto permite integrar modelos matemáticos con interpretación ecológica en diferentes escalas.

---

## ⚠️ Nota técnica

- Los nombres de variables y hojas deben coincidir con los utilizados en los scripts.  
- Las carpetas `outputs/figuras` y `outputs/tablas` se generan automáticamente.  
- Se recomienda ejecutar cada capítulo en el orden propuesto para mantener coherencia en el flujo de análisis.

---

## ✅ Estado de la unidad

✔ Capítulo 4 validado  
✔ Capítulo 5 validado  
✔ Capítulo 6 validado  

Unidad II lista para ejecución completa.
