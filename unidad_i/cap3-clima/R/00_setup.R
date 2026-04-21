# =========================================================
# ANVIDEA - Capítulo 3
# Archivo: 00_setup.R
# Propósito: configuración general del capítulo 3
#            Análisis climático y ecológico en ambientes contrastantes
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 3\n")
cat("Análisis climático y ecológico en ambientes contrastantes\n")
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
  "scales",
  "viridis",
  "knitr",
  "kableExtra",
  "cowplot"
)

missing_packages <- required_packages[
  !required_packages %in% installed.packages()[, "Package"]
]

if (length(missing_packages) > 0) {
  message("Instalando paquetes faltantes: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, dependencies = TRUE)
}

invisible(lapply(required_packages, library, character.only = TRUE))

# ---------------------------------------------------------
# 2. Rutas del proyecto
# ---------------------------------------------------------

root_dir      <- getwd()
ruta_scripts  <- file.path(root_dir, "R")
ruta_datos    <- file.path(root_dir, "data", "raw")
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

archivo_funciones <- file.path(ruta_scripts, "02_funciones_auxiliares.R")

if (file.exists(archivo_funciones)) {
  source(archivo_funciones)
} else {
  warning("No se encontró 02_funciones_auxiliares.R")
}

# ---------------------------------------------------------
# 5. Ruta del archivo de datos y validación de hojas
# ---------------------------------------------------------

archivo_datos <- file.path(ruta_datos, "datos.c3.xlsx")

if (!file.exists(archivo_datos)) {
  stop("No se encontró 'datos.c3.xlsx' en data/raw/", call. = FALSE)
}

hojas_datos           <- readxl::excel_sheets(archivo_datos)
hojas_datos_requeridas <- c("serie_temp", "serie_precipit", "clima")
faltan_hojas           <- setdiff(hojas_datos_requeridas, hojas_datos)

if (length(faltan_hojas) > 0) {
  stop(
    "En 'datos.c3.xlsx' faltan las siguientes hojas:\n- ",
    paste(faltan_hojas, collapse = "\n- "),
    call. = FALSE
  )
}

# ---------------------------------------------------------
# 6. Cargar función de balance hídrico (bal_hid.R)
# ---------------------------------------------------------

archivo_balhid <- file.path(ruta_datos, "bal_hid.R")

if (file.exists(archivo_balhid)) {
  source(archivo_balhid)
} else {
  stop("No se encontró bal_hid.R en data/raw/", call. = FALSE)
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
