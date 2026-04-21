# =========================================================
# ANVIDEA - Capítulo 3
# Archivo: 02_funciones_auxiliares.R
# Propósito: funciones de apoyo para figuras, tablas y reportes
# Cargado automáticamente desde 00_setup.R
# =========================================================

# ---------------------------------------------------------
# 1. Verificar existencia de archivo
# ---------------------------------------------------------

verificar_archivo <- function(ruta) {
  if (!file.exists(ruta)) {
    stop("No se encontró el archivo: ", ruta, call. = FALSE)
  }
}

# ---------------------------------------------------------
# 2. Estandarizar nombres de estaciones
# ---------------------------------------------------------

estandarizar_estacion <- function(x) {
  x_chr <- stringr::str_squish(as.character(x))
  dplyr::case_when(
    stringr::str_to_upper(x_chr) %in%
      c("APTO", "AEROPUERTO", "AEROPUERTO SIMON BOLIVAR",
        "AEROPUERTO SIMÓN BOLÍVAR") ~ "APTO",
    stringr::str_to_upper(x_chr) %in%
      c("PNNT", "PARQUE TAYRONA",
        "PARQUE NACIONAL NATURAL TAYRONA") ~ "PNNT",
    stringr::str_to_upper(x_chr) %in%
      c("SL", "SAN LORENZO") ~ "SL",
    TRUE ~ stringr::str_to_upper(x_chr)
  )
}

# ---------------------------------------------------------
# 3. Ordenar meses como factor
# ---------------------------------------------------------

ordenar_meses <- function(x, abreviatura = c("lower", "upper", "title")) {
  abreviatura <- match.arg(abreviatura)
  base   <- c("ene","feb","mar","abr","may","jun","jul","ago","sep","oct","nov","dic")
  x_std  <- stringr::str_to_lower(stringr::str_sub(as.character(x), 1, 3))
  niveles <- switch(abreviatura,
                    lower = base,
                    upper = stringr::str_to_upper(base),
                    title = stringr::str_to_title(base))
  valores <- switch(abreviatura,
                    lower = x_std,
                    upper = stringr::str_to_upper(x_std),
                    title = stringr::str_to_title(x_std))
  factor(valores, levels = niveles, ordered = TRUE)
}

# ---------------------------------------------------------
# 4. Guardar tablas en Excel
# ---------------------------------------------------------

guardar_xlsx <- function(objeto, ruta) {
  writexl::write_xlsx(objeto, path = ruta)
}

# ---------------------------------------------------------
# 5. Guardar figuras ggplot2
# ---------------------------------------------------------

guardar_figura <- function(plot, nombre_archivo,
                            width = 9, height = 5,
                            dpi = 300, bg = "white") {
  ggplot2::ggsave(
    filename = file.path(ruta_figuras, nombre_archivo),
    plot     = plot,
    width    = width,
    height   = height,
    units    = "in",
    dpi      = dpi,
    bg       = bg
  )
}

# ---------------------------------------------------------
# 6. Guardar y leer objetos RDS
# ---------------------------------------------------------

guardar_rds <- function(objeto, nombre_archivo) {
  ruta <- file.path(ruta_reportes, nombre_archivo)
  saveRDS(objeto, file = ruta)
}

leer_rds <- function(nombre_archivo) {
  ruta <- file.path(ruta_reportes, nombre_archivo)
  readRDS(ruta)
}

# ---------------------------------------------------------
# 7. Tabla HTML para reportes
# ---------------------------------------------------------

tabla_html <- function(df, digits = 2, caption = NULL, max_filas = NULL) {
  if (is.null(df) || !is.data.frame(df) || ncol(df) == 0 || nrow(df) == 0) {
    return(htmltools::HTML("<p><em>Tabla no disponible.</em></p>"))
  }
  if (!is.null(max_filas)) df <- head(df, max_filas)
  kableExtra::kbl(df, caption = caption, digits = digits,
                  booktabs = TRUE, format = "html") %>%
    kableExtra::kable_classic(full_width = FALSE, html_font = "Cambria")
}
