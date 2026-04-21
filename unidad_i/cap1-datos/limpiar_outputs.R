# =========================================================
# ANVIDEA - Capítulo 1
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
cat("ANVIDEA - Capítulo 1\n")
cat("Limpieza de outputs\n")
cat("========================================\n\n")

# ---------------------------------------------------------
# 1. Verificar que se ejecuta desde la raíz del capítulo
# ---------------------------------------------------------

if (!dir.exists("outputs")) {
  stop(
    "No se encontró la carpeta outputs/.\n",
    "Ejecute limpiar_outputs.R desde la raíz del capítulo."
  )
}

# ---------------------------------------------------------
# 2. Confirmar antes de borrar (sesión interactiva)
# ---------------------------------------------------------

if (interactive()) {
  respuesta <- readline(
    "¿Está seguro de que desea eliminar todos los outputs del capítulo 1? (s/n): "
  )
  if (!tolower(trimws(respuesta)) %in% c("s", "si", "sí", "y", "yes")) {
    cat("Operación cancelada. No se eliminó ningún archivo.\n")
    stop("Cancelado por el usuario.", call. = FALSE)
  }
}

# ---------------------------------------------------------
# 3. Borrar contenido de cada subcarpeta
# ---------------------------------------------------------

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

# ---------------------------------------------------------
# 4. Mensaje final
# ---------------------------------------------------------

cat("\nOutputs eliminados.\n")
cat("Para volver a generarlos ejecute:\n\n")
cat("  source(\"run_cap1.R\")\n\n")
cat("o por partes:\n\n")
cat("  source(\"R/00_setup.R\")\n")
cat("  source(\"R/01_casoA_mesozooplancton.R\")\n")
cat("  source(\"R/02_casoB_macroinvertebrados.R\")\n")
cat("  source(\"R/04_guardar_salidas_cap1.R\")\n")
cat("  source(\"R/05_render_reporte.R\")\n")
