# =========================================================
# ANVIDEA - Capítulo 5
# Archivo: 05_funciones_auxiliares.R
# Propósito: funciones auxiliares de guardado
# =========================================================

guardar_figura <- function(plot, archivo, width = 8, height = 5, dpi = 300) {
  ruta <- file.path("outputs", "figuras", archivo)
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(filename = ruta, plot = plot,
                  width = width, height = height, dpi = dpi)
  invisible(ruta)
}

guardar_xlsx <- function(datos, ruta) {
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  writexl::write_xlsx(datos, path = ruta)
  invisible(ruta)
}

guardar_rds <- function(objeto, archivo) {
  ruta <- file.path("outputs", "reportes", archivo)
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  saveRDS(objeto, file = ruta)
  invisible(ruta)
}