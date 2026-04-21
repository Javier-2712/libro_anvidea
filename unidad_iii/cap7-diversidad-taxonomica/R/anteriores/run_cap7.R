# =========================================================
# ANVIDEA - Capítulo 6
# Archivo: run_cap6.R
# Propósito: ejecutar todo el capítulo 6 de forma secuencial
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 6\n")
cat("Patrones de distribución y estimación de la densidad\n")
cat("========================================\n")
cat("Este script ejecutará todo el capítulo 6.\n")
cat("Se correrán los casos A y B, se guardarán las salidas y luego se renderizará el reporte.\n\n")

# ---------------------------------------------------------
# Verificar estructura mínima del capítulo
# ---------------------------------------------------------

rutas_requeridas <- c(
  "R",
  "data/raw",
  "outputs",
  "outputs/figuras",
  "outputs/tablas",
  "outputs/reportes",
  "R/00_setup.R",
  "R/01_casoA_distribucion.R",
  "R/02_casoB_densidad.R",
  "R/03_funciones_auxiliares.R",
  "R/04_guardar_salidas_cap6.R",
  "R/06_render_reporte.R",
  "reporte_cap6.qmd"
)

faltantes <- rutas_requeridas[!file.exists(rutas_requeridas)]

if (length(faltantes) > 0) {
  stop(
    "Error: faltan los siguientes archivos o carpetas:\n- ",
    paste(faltantes, collapse = "\n- ")
  )
}

# ---------------------------------------------------------
# Cargar configuración general
# ---------------------------------------------------------

source("R/00_setup.R")

cat("\n[1/5] Configuración general cargada correctamente.\n")

# ---------------------------------------------------------
# Ejecutar Caso A
# ---------------------------------------------------------

cat("\n[2/5] Ejecutando Caso A: patrones de distribución...\n")
source("R/01_casoA_distribucion.R")
cat("[2/5] Caso A finalizado.\n")

# ---------------------------------------------------------
# Ejecutar Caso B
# ---------------------------------------------------------

cat("\n[3/5] Ejecutando Caso B: estimación de la densidad...\n")
source("R/02_casoB_densidad.R")
cat("[3/5] Caso B finalizado.\n")

# ---------------------------------------------------------
# Guardar salidas consolidadas del capítulo
# ---------------------------------------------------------

cat("\n[4/5] Guardando salidas del capítulo...\n")
source("R/04_guardar_salidas_cap6.R")
cat("[4/5] Salidas guardadas.\n")

# ---------------------------------------------------------
# Renderizar reporte del capítulo
# ---------------------------------------------------------

cat("\n[5/5] Renderizando reporte del capítulo...\n")
source("R/06_render_reporte.R")
cat("[5/5] Reporte finalizado.\n")

cat("\n========================================\n")
cat("Capítulo 6 ejecutado correctamente.\n")
cat("Revise las salidas en:\n")
cat("- outputs/figuras/\n")
cat("- outputs/tablas/\n")
cat("- outputs/reportes/\n")
cat("========================================\n")
