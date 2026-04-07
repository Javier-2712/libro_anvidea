# Capítulo 6 — Patrones de distribución y estimación de la densidad

Plantillas derivadas del capítulo sobre análisis de patrones espaciales y estimación de densidad en poblaciones ecológicas.

Incluye:

- Evaluación de patrones de distribución (aleatorio, agregado, uniforme)
- Ajuste a distribuciones teóricas (Poisson y Binomial Negativa)
- Cálculo de índices de dispersión
- Estimación de densidad mediante métodos basados en distancias

---

## 📁 Estructura de scripts

### Preparación
- `00_setup.R`
- `03_funciones_auxiliares.R`

### Casos guiados

#### A. Patrones de distribución espacial
- `01_casoA_patrones_distribucion.R`  
  (Ajuste a Poisson, Binomial Negativa e índices de dispersión)

#### B. Estimación de densidad
- `02_casoB_estimacion_densidad.R`  
  (Métodos de Holgate, King y Hayne)

---

## 📊 Datos esperados

Archivo:  
`data/raw/datos.c6.xlsx`

Hojas requeridas:

- `poisson`
- `densidad1`
- `densidad2`

---

## 🔁 Flujo recomendado de ejecución

```r
source("R/01_casoA_patrones_distribucion.R")
source("R/02_casoB_estimacion_densidad.R")
```

---

## 🧠 Nota pedagógica

Este capítulo integra dos enfoques complementarios en ecología de poblaciones:

1. La **estructura espacial de los individuos**, evaluada mediante modelos probabilísticos e índices de dispersión.
2. La **estimación de la densidad poblacional**, basada en distancias entre individuos o puntos de muestreo.

Ambos enfoques permiten interpretar cómo se organizan las poblaciones en el espacio y cómo se cuantifica su abundancia.

---

## ⚠️ Nota técnica

Los nombres de variables y hojas fueron definidos para mantener consistencia con el flujo del capítulo en el libro ANVIDEA.
