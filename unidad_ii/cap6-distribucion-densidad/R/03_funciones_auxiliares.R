# =========================================================
# ANDIVEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# Archivo: 03_funciones_auxiliares.R
# Propósito: reunir funciones auxiliares para los casos
#             A y B del capítulo 6
# =========================================================

# ---------------------------------------------------------
# Utilidades de guardado
# ---------------------------------------------------------

guardar_figura <- function(plot, nombre, width = 8, height = 5, dpi = 300) {
  ruta <- file.path("outputs", "figuras", nombre)

  if (!dir.exists(dirname(ruta))) {
    dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  }

  ggplot2::ggsave(
    filename = ruta,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )

  invisible(ruta)
}

guardar_tabla_excel <- function(lista_tablas, archivo = "salidas_cap6.xlsx") {
  ruta <- file.path("outputs", "tablas", archivo)

  if (!dir.exists(dirname(ruta))) {
    dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  }

  if (file.exists(ruta)) {
    file.remove(ruta)
  }

  writexl::write_xlsx(lista_tablas, path = ruta)
  invisible(ruta)
}

# ---------------------------------------------------------
# Ajuste de distribuciones
# ---------------------------------------------------------

ajuste_poisson <- function(conteos) {
  conteos <- as.numeric(conteos)
  conteos <- conteos[is.finite(conteos) & !is.na(conteos) & conteos >= 0]

  if (length(conteos) == 0) {
    stop("No hay conteos válidos para ajustar la distribución de Poisson.")
  }

  n <- length(conteos)
  mu <- mean(conteos, na.rm = TRUE)

  freq_obs <- table(factor(conteos, levels = 0:max(conteos)))
  x <- as.integer(names(freq_obs))
  obs <- as.numeric(freq_obs)
  esp <- stats::dpois(x, lambda = mu) * n

  tibble::tibble(
    x = x,
    observada = obs,
    esperada = esp,
    chi = ifelse(esp > 0, (obs - esp)^2 / esp, NA_real_)
  )
}

ajuste_binomial_negativa <- function(conteos) {
  conteos <- as.numeric(conteos)
  conteos <- conteos[is.finite(conteos) & !is.na(conteos) & conteos >= 0]

  if (length(conteos) == 0) {
    stop("No hay conteos válidos para ajustar la distribución binomial negativa.")
  }

  fit <- MASS::fitdistr(conteos, densfun = "Negative Binomial")
  size <- unname(fit$estimate[["size"]])
  mu <- unname(fit$estimate[["mu"]])

  freq_obs <- table(factor(conteos, levels = 0:max(conteos)))
  x <- as.integer(names(freq_obs))
  obs <- as.numeric(freq_obs)
  esp <- stats::dnbinom(x, size = size, mu = mu) * length(conteos)

  list(
    tabla = tibble::tibble(
      x = x,
      observada = obs,
      esperada = esp,
      chi = ifelse(esp > 0, (obs - esp)^2 / esp, NA_real_)
    ),
    size = size,
    mu = mu
  )
}

# ---------------------------------------------------------
# Índices de dispersión
# ---------------------------------------------------------

indices_dispersion <- function(conteos) {
  conteos <- as.numeric(conteos)
  conteos <- conteos[is.finite(conteos) & !is.na(conteos) & conteos >= 0]

  if (length(conteos) < 2) {
    stop("Se requieren al menos dos conteos válidos para calcular índices de dispersión.")
  }

  n <- length(conteos)
  m <- mean(conteos, na.rm = TRUE)
  s2 <- stats::var(conteos, na.rm = TRUE)

  ID <- ifelse(m > 0, s2 / m, NA_real_)
  IC <- ifelse(m > 0, (s2 / m) - 1, NA_real_)
  IH <- ifelse(sum(conteos^2, na.rm = TRUE) > 0,
               sum(conteos, na.rm = TRUE) / sqrt(sum(conteos^2, na.rm = TRUE)),
               NA_real_)
  m_estrella <- ifelse(m > 0, m + (s2 / m) - 1, NA_real_)
  Ic_lloyd <- ifelse(m > 0, m_estrella / m, NA_real_)
  IM <- ifelse(
    (n - 1) > 0 && sum(conteos, na.rm = TRUE) > 1,
    (n * sum(conteos * (conteos - 1), na.rm = TRUE)) /
      (sum(conteos, na.rm = TRUE) * (sum(conteos, na.rm = TRUE) - 1)),
    NA_real_
  )

  tibble::tibble(
    media = m,
    varianza = s2,
    ID = ID,
    IC = IC,
    IH = IH,
    m_estrella = m_estrella,
    Ic_lloyd = Ic_lloyd,
    IM = IM
  )
}

# ---------------------------------------------------------
# Utilidades para estimación de densidad
# ---------------------------------------------------------

resumen_densidad <- function(densidad_m2, metodo, longitud_referencia = NA_real_) {
  tibble::tibble(
    metodo = metodo,
    densidad_m2 = densidad_m2,
    densidad_ha = densidad_m2 * 10000,
    longitud_referencia = longitud_referencia
  )
}
