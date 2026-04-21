# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# ---------------------------------------------------------
# Archivo : limpiar_outputs.R
# Propósito: eliminar salidas generadas y recrear estructura
# Uso: source("limpiar_outputs.R")
#      Ejecutar desde la raíz del capítulo
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Cap\u00edtulo 7\n")
cat("Limpieza de outputs\n")
cat("========================================\n\n")

if (!dir.exists("outputs")) {
  stop(
    "No se encontr\u00f3 la carpeta outputs/.\n",
    "Ejecute limpiar_outputs.R desde la ra\u00edz del cap\u00edtulo 7."
  )
}

if (interactive()) {
  respuesta <- readline(
    "\u00bfDesea eliminar todos los outputs del cap\u00edtulo 7? (s/n): "
  )
  ok <- tolower(trimws(respuesta)) %in% c("s", "si", "s\u00ed", "y", "yes")
  if (!ok) {
    cat("Operaci\u00f3n cancelada.\n")
    stop("Cancelado por el usuario.", call. = FALSE)
  }
}

carpetas <- c(
  file.path("outputs", "figuras"),
  file.path("outputs", "tablas"),
  file.path("outputs", "reportes")
)

for (carpeta in carpetas) {
  if (dir.exists(carpeta)) {
    archivos <- list.files(
      carpeta,
      full.names = TRUE,
      recursive  = TRUE,
      all.files  = FALSE,
      no..       = TRUE
    )
    if (length(archivos) > 0) {
      unlink(archivos, recursive = TRUE, force = TRUE)
      cat("Limpiada:", carpeta, "-",
          length(archivos), "elemento(s) eliminado(s).\n")
    } else {
      cat("Ya vac\u00eda:", carpeta, "\n")
    }
  } else {
    cat("No existe:", carpeta, "(se crear\u00e1).\n")
  }
  dir.create(carpeta, recursive = TRUE, showWarnings = FALSE)
}

cat("\nOutputs eliminados y carpetas verificadas.\n")
cat("Para regenerar los resultados ejecute:\n\n")
cat("source(\"run_cap7.R\")\n")
