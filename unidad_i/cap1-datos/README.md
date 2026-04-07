# ANVIDEA — Capítulo 1: Fundamentos de manipulación de datos

Este repositorio piloto organiza el **código del Capítulo 1** del libro en una versión más limpia para usuarios.

## Estructura

- `R/00_setup.R`: carga y verificación de paquetes.
- `R/01_casoA_mesozooplancton.R`: flujo principal del caso estuarino con `plancton.xlsx`.
- `R/02_casoB_macroinvertebrados.R`: flujo principal del caso fluvial con `invert.xlsx`.
- `R/03_funciones_auxiliares.R`: funciones reutilizables.
- `data/raw/`: ubique aquí los archivos de entrada.

## Archivos esperados

Coloque en `data/raw/`:

- `plancton.xlsx` con la hoja `Riqueza`
- `invert.xlsx` con las hojas `Taxones1`, `Taxones2` y `fquímicos`

## Flujo recomendado

```r
source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")
source("R/01_casoA_mesozooplancton.R")
source("R/02_casoB_macroinvertebrados.R")
```

## Criterios usados para esta versión de usuario

Se eliminaron del `.qmd`:

- bloques puramente editoriales de Quarto,
- tablas de validación hechas solo para el libro,
- llamadas a `knitr::include_graphics()`,
- texto pedagógico no necesario para ejecutar el análisis.

Se conservaron y reorganizaron:

- importación de datos,
- transformación con `dplyr` y `tidyr`,
- resúmenes ecológicos,
- categorizaciones,
- uniones entre tablas,
- gráficos reproducibles con `ggplot2`.

## Siguiente paso sugerido

Si esta estructura te convence, se puede replicar al resto de los capítulos y luego consolidar un repositorio general por unidades o por capítulos.
