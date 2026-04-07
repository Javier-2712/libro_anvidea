# =========================================================
# ANVIDEA - Unidad I
# Capítulo 1 - Fundamentos de manipulación de datos
# Archivo: 03_funciones_auxiliares_ajustado.R
# Propósito: definir funciones auxiliares reutilizables
# =========================================================

# ---------------------------------------------------------
# 1. Estandarización de nombres de sitio
# ---------------------------------------------------------

std_sitio <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  stringr::str_replace_all(x, "\\s+", "")
}

# ---------------------------------------------------------
# 2. Resumen estadístico de salinidad
# ---------------------------------------------------------

resumen_salinidad_fun <- function(df, var = "Salinity") {
  if (!is.data.frame(df)) {
    stop("'df' debe ser un data.frame.")
  }

  if (!var %in% names(df)) {
    stop("La variable '", var, "' no existe en el data.frame.")
  }

  x <- suppressWarnings(as.numeric(df[[var]]))

  if (all(is.na(x))) {
    stop("La variable '", var, "' no contiene valores numéricos válidos.")
  }

  tibble::tibble(
    minimo  = min(x, na.rm = TRUE),
    q25     = as.numeric(stats::quantile(x, 0.25, na.rm = TRUE)),
    mediana = stats::median(x, na.rm = TRUE),
    q75     = as.numeric(stats::quantile(x, 0.75, na.rm = TRUE)),
    maximo  = max(x, na.rm = TRUE),
    media   = mean(x, na.rm = TRUE),
    sd      = stats::sd(x, na.rm = TRUE)
  )
}

# ---------------------------------------------------------
# 3. Taxones más abundantes
# ---------------------------------------------------------

top_n_taxa <- function(df, taxon_col, abundance_col, n = 5) {
  if (!is.data.frame(df)) {
    stop("'df' debe ser un data.frame.")
  }

  if (!taxon_col %in% names(df)) {
    stop("La columna taxonómica '", taxon_col, "' no existe en 'df'.")
  }

  if (!abundance_col %in% names(df)) {
    stop("La columna de abundancia '", abundance_col, "' no existe en 'df'.")
  }

  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n <= 0) {
    stop("'n' debe ser un número positivo.")
  }

  df %>%
    dplyr::mutate(
      dplyr::across(dplyr::all_of(abundance_col), as.numeric)
    ) %>%
    dplyr::group_by(.data[[taxon_col]]) %>%
    dplyr::summarise(
      total = sum(.data[[abundance_col]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::slice_max(order_by = total, n = n, with_ties = FALSE)
}

# ---------------------------------------------------------
# 4. Guardar figuras
# ---------------------------------------------------------

guardar_figura <- function(plot_obj, nombre, width = 8, height = 5, dpi = 300) {
  if (missing(plot_obj) || is.null(plot_obj)) {
    stop("Debe suministrar un objeto gráfico válido en 'plot_obj'.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena no vacía.")
  }

  dir.create(file.path("outputs", "figuras"), recursive = TRUE, showWarnings = FALSE)

  ggplot2::ggsave(
    filename = file.path("outputs", "figuras", nombre),
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi
  )
}

# ---------------------------------------------------------
# 5. Guardar tablas en Excel
# ---------------------------------------------------------

guardar_tabla_excel <- function(df, nombre) {
  if (missing(df) || is.null(df)) {
    stop("Debe suministrar un objeto válido en 'df'.")
  }

  if (!inherits(df, c("data.frame", "list"))) {
    stop("El objeto 'df' debe ser un data.frame o una lista de data.frames.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena no vacía.")
  }

  dir.create(file.path("outputs", "tablas"), recursive = TRUE, showWarnings = FALSE)

  writexl::write_xlsx(df, file.path("outputs", "tablas", nombre))
}
