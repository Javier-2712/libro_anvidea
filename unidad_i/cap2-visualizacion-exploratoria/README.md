# Capítulo 2 — Visualización exploratoria de datos ecológicos

Este directorio reúne el material reproducible asociado al **Capítulo 2** de ANVIDEA.

El propósito de esta carpeta es permitir que el lector ejecute los ejemplos y casos guiados del capítulo de forma flexible, ya sea:

- ejecutando todo el capítulo,
- trabajando por partes,
- o reiniciando las salidas para nuevas pruebas.

------------------------------------------------------------------------

## Estructura del capítulo

```text
cap2-visualizacion-exploratoria/
├── README.md
├── run_cap2.R
├── limpiar_outputs.R
├── reporte_cap2.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_casoA_mesozooplancton.R
│   ├── 02_casoB_macroinvertebrados.R
│   ├── 03_funciones_auxiliares.R
│   ├── 04_guardar_salidas_cap2.R
│   └── 05_render_reporte.R
├── data/
│   └── raw/
│       ├── plancton.xlsx
│       └── invert.xlsx
└── outputs/
    ├── figuras/
    ├── tablas/
    └── reportes/
```

------------------------------------------------------------------------

## Opción 1. Ejecutar todo el capítulo

```r
source("run_cap2.R")
```

Esta es la opción recomendada para el usuario que desea ejecutar el capítulo completo.

El archivo `run_cap2.R` coordina todo el flujo de trabajo en cinco pasos:

1. cargar la configuración general
2. ejecutar el Caso A
3. ejecutar el Caso B
4. guardar todas las salidas
5. renderizar el reporte final

En otras palabras, **run_cap2.R es el director de orquesta del capítulo**.

### Resultado esperado

**En `outputs/figuras/`**

- figuras del Caso A (`casoA_fig_*.png`)
- figuras del Caso B (`casoB_fig_*.png`)

**En `outputs/tablas/`**

- tablas exportadas en formato `.xlsx`

**En `outputs/reportes/`**

- `resultado_casoA.rds`
- `resultado_casoB.rds`
- `reporte_cap2.html`
- `reporte_cap2_files/`

------------------------------------------------------------------------

## Opción 2. Ejecutar por partes

Esta opción es útil para:

- depurar errores
- enseñar un caso guiado específico
- rehacer solo una parte del capítulo
- validar qué genera cada script

------------------------------------------------------------------------

### Paso 1. Configuración general

```r
source("R/00_setup.R")
```

**Aporte del script**

Prepara el entorno de trabajo:

- instala y carga paquetes requeridos
- define rutas: `ruta_datos`, `ruta_figuras`, `ruta_tablas`, `ruta_reportes`
- carga las funciones auxiliares (`03_funciones_auxiliares.R`)
- crea la estructura de carpetas en `outputs/`
- verifica que los archivos de datos estén en `data/raw/`

Sin este archivo, los demás scripts fallarán.

------------------------------------------------------------------------

### Paso 2. Caso A — Mesozooplancton estuarino

```r
source("R/01_casoA_mesozooplancton.R")
```

**Aporte del script**

Ejecuta el análisis del Caso A (corazón pedagógico):

- lee `plancton.xlsx` (hoja `Riqueza`)
- transforma datos al formato ancho (`biol1`) con abreviaturas y columna `Ab`
- demuestra operaciones tidyverse: `select`, `filter`, `mutate`, `pivot`, `join`
- genera correlogramas, dispersión por pares, histogramas de densidad y dispersión X-Y
- construye cajas y bigotes por estación, capa y variables ambientales (terciles)
- genera figuras de burbujas con datos hipotéticos y reales
- deja todos los objetos y figuras disponibles en el entorno para el paso 4

------------------------------------------------------------------------

### Paso 3. Caso B — Macroinvertebrados bentónicos fluviales

```r
source("R/02_casoB_macroinvertebrados.R")
```

**Aporte del script**

Ejecuta el análisis del Caso B (corazón pedagógico):

- lee `invert.xlsx` (hojas `Taxones1`, `Taxones2`, fisicoquímica)
- abrevia nombres de familias y construye catálogo de taxones
- selecciona los 15 taxones más abundantes (`biol2`, `biol3`)
- calcula promedios ambientales por sitio (`amb1`)
- genera correlogramas de taxones y ambiente-biota
- construye cajas por sitio, microhábitat y combinación sitio × microhábitat
- genera barras de dominancia y barras con error estándar
- genera figura de burbujas: oxígeno × taxón × sitio
- deja todos los objetos y figuras disponibles en el entorno para el paso 4

------------------------------------------------------------------------

### Paso 4. Guardar salidas

```r
source("R/04_guardar_salidas_cap2.R")
```

**Aporte del script**

Exporta todas las salidas generadas por los casos A y B. No contiene lógica pedagógica ni análisis. Solo:

- `write_xlsx()` — tablas en formato Excel
- `ggsave()` — figuras ggplot2 en PNG
- `saveRDS()` — objetos consolidados `.rds` para el reporte

Genera:
- `outputs/tablas/casoA_*.xlsx` y `casoB_*.xlsx`
- `outputs/figuras/casoA_*.png` y `casoB_*.png`
- `outputs/reportes/resultado_casoA.rds`
- `outputs/reportes/resultado_casoB.rds`

------------------------------------------------------------------------

### Paso 5. Renderizar el reporte

```r
source("R/05_render_reporte.R")
```

**Aporte del script**

No realiza análisis nuevos. Su función exclusiva es:

- llamar a Quarto para renderizar `reporte_cap2.qmd`
- mover el HTML resultante a `outputs/reportes/`

El reporte lee los `.rds` generados en el paso 4 y muestra figuras y tablas ya guardadas en disco.

------------------------------------------------------------------------

## Opción 3. Reiniciar salidas y volver a ejecutar

Para borrar todas las salidas generadas y dejar el capítulo listo para una ejecución limpia desde cero, ejecutar desde la carpeta raíz del capítulo:

```r
source("limpiar_outputs.R")
```

Este script elimina el contenido de `outputs/figuras/`, `outputs/tablas/` y `outputs/reportes/`. En sesiones interactivas de RStudio pedirá confirmación antes de borrar. **Los datos originales en `data/raw/` no se ven afectados.**

Luego ejecutar nuevamente:

```r
source("run_cap2.R")
```

o por partes siguiendo los pasos anteriores.

------------------------------------------------------------------------

## Recomendación de uso

**Usuario principiante**

```r
source("run_cap2.R")
```

**Usuario intermedio**

```r
source("R/00_setup.R")
source("R/01_casoA_mesozooplancton.R")
source("R/04_guardar_salidas_cap2.R")
source("R/05_render_reporte.R")
```

o solo el Caso B:

```r
source("R/00_setup.R")
source("R/02_casoB_macroinvertebrados.R")
source("R/04_guardar_salidas_cap2.R")
source("R/05_render_reporte.R")
```

**Usuario avanzado**

Revisar y ejecutar directamente los scripts internos de la carpeta `R/`.

------------------------------------------------------------------------

## Nota final

El propósito de esta organización es que el lector no solo observe resultados gráficos, sino que también comprenda el proceso exploratorio que conduce a ellos y su utilidad en el análisis ecológico.

Los scripts `01_casoA_mesozooplancton.R` y `02_casoB_macroinvertebrados.R` son el núcleo pedagógico del capítulo. El script `04_guardar_salidas_cap2.R` es deliberadamente técnico y separado, para que el estudiante pueda enfocarse en la secuencia analítica sin distracciones de exportación.
