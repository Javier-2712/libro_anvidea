# =========================================================
# ANVIDEA - Unidad II
# Capítulo 4 - Modelos poblacionales
# Archivo: 03_funciones_auxiliares_ajustado.R
# Propósito: definir funciones auxiliares reutilizables
# =========================================================

# ---------------------------------------------------------
# 1. Guardar figuras
# ---------------------------------------------------------

guardar_figura <- function(plot, nombre, width = 8, height = 5, dpi = 300) {
  if (missing(plot) || is.null(plot)) {
    stop("Debe suministrar un objeto gráfico válido en 'plot'.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena no vacía.")
  }

  dir.create(file.path("outputs", "figuras"), recursive = TRUE, showWarnings = FALSE)

  ggplot2::ggsave(
    filename = file.path("outputs", "figuras", nombre),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )
}

# ---------------------------------------------------------
# 2. Guardar tablas en Excel
# ---------------------------------------------------------

guardar_tablas_excel <- function(lista_tablas, archivo = "salidas_cap4.xlsx") {
  if (missing(lista_tablas) || is.null(lista_tablas)) {
    stop("Debe suministrar una lista de tablas en 'lista_tablas'.")
  }

  if (!is.list(lista_tablas) || length(lista_tablas) == 0) {
    stop("'lista_tablas' debe ser una lista no vacía.")
  }

  if (!all(vapply(lista_tablas, function(x) inherits(x, c("data.frame", "tbl_df")), logical(1)))) {
    stop("Todos los elementos de 'lista_tablas' deben ser data.frame o tibble.")
  }

  if (!is.character(archivo) || length(archivo) != 1 || !nzchar(archivo)) {
    stop("El argumento 'archivo' debe ser una cadena no vacía.")
  }

  dir.create(file.path("outputs", "tablas"), recursive = TRUE, showWarnings = FALSE)

  ruta <- file.path("outputs", "tablas", archivo)
  if (file.exists(ruta)) file.remove(ruta)

  writexl::write_xlsx(lista_tablas, path = ruta)
}

guardar_tabla_excel <- function(df, archivo = "tabla.xlsx") {
  if (missing(df) || is.null(df)) {
    stop("Debe suministrar un data.frame o tibble en 'df'.")
  }

  if (!inherits(df, c("data.frame", "tbl_df"))) {
    stop("El objeto 'df' debe ser un data.frame o tibble.")
  }

  guardar_tablas_excel(list(tabla = df), archivo = archivo)
}

# ---------------------------------------------------------
# 3. Modelo exponencial continuo
# ---------------------------------------------------------

modelo_exponencial_continuo <- function(N0, r, t) {
  if (length(N0) != 1 || !is.finite(N0) || N0 <= 0) {
    stop("'N0' debe ser un número positivo.")
  }
  if (length(r) != 1 || !is.finite(r)) {
    stop("'r' debe ser un número finito.")
  }
  if (length(t) == 0 || any(!is.finite(t))) {
    stop("'t' debe contener valores numéricos finitos.")
  }

  tibble::tibble(
    t = t,
    N = N0 * exp(r * t)
  )
}

# ---------------------------------------------------------
# 4. Modelo exponencial discreto
# ---------------------------------------------------------

modelo_exponencial_discreto <- function(N0, lambda, t) {
  if (length(N0) != 1 || !is.finite(N0) || N0 <= 0) {
    stop("'N0' debe ser un número positivo.")
  }
  if (length(lambda) != 1 || !is.finite(lambda) || lambda <= 0) {
    stop("'lambda' debe ser un número positivo.")
  }
  if (length(t) == 0 || any(!is.finite(t))) {
    stop("'t' debe contener valores numéricos finitos.")
  }

  tibble::tibble(
    t = t,
    N = N0 * lambda^t
  )
}

# ---------------------------------------------------------
# 5. Estimación de parámetros exponenciales
# ---------------------------------------------------------

estimar_r <- function(N0, Nt, t) {
  if (any(!is.finite(c(N0, Nt, t)))) {
    stop("'N0', 'Nt' y 't' deben ser valores finitos.")
  }
  if (any(N0 <= 0) || any(Nt <= 0)) {
    stop("'N0' y 'Nt' deben ser positivos.")
  }
  if (any(t <= 0)) {
    stop("'t' debe ser mayor que cero.")
  }

  log(Nt / N0) / t
}

estimar_lambda <- function(N0, Nt, t) {
  if (any(!is.finite(c(N0, Nt, t)))) {
    stop("'N0', 'Nt' y 't' deben ser valores finitos.")
  }
  if (any(N0 <= 0) || any(Nt <= 0)) {
    stop("'N0' y 'Nt' deben ser positivos.")
  }
  if (any(t <= 0)) {
    stop("'t' debe ser mayor que cero.")
  }

  (Nt / N0)^(1 / t)
}

# ---------------------------------------------------------
# 6. Modelo logístico
# ---------------------------------------------------------

modelo_logistico <- function(N0, K, r, t) {
  if (length(N0) != 1 || !is.finite(N0) || N0 <= 0) {
    stop("'N0' debe ser un número positivo.")
  }
  if (length(K) != 1 || !is.finite(K) || K <= 0) {
    stop("'K' debe ser un número positivo.")
  }
  if (N0 >= K) {
    warning("'N0' es mayor o igual que 'K'. Revise si ese escenario es intencional.")
  }
  if (length(r) != 1 || !is.finite(r)) {
    stop("'r' debe ser un número finito.")
  }
  if (length(t) == 0 || any(!is.finite(t))) {
    stop("'t' debe contener valores numéricos finitos.")
  }

  tibble::tibble(
    t = t,
    N = K / (1 + ((K - N0) / N0) * exp(-r * t))
  )
}

velocidad_logistica <- function(N, r, K) {
  if (any(!is.finite(N))) {
    stop("'N' debe contener valores finitos.")
  }
  if (length(r) != 1 || !is.finite(r)) {
    stop("'r' debe ser un número finito.")
  }
  if (length(K) != 1 || !is.finite(K) || K <= 0) {
    stop("'K' debe ser un número positivo.")
  }

  r * N * (1 - N / K)
}

tiempo_hasta_fraccion_K <- function(N0, K, r, fraccion) {
  if (any(!is.finite(c(N0, K, r, fraccion)))) {
    stop("'N0', 'K', 'r' y 'fraccion' deben ser valores finitos.")
  }
  if (N0 <= 0 || K <= 0) {
    stop("'N0' y 'K' deben ser positivos.")
  }
  if (r == 0) {
    stop("'r' no puede ser cero para calcular el tiempo.")
  }
  if (fraccion <= 0 || fraccion >= 1) {
    stop("'fraccion' debe estar entre 0 y 1, sin incluir extremos.")
  }

  (1 / r) * log(((K - N0) / N0) * (fraccion / (1 - fraccion)))
}
