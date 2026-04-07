# =========================================================
# ANVIDEA - Unidad II
# Archivo: run_unidad2_ajustado.R
# Propósito: ejecutar la Unidad II de forma progresiva
# Nota: actualmente el run integra los capítulos 4, 5 y 6.
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Unidad II\n")
cat("Ecología de poblaciones\n")
cat("========================================\n")

# ---------------------------------------------------------
# Verificar estructura mínima actualmente ajustada
# ---------------------------------------------------------

rutas_requeridas <- c(
  # Capítulo 4
  "cap4-modelos-poblacionales/R/00_setup.R",
  "cap4-modelos-poblacionales/R/03_funciones_auxiliares.R",
  "cap4-modelos-poblacionales/R/01_casoA_modelo_exponencial.R",
  "cap4-modelos-poblacionales/R/02_casoB_modelo_logistico.R",

  # Capítulo 5
  "cap5-tablas-vida-modelos-matriciales/R/00_setup.R",
  "cap5-tablas-vida-modelos-matriciales/R/05_funciones_auxiliares.R",
  "cap5-tablas-vida-modelos-matriciales/R/01_casoA1_tabla_vida_edad.R",
  "cap5-tablas-vida-modelos-matriciales/R/02_casoA2_tabla_vida_gotelli.R",
  "cap5-tablas-vida-modelos-matriciales/R/03_casoB_modelo_leslie.R",
  "cap5-tablas-vida-modelos-matriciales/R/04_casoC_modelo_lefkovitch.R",

  # Capítulo 6
  "cap6-distribucion-densidad/R/00_setup.R",
  "cap6-distribucion-densidad/R/03_funciones_auxiliares.R",
  "cap6-distribucion-densidad/R/01_casoA_patrones_distribucion.R",
  "cap6-distribucion-densidad/R/02_casoB_estimacion_densidad.R"
)

faltantes <- rutas_requeridas[!file.exists(rutas_requeridas)]

if (length(faltantes) > 0) {
  stop(
    "No se encontraron los siguientes archivos requeridos para la Unidad II:\n",
    paste(faltantes, collapse = "\n")
  )
}

# ---------------------------------------------------------
# Capítulo 4 - Modelos poblacionales
# ---------------------------------------------------------

cat("\n----------------------------------------\n")
cat("Ejecutando Capítulo 4 - Modelos poblacionales\n")
cat("----------------------------------------\n")

source("cap4-modelos-poblacionales/R/00_setup.R")
source("cap4-modelos-poblacionales/R/03_funciones_auxiliares.R")
source("cap4-modelos-poblacionales/R/01_casoA_modelo_exponencial.R")
source("cap4-modelos-poblacionales/R/02_casoB_modelo_logistico.R")

cat("Capítulo 4 completado.\n")

# ---------------------------------------------------------
# Capítulo 5 - Tablas de vida y modelos matriciales
# ---------------------------------------------------------

cat("\n----------------------------------------\n")
cat("Ejecutando Capítulo 5 - Tablas de vida y modelos matriciales\n")
cat("----------------------------------------\n")

source("cap5-tablas-vida-modelos-matriciales/R/00_setup.R")
source("cap5-tablas-vida-modelos-matriciales/R/05_funciones_auxiliares.R")

# Caso A.1 - Tablas de vida con cementerios
source("cap5-tablas-vida-modelos-matriciales/R/01_casoA1_tabla_vida_edad.R")

# Caso A.2 - Tabla de vida clásica (Gotelli)
source("cap5-tablas-vida-modelos-matriciales/R/02_casoA2_tabla_vida_gotelli.R")

# Caso B - Modelo de Leslie
source("cap5-tablas-vida-modelos-matriciales/R/03_casoB_modelo_leslie.R")

# Caso C - Modelo de Lefkovitch
source("cap5-tablas-vida-modelos-matriciales/R/04_casoC_modelo_lefkovitch.R")

cat("Capítulo 5 completado.\n")

# ---------------------------------------------------------
# Capítulo 6 - Distribución y densidad
# ---------------------------------------------------------

cat("\n----------------------------------------\n")
cat("Ejecutando Capítulo 6 - Distribución y densidad\n")
cat("----------------------------------------\n")

source("cap6-distribucion-densidad/R/00_setup.R")
source("cap6-distribucion-densidad/R/03_funciones_auxiliares.R")

# Caso A - Patrones de distribución
source("cap6-distribucion-densidad/R/01_casoA_patrones_distribucion.R")

# Caso B - Estimación de densidad
source("cap6-distribucion-densidad/R/02_casoB_estimacion_densidad.R")

cat("Capítulo 6 completado.\n")

# ---------------------------------------------------------
# Fin de la Unidad II
# ---------------------------------------------------------

cat("\n========================================\n")
cat("Unidad II ejecutada completamente\n")
cat("Estado actual: Capítulos 4, 5 y 6 integrados y validados\n")
cat("========================================\n")
