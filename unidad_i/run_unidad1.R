# =========================================================
# ANVIDEA - Unidad I
# Archivo: run_unidad1.R
# Propósito: ejecutar de forma secuencial los capítulos 1, 2 y 3
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Unidad I\n")
cat("Análisis de datos ecológicos\n")
cat("========================================\n")

# ---------------------------------------------------------
# Verificar estructura general
# ---------------------------------------------------------

rutas_requeridas <- c(
  "cap1-datos/R/00_setup.R",
  "cap1-datos/R/03_funciones_auxiliares.R",
  "cap1-datos/R/01_casoA_mesozooplancton.R",
  "cap1-datos/R/02_casoB_macroinvertebrados.R",
  "cap2-visualizacion-exploratoria/R/00_setup.R",
  "cap2-visualizacion-exploratoria/R/03_funciones_auxiliares.R",
  "cap2-visualizacion-exploratoria/R/01_casoA_plancton_exploracion.R",
  "cap2-visualizacion-exploratoria/R/02_casoB_macroinvertebrados_exploracion.R",
  "cap3-clima/R/00_setup.R",
  "cap3-clima/R/03_funciones_auxiliares.R",
  "cap3-clima/R/01_casoA_series_climaticas.R",
  "cap3-clima/R/02_casoB_climatogramas_balance_hidrico.R"
)

faltantes <- rutas_requeridas[!file.exists(rutas_requeridas)]

if (length(faltantes) > 0) {
  stop(
    "No se encontraron los siguientes archivos requeridos:\n",
    paste(faltantes, collapse = "\n")
  )
}

# ---------------------------------------------------------
# Capítulo 1 - Manipulación de datos
# ---------------------------------------------------------

cat("\n----------------------------------------\n")
cat("Ejecutando Capítulo 1 - Manipulación de datos\n")
cat("----------------------------------------\n")

source("cap1-datos/R/00_setup.R")
source("cap1-datos/R/03_funciones_auxiliares.R")
source("cap1-datos/R/01_casoA_mesozooplancton.R")
source("cap1-datos/R/02_casoB_macroinvertebrados.R")

cat("Capítulo 1 completado.\n")

# ---------------------------------------------------------
# Capítulo 2 - Visualización exploratoria
# ---------------------------------------------------------

cat("\n----------------------------------------\n")
cat("Ejecutando Capítulo 2 - Visualización exploratoria\n")
cat("----------------------------------------\n")

source("cap2-visualizacion-exploratoria/R/00_setup.R")
source("cap2-visualizacion-exploratoria/R/03_funciones_auxiliares.R")
source("cap2-visualizacion-exploratoria/R/01_casoA_plancton_exploracion.R")
source("cap2-visualizacion-exploratoria/R/02_casoB_macroinvertebrados_exploracion.R")

cat("Capítulo 2 completado.\n")

# ---------------------------------------------------------
# Capítulo 3 - Análisis climático
# ---------------------------------------------------------

cat("\n----------------------------------------\n")
cat("Ejecutando Capítulo 3 - Análisis climático\n")
cat("----------------------------------------\n")

source("cap3-clima/R/00_setup.R")
source("cap3-clima/R/03_funciones_auxiliares.R")
source("cap3-clima/R/01_casoA_series_climaticas.R")
source("cap3-clima/R/02_casoB_climatogramas_balance_hidrico.R")

cat("Capítulo 3 completado.\n")

# ---------------------------------------------------------
# Fin de la Unidad I
# ---------------------------------------------------------

cat("\n========================================\n")
cat("Unidad I ejecutada correctamente\n")
cat("Revise las salidas en las carpetas outputs/ de cada capítulo.\n")
cat("========================================\n")
