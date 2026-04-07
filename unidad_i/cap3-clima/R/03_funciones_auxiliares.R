# =========================================================
# ANVIDEA - Unidad I
# Capítulo 3 - Visualización gráfica de patrones climáticos
# Archivo: 03_funciones_auxiliares_ajustado.R
# Propósito: definir funciones auxiliares reutilizables
# =========================================================

# ---------------------------------------------------------
# 1. Vectores de meses
# ---------------------------------------------------------

meses_min <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
meses_may <- c("ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC")

# ---------------------------------------------------------
# 2. Ordenación de meses
# ---------------------------------------------------------

ordenar_meses_min <- function(x) {
  x <- tolower(trimws(as.character(x)))
  factor(x, levels = meses_min, ordered = TRUE)
}

ordenar_meses_may <- function(x) {
  x <- toupper(trimws(as.character(x)))
  factor(x, levels = meses_may, ordered = TRUE)
}

# ---------------------------------------------------------
# 3. Coeficiente de Thornthwaite
# ---------------------------------------------------------

thornthwaite_a <- function(I) {
  I <- as.numeric(I)

  if (any(is.na(I))) {
    warning("Se detectaron valores NA en 'I'.")
  }

  6.75e-7 * I^3 - 7.71e-5 * I^2 + 1.792e-2 * I + 0.49239
}

# ---------------------------------------------------------
# 4. Clasificación del índice de Lang
# ---------------------------------------------------------

clasificar_lang <- function(x) {
  x <- as.numeric(x)

  cut(
    x,
    breaks = c(0, 20, 40, 60, 100, 160, Inf),
    labels = c("Muy árido", "Árido", "Semiárido", "Subhúmedo seco", "Húmedo", "Hiperhúmedo"),
    right = TRUE,
    include.lowest = TRUE,
    ordered_result = TRUE
  )
}

# ---------------------------------------------------------
# 5. Guardar figuras
# ---------------------------------------------------------

guardar_figura <- function(plot_obj, nombre, width = 10, height = 7, dpi = 300) {
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
# 6. Guardar tablas en Excel
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
