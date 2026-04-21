# =========================================================
# ANVIDEA - Capítulo 1
# Archivo: 00_setup.R
# Propósito: configuración general del capítulo 1
#            Fundamentos de manipulación de datos
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 1\n")
cat("Fundamentos de manipulación de datos\n")
cat("Cargando configuración general...\n")
cat("========================================\n")

# ---------------------------------------------------------
# 1. Paquetes requeridos
# ---------------------------------------------------------

required_packages <- c(
  "tidyverse",
  "readxl",
  "writexl",
  "janitor",
  "kableExtra",
  "viridis",
  "knitr",
  "tidyr"
)

missing_packages <- required_packages[
  !sapply(required_packages, requireNamespace, quietly = TRUE)
]

if (length(missing_packages) > 0) {
  message(
    "Instalando paquetes faltantes: ",
    paste(missing_packages, collapse = ", ")
  )
  install.packages(missing_packages, dependencies = TRUE)
}

invisible(lapply(required_packages, library, character.only = TRUE))

# ---------------------------------------------------------
# 2. Rutas del proyecto
# ---------------------------------------------------------

root_dir      <- getwd()
ruta_datos    <- file.path(root_dir, "data", "raw")
ruta_scripts  <- file.path(root_dir, "R")
ruta_outputs  <- file.path(root_dir, "outputs")
ruta_figuras  <- file.path(ruta_outputs, "figuras")
ruta_tablas   <- file.path(ruta_outputs, "tablas")
ruta_reportes <- file.path(ruta_outputs, "reportes")

# ---------------------------------------------------------
# 3. Crear carpetas si no existen
# ---------------------------------------------------------

invisible(lapply(
  c(ruta_outputs, ruta_figuras, ruta_tablas, ruta_reportes),
  dir.create, recursive = TRUE, showWarnings = FALSE
))

# ---------------------------------------------------------
# 4. Cargar funciones auxiliares
# ---------------------------------------------------------

archivo_funciones <- file.path(ruta_scripts, "03_funciones_auxiliares.R")

if (file.exists(archivo_funciones)) {
  source(archivo_funciones)
} else {
  warning("No se encontró 03_funciones_auxiliares.R")
}

# ---------------------------------------------------------
# 5. Rutas de archivos de datos y hoja fisicoquímica
# ---------------------------------------------------------

archivo_plancton <- file.path(ruta_datos, "plancton.xlsx")
archivo_invert   <- file.path(ruta_datos, "invert.xlsx")

# Detectar hoja fisicoquímica de invert.xlsx
hoja_fq <- NULL
if (file.exists(archivo_invert)) {
  hojas_invert <- readxl::excel_sheets(archivo_invert)
  hoja_fq <- hojas_invert[stringr::str_detect(
    stringr::str_to_lower(iconv(hojas_invert, to = "ASCII//TRANSLIT")),
    "fquim|fisico"
  )]
  if (length(hoja_fq) > 0) {
    hoja_fq <- hoja_fq[1]
  } else {
    warning("No se encontró hoja fisicoquímica en invert.xlsx.")
    hoja_fq <- NULL
  }
}

# ---------------------------------------------------------
# 6. Verificación de insumos principales
# ---------------------------------------------------------

faltantes <- c(archivo_plancton, archivo_invert)[
  !file.exists(c(archivo_plancton, archivo_invert))
]

if (length(faltantes) > 0) {
  warning(
    "Faltan archivos en data/raw:\n",
    paste("-", basename(faltantes), collapse = "\n")
  )
}

# ---------------------------------------------------------
# 7. Opciones globales
# ---------------------------------------------------------

options(
  scipen = 999,
  dplyr.summarise.inform = FALSE,
  width = 120
)

cat("Configuración general cargada correctamente.\n")
