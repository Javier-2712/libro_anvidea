# =========================================================
# ANVIDEA - Unidad I
# Archivo: run_unidad1.R
# Propósito: ejecutar secuencialmente los capítulos 1, 2 y 3
#            desde la raíz de la Unidad I
# Uso: source("run_unidad1.R")  desde la carpeta unidad_i/
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Unidad I\n")
cat("Análisis de datos ecológicos\n")
cat("========================================\n")
cat("Este script ejecutará automáticamente los capítulos 1, 2 y 3.\n")
cat("Las salidas se guardarán en las carpetas outputs/ de cada capítulo.\n\n")

# ---------------------------------------------------------
# Verificar que se ejecuta desde la raíz de la unidad
# ---------------------------------------------------------

if (!dir.exists("cap1-datos") ||
    !dir.exists("cap2-visualizacion-exploratoria") ||
    !dir.exists("cap3-clima")) {
  stop(
    "Ejecute run_unidad1.R desde la carpeta unidad_i/.\n",
    "Debe contener las subcarpetas cap1-datos/, cap2-visualizacion-exploratoria/ y cap3-clima/."
  )
}

unidad_dir <- getwd()

# ---------------------------------------------------------
# Función auxiliar: cambiar al capítulo y ejecutar run_capX.R
# ---------------------------------------------------------

ejecutar_capitulo <- function(capitulo_rel, titulo) {
  capitulo_dir <- file.path(unidad_dir, capitulo_rel)

  if (!dir.exists(capitulo_dir)) {
    stop("No se encontró la carpeta del capítulo: ", capitulo_dir)
  }

  run_script <- file.path(capitulo_dir, paste0("run_", basename(capitulo_rel), ".R"))

  # Intentar detectar el run_*.R si el nombre no coincide exactamente
  if (!file.exists(run_script)) {
    candidates <- list.files(capitulo_dir, pattern = "^run_cap.*\\.R$", full.names = TRUE)
    if (length(candidates) == 0) {
      stop("No se encontró run_cap*.R en: ", capitulo_dir)
    }
    run_script <- candidates[1]
  }

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
# Capítulo 1 — Fundamentos de manipulación de datos
# ---------------------------------------------------------

tryCatch(
  ejecutar_capitulo("cap1-datos", "Capítulo 1 - Manipulación de datos"),
  error = function(e) stop("Error en Capítulo 1: ", e$message)
)

# ---------------------------------------------------------
# Capítulo 2 — Visualización exploratoria
# ---------------------------------------------------------

tryCatch(
  ejecutar_capitulo("cap2-visualizacion-exploratoria", "Capítulo 2 - Visualización exploratoria"),
  error = function(e) stop("Error en Capítulo 2: ", e$message)
)

# ---------------------------------------------------------
# Capítulo 3 — Análisis climático
# ---------------------------------------------------------

tryCatch(
  ejecutar_capitulo("cap3-clima", "Capítulo 3 - Análisis climático"),
  error = function(e) stop("Error en Capítulo 3: ", e$message)
)

cat("\n========================================\n")
cat("Unidad I ejecutada correctamente.\n")
cat("Revise las salidas en outputs/ de cada capítulo.\n")
cat("========================================\n")
