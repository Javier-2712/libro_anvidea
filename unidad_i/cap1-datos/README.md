# Capítulo 1 — Fundamentos de manipulación de datos

Este directorio reúne el material reproducible asociado al **Capítulo 1** de ANVIDEA.

Su propósito es que el lector no solo consulte resultados finales, sino que pueda **ejecutar, comprender y reutilizar** el flujo completo de trabajo presentado en el libro.

------------------------------------------------------------------------

## Estructura del capítulo

```text
cap1-datos/
├── README.md
├── run_cap1.R
├── limpiar_outputs.R
├── reporte_cap1.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_casoA_mesozooplancton.R
│   ├── 02_casoB_macroinvertebrados.R
│   ├── 03_funciones_auxiliares.R
│   ├── 04_guardar_salidas_cap1.R
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
source("run_cap1.R")
```

Esta es la opción recomendada para la mayoría de usuarios.

El archivo `run_cap1.R` coordina todo el flujo de trabajo en cinco pasos:

1. cargar la configuración general
2. ejecutar el Caso A
3. ejecutar el Caso B
4. guardar todas las salidas
5. renderizar el reporte HTML

En otras palabras, **run_cap1.R es el script maestro del capítulo**.

### Resultado esperado

**En `outputs/figuras/`**

- figuras del Caso A (`casoA_fig_*.png`)
- figuras del Caso B (`casoB_fig_*.png`)

**En `outputs/tablas/`**

- tablas exportadas en formato `.xlsx`

**En `outputs/reportes/`**

- `resultado_casoA.rds`
- `resultado_casoB.rds`
- `reporte_cap1.html`
- carpeta de recursos HTML asociada

------------------------------------------------------------------------

## Opción 2. Ejecutar por partes

Esta opción es útil para:

- depurar errores
- enseñar un bloque específico
- rehacer una parte puntual
- validar qué genera cada script

------------------------------------------------------------------------

### Paso 1. Configuración general

```r
source("R/00_setup.R")
```

**Aporte del script**

- instala y carga paquetes requeridos
- define rutas: `ruta_datos`, `ruta_figuras`, `ruta_tablas`, `ruta_reportes`
- define rutas de archivos: `archivo_plancton`, `archivo_invert`, `hoja_fq`
- carga las funciones auxiliares (`03_funciones_auxiliares.R`)
- crea la estructura de carpetas en `outputs/`

Sin este archivo, los demás scripts fallarán.

------------------------------------------------------------------------

### Paso 2. Caso A — Mesozooplancton estuarino

```r
source("R/01_casoA_mesozooplancton.R")
```

**Aporte del script**

Ejecuta el análisis del Caso A (corazón pedagógico):

- lee `plancton.xlsx` (hoja `Riqueza`)
- demuestra operaciones tidyverse: `select`, `filter`, `mutate`, `summarise`, `pivot`, `left_join`
- abrevia taxones y construye formato ancho (`biol_ancho`)
- selecciona los 5 taxones más abundantes
- visualiza factores con cajas y bigotes
- categoriza salinidad por terciles y por criterio ecológico estuarino
- deja todos los objetos y figuras disponibles en el entorno para el paso 4

------------------------------------------------------------------------

### Paso 3. Caso B — Macroinvertebrados bentónicos fluviales

```r
source("R/02_casoB_macroinvertebrados.R")
```

**Aporte del script**

Ejecuta el análisis del Caso B (corazón pedagógico):

- lee `invert.xlsx` (hojas `Taxones1`, `Taxones2`, fisicoquímica)
- selecciona, filtra y crea nuevas variables
- transforma abundancias con `log1p` y convierte a formato largo
- une datos bióticos y fisicoquímicos (`left_join`)
- abrevia nombres de familias
- identifica los 5 taxones dominantes
- categoriza oxígeno disuelto y cruza con dominantes
- calcula métricas comunitarias (abundancia total, riqueza)
- genera figuras de dominancia y relaciones ambiente-biota

------------------------------------------------------------------------

### Paso 4. Guardar salidas

```r
source("R/04_guardar_salidas_cap1.R")
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

- llamar a Quarto para renderizar `reporte_cap1.qmd`
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
source("run_cap1.R")
```

o por partes siguiendo los pasos anteriores.

------------------------------------------------------------------------

## Recomendación de uso

**Usuario principiante**

```r
source("run_cap1.R")
```

**Usuario intermedio**

```r
source("R/00_setup.R")
source("R/01_casoA_mesozooplancton.R")
source("R/04_guardar_salidas_cap1.R")
source("R/05_render_reporte.R")
```

o solo el Caso B:

```r
source("R/00_setup.R")
source("R/02_casoB_macroinvertebrados.R")
source("R/04_guardar_salidas_cap1.R")
source("R/05_render_reporte.R")
```

**Usuario avanzado**

Editar y ejecutar directamente los scripts internos de la carpeta `R/`.

------------------------------------------------------------------------

## Nota final

El propósito de esta organización es que el lector no solo observe resultados, sino que comprenda el proceso completo de manipulación de datos ecológicos y pueda transferir estas herramientas a nuevos problemas de investigación, docencia o consultoría ambiental.

Los scripts `01_casoA_mesozooplancton.R` y `02_casoB_macroinvertebrados.R` son el núcleo pedagógico del capítulo. El script `04_guardar_salidas_cap1.R` es deliberadamente técnico y separado, para que el estudiante pueda enfocarse en la secuencia analítica sin distracciones de exportación.
