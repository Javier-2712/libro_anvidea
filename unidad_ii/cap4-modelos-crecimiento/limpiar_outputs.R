# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: limpiar_outputs.R
# Propósito: borrar todas las salidas generadas del capítulo
#            para permitir una ejecución limpia desde cero
# Uso: source("limpiar_outputs.R")  desde la raíz del capítulo
# =========================================================
# ADVERTENCIA: esta acción es irreversible.
# Los archivos en outputs/ serán eliminados permanentemente.
# Los datos originales en data/raw/ NO se ven afectados.
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 4\n")
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
    "¿Está seguro de que desea eliminar todos los outputs del capítulo 4? (s/n): "
  )
  if (!tolower(trimws(respuesta)) %in% c("s", "si", "sí", "y", "yes")) {
    cat("Operación cancelada. No se eliminó ningún archivo.\n")
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
    archivos <- list.files(carpeta, full.names = TRUE, all.files = FALSE)
    if (length(archivos) > 0) {
      unlink(archivos, recursive = TRUE, force = TRUE)
      cat("  Limpiada:", carpeta, "(", length(archivos), "elemento(s) eliminado(s) )\n")
    } else {
      cat("  Ya vacía:", carpeta, "\n")
    }
  } else {
    cat("  No existe:", carpeta, "(se omite)\n")
  }
}

# Al final del bucle de limpieza, agregar:
for (carpeta in carpetas) {
  if (!dir.exists(carpeta)) {
    dir.create(carpeta, recursive = TRUE)
    cat("  Recreada:", carpeta, "\n")
  }
}

cat("\nOutputs eliminados y carpetas recreadas.\n")
cat("Para volver a generarlos ejecute:\n\n")
cat("  source(\"run_cap4.R\")\n\n")
cat("o por partes:\n\n")
cat("  source(\"R/00_setup.R\")\n")
cat("  source(\"R/01_modelo_exponencial_continuo.R\")\n")
cat("  source(\"R/02_modelo_exponencial_discreto.R\")\n")
cat("  source(\"R/03_modelo_logistico.R\")\n")
cat("  source(\"R/04_render_reporte.R\")\n")
cat("  source(\"R/05_guardar_salidas_cap4.R\")\n")
cat("  source(\"R/06_funciones_auxiliares.R\")\n")
