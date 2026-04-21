# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: 05_funciones_auxiliares.R
# Propósito: funciones auxiliares para exportación y apoyo
# =========================================================

guardar_figura_anvidea <- function(plot, filename, width = 7, height = 5, dpi = 300) {
  ggplot2::ggsave(
    filename = file.path(fig_dir, filename),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )
}

guardar_tabla_csv <- function(data, filename) {
  readr::write_csv(data, file.path(tab_dir, filename))
}
