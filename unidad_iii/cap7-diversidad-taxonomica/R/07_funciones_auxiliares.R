# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# ---------------------------------------------------------
# Archivo : 07_funciones_auxiliares.R
# Propósito: funciones auxiliares de guardado para los casos
#             guiados del capítulo 7.
#             La lógica de análisis es explícita en cada script
#             de caso guiado; este archivo solo contiene
#             utilidades para exportar salidas.
# =========================================================

# ---------------------------------------------------------
# guardar_figura()
# Exporta un objeto ggplot como archivo .png
# ---------------------------------------------------------

guardar_figura <- function(plot, nombre, width = 8, height = 5, dpi = 300) {
  ruta <- file.path(fig_dir, nombre)
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(
    filename = ruta,
    plot     = plot,
    width    = width,
    height   = height,
    dpi      = dpi
  )
  invisible(ruta)
}

# ---------------------------------------------------------
# guardar_xlsx()
# Exporta un data.frame / tibble como archivo .xlsx
# ---------------------------------------------------------

guardar_xlsx <- function(datos, ruta) {
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  writexl::write_xlsx(datos, path = ruta)
  invisible(ruta)
}

# ---------------------------------------------------------
# guardar_rds()
# Exporta un objeto R como archivo .rds en outputs/reportes/
# ---------------------------------------------------------

guardar_rds <- function(objeto, archivo) {
  ruta <- file.path(rep_dir, archivo)
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  saveRDS(objeto, file = ruta)
  invisible(ruta)
}
