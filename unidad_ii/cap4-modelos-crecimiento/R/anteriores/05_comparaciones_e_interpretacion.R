# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: 05_comparaciones_e_interpretacion.R
# Propósito: comparar modelos e integrar interpretación
#            ecológica final del capítulo
# =========================================================

source("R/00_setup.R")
source("R/07_funciones_auxiliares.R")

cat("Iniciando: comparaciones e interpretación...\n")

logistico_N <- function(t, N0, r, K) {
  K / (1 + ((K - N0) / N0) * exp(-r * t))
}

# ---------------------------------------------------------
# Ejemplo 1 — Exponencial vs logístico
# ---------------------------------------------------------
N0 <- 20
r  <- 0.28
K  <- 300
t  <- seq(0, 30, by = 0.25)

tabla_e1 <- tibble::tibble(
  t = t,
  Exponencial = N0 * exp(r * t),
  Logistico   = logistico_N(t, N0 = N0, r = r, K = K)
) |>
  tidyr::pivot_longer(
    cols = c(Exponencial, Logistico),
    names_to = "Modelo",
    values_to = "N"
  )

fig_e1 <- ggplot2::ggplot(
  tabla_e1,
  ggplot2::aes(t, N, linetype = Modelo)
) +
  ggplot2::geom_line(linewidth = 1.05) +
  ggplot2::geom_hline(yintercept = K, linetype = 2) +
  ggplot2::labs(
    title = "Comparación entre crecimiento exponencial y logístico",
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)",
    linetype = "Modelo"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e1,
  filename = "fig-c4-22_exponencial_vs_logistico.png",
  width = 7.2,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 2 — Escenarios con diferentes tamaños iniciales
# ---------------------------------------------------------
N0_vals <- c(10, 50, 150, 280)
r <- 0.30
K <- 300
t <- seq(0, 30, by = 0.25)

tabla_e2 <- purrr::map_dfr(
  N0_vals,
  function(N0i) {
    tibble::tibble(
      t = t,
      N0 = factor(N0i),
      N = logistico_N(t, N0 = N0i, r = r, K = K)
    )
  }
)

fig_e2 <- ggplot2::ggplot(
  tabla_e2,
  ggplot2::aes(t, N, linetype = N0)
) +
  ggplot2::geom_line(linewidth = 1.05) +
  ggplot2::geom_hline(yintercept = K, linetype = 2) +
  ggplot2::labs(
    title = "Influencia del tamaño inicial en la trayectoria logística",
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)",
    linetype = "N0"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e2,
  filename = "fig-c4-23_logistico_efecto_N0.png",
  width = 7.2,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 3 — Tiempo para alcanzar una fracción de K
# ---------------------------------------------------------
r <- 0.25
K <- 400
N0 <- 20
fracciones <- c(0.25, 0.50, 0.75, 0.90)

tabla_e3 <- tibble::tibble(fraccion = fracciones) |>
  dplyr::mutate(
    Nt = fraccion * K,
    tiempo = (log((K - N0) / N0) - log((K - Nt) / Nt)) / r
  )

guardar_tabla_csv(
  data = tabla_e3,
  filename = "tabla-c4-10_tiempo_fracciones_K.csv"
)

fig_e3 <- ggplot2::ggplot(tabla_e3, ggplot2::aes(fraccion, tiempo)) +
  ggplot2::geom_point(size = 2.8) +
  ggplot2::geom_line() +
  ggplot2::scale_x_continuous(breaks = fracciones) +
  ggplot2::labs(
    title = "Tiempo requerido para alcanzar fracciones de K",
    x = "Fracción de la capacidad de carga",
    y = "Tiempo"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e3,
  filename = "fig-c4-24_tiempo_fracciones_K.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 4 — Resumen comparativo de modelos
# ---------------------------------------------------------
tabla_e4 <- tibble::tribble(
  ~Aspecto, ~Modelo_exponencial, ~Modelo_logistico,
  "Supuesto central", "No hay limitación ambiental", "Existe limitación por recursos",
  "Parámetro clave", "r o λ", "r y K",
  "Forma de la curva", "J", "Sigmoide",
  "Regulación por densidad", "No", "Sí",
  "Aplicación conceptual", "Potencial biótico", "Crecimiento regulado"
)

guardar_tabla_csv(
  data = tabla_e4,
  filename = "tabla-c4-11_resumen_comparativo_modelos.csv"
)

cat("Finalizado: comparaciones e interpretación.\n")
