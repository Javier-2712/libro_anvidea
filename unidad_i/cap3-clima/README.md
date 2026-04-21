# Capítulo 3 — Análisis climático y ecológico en ambientes contrastantes

Este directorio reúne el material reproducible asociado al **Capítulo 3** de ANVIDEA.

El propósito de esta carpeta es que el repositorio no sea solo material complementario, sino una **extensión operativa del libro**, con fidelidad alta al capítulo original. El lector puede:

- ejecutar el caso guiado completo,
- contrastar el texto del libro con los códigos asociados,
- revisar cómo se generó cada tabla y cada figura,
- y reutilizar esta estructura como referencia para otros capítulos.

------------------------------------------------------------------------

## Estructura del capítulo

```text
cap3-clima/
├── README.md
├── run_cap3.R
├── limpiar_outputs.R
├── reporte_cap3.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_caso_clima_ecologia.R
│   ├── 02_funciones_auxiliares.R
│   ├── 03_guardar_salidas_cap3.R
│   └── 04_render_reporte.R
├── data/
│   └── raw/
│       ├── datos.c3.xlsx
│       └── bal_hid.R
└── outputs/
    ├── figuras/
    ├── tablas/
    └── reportes/
```

------------------------------------------------------------------------

## Opción 1. Ejecutar todo el capítulo

```r
source("run_cap3.R")
```

Esta es la opción recomendada para la mayoría de usuarios.

El archivo `run_cap3.R` coordina todo el flujo de trabajo en cuatro pasos:

1. cargar la configuración general
2. ejecutar el caso guiado
3. guardar todas las salidas
4. renderizar el reporte HTML

En otras palabras, **run_cap3.R es el script maestro del capítulo**.

### Resultado esperado

**En `outputs/figuras/`**

- `cap3_fig_temp_mensual.png`
- `cap3_fig_temp_anual.png`
- `cap3_fig_precipit_mensual.png`
- `cap3_fig_precipit_anual.png`
- `cap3_climatograma.png`
- `cap3_fig_lang.png`
- `cap3_balance_hidrico.png`

**En `outputs/tablas/`**

- tablas exportadas en formato `.xlsx`

**En `outputs/reportes/`**

- `resultado_cap3.RDS`
- `reporte_cap3.html`
- `reporte_cap3_files/`

------------------------------------------------------------------------

## Opción 2. Ejecutar por partes

Esta opción es útil para:

- depurar errores
- enseñar el caso guiado por secciones
- rehacer solo una parte del capítulo
- validar qué genera cada script

------------------------------------------------------------------------

### Paso 1. Configuración general

```r
source("R/00_setup.R")
```

**Aporte del script**

- instala y carga paquetes requeridos
- define rutas: `ruta_datos`, `ruta_figuras`, `ruta_tablas`, `ruta_reportes`
- define `archivo_datos` (ruta a `datos.c3.xlsx`)
- valida hojas requeridas: `serie_temp`, `serie_precipit`, `clima`
- carga `bal_hid.R` (función de balance hídrico)
- crea la estructura de carpetas en `outputs/`

Sin este archivo, los demás scripts fallarán.

------------------------------------------------------------------------

### Paso 2. Caso guiado

```r
source("R/01_caso_clima_ecologia.R")
```

**Aporte del script**

Ejecuta el caso guiado (corazón pedagógico):

- lee y organiza la tabla de estaciones
- construye figuras de temperatura mensual e interanual (Figs. 3.1 y 3.2)
- construye figuras de precipitación mensual e interanual (Figs. 3.3 y 3.5)
- genera climatogramas compuestos por estación (Fig. 3.6)
- calcula el índice de Lang y su clasificación (Fig. 3.7)
- estima el balance hídrico mensual (Fig. 3.8)
- construye resumen climático y ecológico final (Tablas 3.4–3.6)
- deja todos los objetos y figuras disponibles en el entorno para el paso 3

------------------------------------------------------------------------

### Paso 3. Guardar salidas

```r
source("R/03_guardar_salidas_cap3.R")
```

**Aporte del script**

Exporta todas las salidas generadas por el caso guiado. No contiene lógica pedagógica ni análisis. Solo:

- `write_xlsx()` — tablas en formato Excel
- `ggsave()` — figuras en PNG
- `saveRDS()` — objeto consolidado `.RDS` para el reporte

------------------------------------------------------------------------

### Paso 4. Renderizar el reporte

```r
source("R/04_render_reporte.R")
```

**Aporte del script**

No realiza análisis nuevos. Su función exclusiva es:

- llamar a Quarto para renderizar `reporte_cap3.qmd`
- mover el HTML resultante a `outputs/reportes/`

------------------------------------------------------------------------

## Opción 3. Reiniciar salidas y volver a ejecutar

Para borrar todas las salidas generadas y dejar el capítulo listo para una ejecución limpia desde cero, ejecutar desde la carpeta raíz del capítulo:

```r
source("limpiar_outputs.R")
```

Este script elimina el contenido de `outputs/figuras/`, `outputs/tablas/` y `outputs/reportes/`. En sesiones interactivas de RStudio pedirá confirmación antes de borrar. **Los datos originales en `data/raw/` no se ven afectados.**

Luego ejecutar nuevamente:

```r
source("run_cap3.R")
```

------------------------------------------------------------------------

## Recomendación de uso

**Usuario principiante**

```r
source("run_cap3.R")
```

**Usuario intermedio**

```r
source("R/00_setup.R")
source("R/01_caso_clima_ecologia.R")
source("R/03_guardar_salidas_cap3.R")
source("R/04_render_reporte.R")
```

**Usuario avanzado**

Revisar y ejecutar directamente los scripts internos de la carpeta `R/`, contrastando sus pasos con el capítulo del libro.

------------------------------------------------------------------------

## Nota final

El propósito de esta organización es que el lector no solo observe resultados climáticos y ecológicos, sino que también comprenda el proceso analítico que conduce a ellos y su utilidad dentro de la interpretación ambiental.

El script `01_caso_clima_ecologia.R` es el núcleo pedagógico del capítulo. El script `03_guardar_salidas_cap3.R` es deliberadamente técnico y separado, para que el estudiante pueda enfocarse en la secuencia analítica sin distracciones de exportación.
