# =========================================================
# Funciones auxiliares - Capítulo 7
# =========================================================

guardar_tabla_excel <- function(df, nombre){
  writexl::write_xlsx(df, file.path(tab_dir, nombre))
}

guardar_figura <- function(plot_obj, nombre, width = 8, height = 5){
  ggplot2::ggsave(
    filename = file.path(fig_dir, nombre),
    plot = plot_obj,
    width = width, height = height, dpi = 300
  )
}

titulo_paso <- function(txt){
  cat("\n----------------------------------------\n")
  cat(txt, "\n")
  cat("----------------------------------------\n")
}

verificar_objeto <- function(x, nombre = deparse(substitute(x))){
  if(!exists(nombre, inherits = TRUE)){
    stop("No existe el objeto: ", nombre)
  }
}

tabla_bonita <- function(df, digits = 2){
  df %>%
    knitr::kable(booktabs = TRUE, digits = digits) %>%
    kableExtra::kable_classic(full_width = FALSE)
}
