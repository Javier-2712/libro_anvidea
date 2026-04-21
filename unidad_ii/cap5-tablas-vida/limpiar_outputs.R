# =========================================================
# ANVIDEA - Capítulo 5
# Archivo: limpiar_outputs.R
# Propósito: eliminar salidas generadas y recrear estructura
# Uso: source("limpiar_outputs.R")
# Ejecutar desde la raíz del capítulo
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 5\n")
cat("Limpieza de outputs\n")
cat("========================================\n\n")

if (!dir.exists("outputs")) {
  stop(
    "No se encontró la carpeta outputs/.\n",
    "Ejecute limpiar_outputs.R desde la raíz del capítulo."
  )
}

if (interactive()) {
  respuesta <- readline(
    "¿Desea eliminar todos los outputs del capítulo 5? (s/n): "
  )
  ok <- tolower(trimws(respuesta)) %in% c("s","si","sí","y","yes")
  if (!ok) {
    cat("Operación cancelada.\n")
    stop("Cancelado por el usuario.", call. = FALSE)
  }
}

carpetas <- c(
  file.path("outputs","figuras"),
  file.path("outputs","tablas"),
  file.path("outputs","reportes")
)

for (carpeta in carpetas) {
  if (dir.exists(carpeta)) {
    archivos <- list.files(
      carpeta,
      full.names = TRUE,
      recursive = TRUE,
      all.files = FALSE,
      no.. = TRUE
    )
    
    if (length(archivos) > 0) {
      unlink(archivos, recursive = TRUE, force = TRUE)
      cat("Limpiada:", carpeta, "-",
          length(archivos), "elemento(s) eliminado(s).\n")
    } else {
      cat("Ya vacía:", carpeta, "\n")
    }
  } else {
    cat("No existe:", carpeta, "(se creará).\n")
  }
  
  dir.create(carpeta, recursive = TRUE, showWarnings = FALSE)
}

cat("\nOutputs eliminados y carpetas verificadas.\n")
cat("Para regenerar resultados ejecute:\n\n")
cat("source(\"run_cap5.R\")\n")
