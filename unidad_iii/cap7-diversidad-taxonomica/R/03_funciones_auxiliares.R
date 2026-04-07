# =========================================================
# Funciones auxiliares - Capítulo 7
# =========================================================

guardar_tabla_excel <- function(df, nombre){
  writexl::write_xlsx(df, file.path("outputs","tablas",nombre))
}

guardar_figura <- function(plot_obj, nombre){
  ggplot2::ggsave(
    filename = file.path("outputs","figuras",nombre),
    plot = plot_obj, width = 8, height = 5, dpi = 300
  )
}
