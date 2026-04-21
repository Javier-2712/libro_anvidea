# =========================================================
# ANVIDEA - Capítulo 6
# Patrones de distribución y estimación de la densidad
# ---------------------------------------------------------
# Archivo : run_cap6.R
# Propósito: ejecutar todo el capítulo 6 de forma secuencial
# =========================================================

cat("\n========================================\n")
cat("ANVIDEA - Cap\u00edtulo 6\n")
cat("Patrones de distribuci\u00f3n y estimaci\u00f3n de la densidad\n")
cat("========================================\n\n")

# ---------------------------------------------------------
# Verificar estructura mínima del capítulo
# ---------------------------------------------------------

archivos_requeridos <- c(
  "R/00_setup.R",
  "R/01_casoA_distribucion.R",
  "R/02_casoB_densidad.R",
  "R/03_funciones_auxiliares.R",
  "R/04_guardar_salidas_cap6.R",
  "R/05_render_reporte.R",
  "reporte_cap6.qmd"
)

faltantes <- archivos_requeridos[!file.exists(archivos_requeridos)]

if (length(faltantes) > 0) {
  stop(
    "Faltan los siguientes archivos:\n- ",
    paste(faltantes, collapse = "\n- ")
  )
}

# ---------------------------------------------------------
# Setup y funciones auxiliares
# ---------------------------------------------------------

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

# ---------------------------------------------------------
# Ejecutar casos guiados
# ---------------------------------------------------------

cat("\n[1/4] Caso A: patrones de distribuci\u00f3n...\n")
source("R/01_casoA_distribucion.R")

cat("[2/4] Caso B: estimaci\u00f3n de la densidad...\n")
source("R/02_casoB_densidad.R")

# ---------------------------------------------------------
# Guardar salidas
# ---------------------------------------------------------

cat("\n[3/4] Guardando salidas...\n")
source("R/04_guardar_salidas_cap6.R")

# ---------------------------------------------------------
# Renderizar reporte
# ---------------------------------------------------------

cat("\n[4/4] Renderizando reporte...\n")
source("R/05_render_reporte.R")

cat("\n========================================\n")
cat("Cap\u00edtulo 6 finalizado correctamente.\n")
cat("========================================\n")
