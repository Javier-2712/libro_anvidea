# =========================================================
# ANVIDEA - Unidad II
# Archivo: run_unidad2.R
# Propósito: ejecutar secuencialmente los capítulos 4, 5 y 6
#            desde la raíz de la Unidad II
# Uso: source("run_unidad2.R")  desde la carpeta unidad_ii/
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Unidad II\n")
cat("Ecolog\u00eda de poblaciones\n")
cat("========================================\n")
cat("Este script ejecutar\u00e1 autom\u00e1ticamente los cap\u00edtulos 4, 5 y 6.\n")
cat("Las salidas se guardar\u00e1n en las carpetas outputs/ de cada cap\u00edtulo.\n\n")

# ---------------------------------------------------------
# Verificar que se ejecuta desde la raíz de la unidad
# ---------------------------------------------------------

if (!dir.exists("cap4-modelos-crecimiento") ||
    !dir.exists("cap5-tablas-vida") ||
    !dir.exists("cap6-distribucion-densidad")) {
  stop(
    "Ejecute run_unidad2.R desde la carpeta unidad_ii/.\n",
    "Debe contener las subcarpetas cap4-modelos-crecimiento/, ",
    "cap5-tablas-vida/ y cap6-distribucion-densidad/."
  )
}

unidad_dir <- getwd()

# ---------------------------------------------------------
# Función auxiliar: cambiar al capítulo y ejecutar run_capX.R
# Usa local = FALSE para que source() encadenados dentro de
# cada run_cap*.R compartan el entorno global correctamente.
# Se limpia el entorno entre capítulos para evitar que
# variables como root_dir o archivo_datos de un capítulo
# contaminen al siguiente.
# ---------------------------------------------------------

limpiar_entorno_capitulo <- function() {
  vars <- c("root_dir", "data_dir", "fig_dir", "tab_dir", "rep_dir",
            "output_dir")
  vars_existentes <- vars[sapply(vars, exists, envir = globalenv())]
  if (length(vars_existentes) > 0) {
    rm(list = vars_existentes, envir = globalenv())
  }
}

ejecutar_capitulo <- function(capitulo_rel, titulo) {
  capitulo_dir <- file.path(unidad_dir, capitulo_rel)
  
  if (!dir.exists(capitulo_dir)) {
    stop("No se encontr\u00f3 la carpeta del cap\u00edtulo: ", capitulo_dir)
  }
  
  run_script <- file.path(capitulo_dir, paste0("run_", basename(capitulo_rel), ".R"))
  
  # Intentar detectar el run_*.R si el nombre no coincide exactamente
  if (!file.exists(run_script)) {
    candidates <- list.files(capitulo_dir, pattern = "^run_cap.*\\.R$", full.names = TRUE)
    if (length(candidates) == 0) {
      stop("No se encontr\u00f3 run_cap*.R en: ", capitulo_dir)
    }
    run_script <- candidates[1]
  }
  
  # Limpiar variables de rutas del capítulo anterior
  limpiar_entorno_capitulo()
  
  old_wd <- getwd()
  setwd(capitulo_dir)
  on.exit(setwd(old_wd), add = TRUE)
  
  cat("\n----------------------------------------\n")
  cat("Ejecutando ", titulo, "\n", sep = "")
  cat("----------------------------------------\n")
  
  source(basename(run_script), local = FALSE, echo = FALSE)
  
  cat(titulo, " completado.\n", sep = "")
}

# ---------------------------------------------------------
# Capítulo 4 — Modelos de crecimiento poblacional
# ---------------------------------------------------------

tryCatch(
  ejecutar_capitulo("cap4-modelos-crecimiento", "Cap\u00edtulo 4 - Modelos de crecimiento poblacional"),
  error = function(e) stop("Error en Cap\u00edtulo 4: ", e$message)
)

# ---------------------------------------------------------
# Capítulo 5 — Tablas de vida y modelos matriciales
# ---------------------------------------------------------

tryCatch(
  ejecutar_capitulo("cap5-tablas-vida", "Cap\u00edtulo 5 - Tablas de vida y modelos matriciales"),
  error = function(e) stop("Error en Cap\u00edtulo 5: ", e$message)
)

# ---------------------------------------------------------
# Capítulo 6 — Patrones de distribución y estimación de la densidad
# ---------------------------------------------------------

tryCatch(
  ejecutar_capitulo("cap6-distribucion-densidad", "Cap\u00edtulo 6 - Patrones de distribuci\u00f3n y estimaci\u00f3n de la densidad"),
  error = function(e) stop("Error en Cap\u00edtulo 6: ", e$message)
)

cat("\n========================================\n")
cat("Unidad II ejecutada correctamente.\n")
cat("Revise las salidas en outputs/ de cada cap\u00edtulo.\n")
cat("========================================\n")
