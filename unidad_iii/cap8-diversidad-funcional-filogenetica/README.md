<p align="left">
  <img src="../../Logo_GIEN.png" alt="GIEN - Grupo de Investigación en Ecología Neotropical" width="250">
</p>

# 🌿 Capítulo 8 — Diversidad funcional y filogenética

Este capítulo desarrolla el flujo reproducible de análisis de la **diversidad funcional (FD)** y la **diversidad filogenética (PD)** en R, integrando métricas alfa, descomposición con Rao y enfoques basados en números de Hill.

Corresponde al segundo capítulo de la **Unidad III — Ecología de comunidades** del manual ANVIDEA.

---

## 🎯 Propósito del capítulo

Desarrollar competencias para:

- preparar matrices biológicas, funcionales y filogenéticas para análisis comparativos
- estimar diversidad funcional alfa por sitio con métricas clásicas como FRic, FEve, FDiv, FDis y RaoQ
- comparar ensamblajes mediante descomposición de Rao para FD y PD
- estimar diversidad alfa con números de Hill
- estimar diversidad beta funcional y filogenética con números de Hill
- alinear árboles filogenéticos y matrices biológicas para comparaciones beta reproducibles

---

## 📁 Estructura del capítulo

```text
cap8-diversidad-funcional-filogenetica/
├── README.md
├── run_cap8.R
├── limpiar_outputs.R
├── reporte_cap8.qmd
├── R/
│   ├── 00_setup.R
│   ├── 01_casoA_clasica.R
│   ├── 02_casoB1_alfa_hill.R
│   ├── 03_casoB2_beta_hill.R
│   ├── 04_funciones_auxiliares.R
│   ├── 05_alineador.R
│   ├── 06_Rao.R
│   ├── 07_guardar_salidas_cap8.R
│   └── 08_render_reporte.R
├── data/
│   └── raw/
│       ├── datos.c8.xlsx       ← datos de abundancias, rasgos y coordenadas
│       ├── Rao.R               ← función original del libro (Villeger & Mouillot 2008)
│       ├── arbol_filo_alfa.rds ← árbol filogenético para análisis alfa
│       ├── arbol_filo_beta.rds ← árbol filogenético para análisis beta
│       └── biol_PD_beta.rds    ← matriz de abundancias para beta PD
└── outputs/
    ├── figuras/
    ├── tablas/
    └── reportes/
```

---

## 🗂️ Base de datos utilizada

| Archivo / hoja | Contenido |
|---|---|
| `datos.c8.xlsx` → `tax` | Abundancias por sitio (filas = sitios, columnas = especies) |
| `datos.c8.xlsx` → `tax1` | Tabla de abreviaturas y nombres científicos |
| `datos.c8.xlsx` → `rasgos` | Rasgos funcionales de las especies |
| `datos.c8.xlsx` → `coord` | Coordenadas espaciales de los sitios |
| `arbol_filo_alfa.rds` | Árbol filogenético para análisis alfa (PD) |
| `arbol_filo_beta.rds` | Árbol filogenético para análisis beta (PD) |

---

## ⚠️ Uso del material

Los scripts en R **no se ejecutan desde GitHub ni desde el portal web**.

Para utilizarlos:

1. Descarga la carpeta del capítulo o el repositorio completo.
2. Ábrela en RStudio como proyecto o establece el directorio de trabajo.
3. Ejecuta los scripts desde tu computador.

---

## ▶️ Formas de ejecución

### 🔹 Opción 1 — Ejecutar todo el capítulo

Desde la carpeta `cap8-diversidad-funcional-filogenetica/`:

```r
source("run_cap8.R")
```

Esto ejecuta automáticamente los casos del capítulo en orden, guarda las salidas y renderiza el reporte HTML.

---

### 🔹 Opción 2 — Ejecutar por casos

```r
source("R/00_setup.R")
source("R/04_funciones_auxiliares.R")
source("R/05_alineador.R")

# Caso A — Diversidad funcional y filogenética alfa (clásica)
source("R/01_casoA_clasica.R")

# Caso B.1 — Números de Hill (alfa)
source("R/02_casoB1_alfa_hill.R")

# Caso B.2 — Números de Hill (beta)
source("R/03_casoB2_beta_hill.R")

# Guardar y reportar
source("R/07_guardar_salidas_cap8.R")
source("R/08_render_reporte.R")
```

---

### 🔹 Opción 3 — Reiniciar salidas

```r
source("limpiar_outputs.R")
```

---

## 📦 Paquetes necesarios

```r
install.packages(c(
  "tidyverse", "readxl", "writexl", "FD", "cluster", "ape",
  "picante", "vegan", "ggrepel", "viridis", "cowplot",
  "ade4", "kableExtra"
))

# Paquetes desde GitHub:
remotes::install_github("AnneChao/iNEXT.3D")
remotes::install_github("AnneChao/iNEXTbeta3D")
```

---

## 🔁 Antes de usar con tus propios datos

> Esta sección es especialmente importante si vas a reemplazar los datos de ejemplo por los de tu propio estudio. El Caso A requiere que tres fuentes de información —abundancias (`tax`), rasgos (`rasgos`) y filogenia— estén **perfectamente alineadas a nivel de especie**. Si los nombres no coinciden o las estructuras son inconsistentes, el proceso se detendrá con errores de dimensiones.

### 1. Estandarización de nombres de especies

Los nombres científicos deben coincidir **exactamente** entre las hojas `tax` y `rasgos` del Excel:

- Sin tildes, sin espacios dobles, sin caracteres especiales.
- Formato uniforme: preferiblemente *Género especie* (mayúscula inicial solo en género).
- Sin abreviaturas ambiguas como `sp.`, `spp.`, `cf.`, `aff.` — a menos que sean deliberadas y consistentes en todas las hojas.
- La columna `LatinName` del sheet `rasgos` debe coincidir **carácter por carácter** con los encabezados de columna del sheet `tax`.

### 2. La columna `Abrev` es obligatoria y no se puede regenerar automáticamente

El sheet `rasgos` debe contener una columna `Abrev` con abreviaturas únicas de 4 caracteres para cada especie. Esta columna es la **clave de alineación interna** entre las matrices de abundancia, rasgos y filogenia.

> ⚠️ No uses `abbreviate()` de R para regenerarla. Esa función produce resultados distintos según el conjunto completo de nombres que recibe, lo que genera desajustes silenciosos entre matrices. Las abreviaturas deben ser fijas, únicas y definidas manualmente en el Excel.

Si añades o eliminas especies, actualiza `Abrev` manualmente asegurando que no haya duplicados.

### 3. Especies no encontradas en NCBI

El Caso A consulta NCBI para construir el árbol filogenético. Las especies no reconocidas por NCBI son **excluidas del análisis filogenético (PD)** pero permanecen en el análisis taxonómico (TD) y funcional (FD).

En el ejemplo del libro, 84 de 87 especies fueron encontradas (exclusión del 3.4%), lo que no compromete la comparabilidad entre dimensiones. Si en tu estudio la proporción de especies excluidas es mayor, o las especies faltantes son ecológicamente relevantes, considera verificar sus nombres en NCBI antes de correr el análisis, o consultar técnicas de inserción filogenética (*phylogenetic placement*) para incorporarlas manualmente al árbol.

Verifica tus nombres con:

```r
library(taxize)
classification(tu_vector_de_nombres, db = "ncbi")
```

### 4. Hoja de abundancias (`tax`)

Debe tener esta estructura:

```
Sites | Sites1 | especie1 | especie2 | ...
```

Requisitos:
- Abundancias estrictamente numéricas (≥ 0), sin NA ni caracteres extraños.
- Sin especies con abundancia total = 0 en todos los sitios.
- Sin filas o columnas completamente vacías.

### 5. Hoja de rasgos (`rasgos`)

Columnas mínimas requeridas:

| Columna | Tipo | Descripción |
|---|---|---|
| `Abrev` | texto | Abreviatura única de 4 caracteres |
| `LatinName` | texto | Nombre científico idéntico al usado en `tax` |
| Rasgos continuos | numérico | p. ej., `TrophicLevel`, `BodyLength` |
| Rasgos binarios | 0 / 1 | p. ej., `omnivory`, `piscivory` |

- No se permiten NA en ninguna columna de rasgos usada para calcular distancias de Gower.
- Evitar variables categóricas sin codificación numérica clara.

### 6. Árbol filogenético (Casos B.1 y B.2)

- Debe ser un objeto `phylo` con `tip.label` = nombres científicos.
- Los nombres de las puntas deben coincidir exactamente con `LatinName`.
- No incluir especies ambiguas, incompletas o no reconocidas.

### 7. Checklist rápida antes de ejecutar

- [ ] `LatinName` en `rasgos` coincide exactamente con los encabezados de `tax`
- [ ] La columna `Abrev` existe, es única y tiene exactamente 4 caracteres por especie
- [ ] No hay NA en columnas de rasgos
- [ ] No hay especies con abundancia total = 0
- [ ] Los nombres no tienen tildes, espacios dobles ni caracteres especiales
- [ ] Los `.rds` del árbol filogenético están en `data/raw/`
- [ ] Verificaste tus nombres en NCBI antes de correr el Caso A

---

## 💡 Recomendaciones generales

- Ejecuta los scripts en el orden propuesto: **Caso A → Caso B.1 → Caso B.2**
- Los análisis beta dependen de objetos preparados en pasos anteriores
- Verifica que los archivos `.rds` estén en `data/raw/`
- Mantén separados los **datos** (`data/raw/`) y las **funciones auxiliares** (`R/`)
- Usa `source("limpiar_outputs.R")` para reiniciar las salidas si necesitas correr todo desde cero

---

## 🔗 Relación con el libro

Este capítulo corresponde al análisis de **diversidad funcional y filogenética** del libro ANVIDEA. Los scripts reproducen y organizan los casos guiados del libro en una estructura operativa para el repositorio y el portal web.

La sección **"Recomendaciones para preparar los datos"** (págs. 497–498 del libro) desarrolla con mayor detalle las reglas de organización de datos descritas aquí. Se recomienda leerla antes de adaptar el flujo a datos propios.

---

## 📄 Licencia

- 💻 Código en R: MIT License
- 📘 Contenidos del libro: Creative Commons CC BY-NC 4.0

---

## ⬅️ Navegación

👉 Volver a la Unidad III:  
[unidad_iii/](../../unidad_iii/)

👉 Volver al repositorio principal:  
[libro_anvidea](https://github.com/Javier-2712/libro_anvidea)

👉 Volver al portal web:  
[javier-2712.github.io/libro_anvidea](https://javier-2712.github.io/libro_anvidea/)
