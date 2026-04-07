# Capítulo 3. Visualización gráfica de patrones climáticos

Material complementario para usuarios derivado del archivo `3_clima.qmd` del libro **ANVIDEA**.

Este capítulo integra análisis y visualización de datos climáticos, incluyendo:

- series temporales mensuales e interanuales
- climatogramas
- índice de Lang
- evapotranspiración potencial (ETP)
- balance hídrico tipo Thornthwaite–Mather

---

## 📁 Contenido

- `R/00_setup.R`  
  Configuración del entorno: carga de paquetes, verificación de dependencias y creación de carpetas.

- `R/01_casoA_series_climaticas.R`  
  Procesamiento y visualización de series de temperatura y precipitación (mensual e interanual).

- `R/02_casoB_climatogramas_balance_hidrico.R`  
  Construcción de climatogramas, cálculo del índice de Lang, estimación de ETP corregida y balance hídrico.

- `R/03_funciones_auxiliares.R`  
  Funciones reutilizables para:
  - orden de meses
  - clasificación climática
  - exportación de tablas
  - guardado de figuras

- `data/raw/LEAME_DATOS.txt`  
  Guía para ubicar correctamente los archivos de entrada.

- `outputs/`  
  Carpeta donde se generan automáticamente las salidas.

---

## 📊 Archivos de entrada requeridos

Ubique en:

data/raw/



los siguientes archivos:

- `datos.xlsx`
- `estaciones.xlsx`
- `bal_hid.R`

---

## 📄 Estructura esperada de los datos

### `datos.xlsx`

Debe contener las hojas:

- `serie_temp`
- `serie_precipit`
- `clima`

### `estaciones.xlsx`

Debe contener la hoja:

- `estaciones`

---

## ▶️ Orden de ejecución

Ejecute los scripts en el siguiente orden:

1. `R/00_setup.R`
2. `R/01_casoA_series_climaticas.R`
3. `R/02_casoB_climatogramas_balance_hidrico.R`

---

## 📤 Salidas

Las salidas se almacenan automáticamente en:

### Figuras

outputs/figuras/


### Tablas

outputs/tablas/


Incluyen:

- series climáticas transformadas
- índice de Lang por estación
- climatogramas
- balance hídrico mensual

---

## ⚠️ Consideraciones

- El script `00_setup.R` detiene la ejecución si faltan paquetes o datos.
- Los nombres de las columnas deben coincidir exactamente con los definidos en los scripts.
- El archivo `bal_hid.R` es indispensable para el cálculo del balance hídrico.
- Los scripts están diseñados para ejecutarse de forma secuencial y reproducible.

---

## 🎯 Alcance

Esta versión está orientada al usuario final del libro ANVIDEA:

- simplifica la ejecución del flujo analítico
- organiza los procedimientos en scripts independientes
- prioriza claridad, reproducibilidad y robustez

---

## 🔁 Contexto dentro del libro

Este capítulo forma parte de la **Unidad I (Análisis de datos)** y conecta:

- la manipulación de datos (Capítulo 1)
- la exploración gráfica (Capítulo 2)

con la interpretación ecológica de patrones climáticos.



