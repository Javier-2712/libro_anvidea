# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: 03_modelo_logistico_fundamentos.R
# Propósito: desarrollar los fundamentos del modelo logístico
#            y exportar figuras/tablas base
# =========================================================

source("R/00_setup.R")
source("R/07_funciones_auxiliares.R")

cat("Iniciando: modelo logístico - fundamentos...\n")

logistico_N <- function(t, N0, r, K) {
  K / (1 + ((K - N0) / N0) * exp(-r * t))
}

# ---------------------------------------------------------
# Ejemplo 1 — Trayectoria logística básica
# ---------------------------------------------------------
N0 <- 20
r  <- 0.35
K  <- 500
t  <- seq(0, 35, by = 0.25)

tabla_e1 <- tibble::tibble(
  t = t,
  N = logistico_N(t, N0 = N0, r = r, K = K)
)

fig_e1 <- ggplot2::ggplot(tabla_e1, ggplot2::aes(t, N)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_hline(yintercept = K, linetype = 2) +
  ggplot2::labs(
    title = "Modelo logístico de crecimiento poblacional",
    subtitle = paste0("N0 = ", N0, ", r = ", r, ", K = ", K),
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e1,
  filename = "fig-c4-13_logistico_basico.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 2 — Comparación de distintos valores de K
# ---------------------------------------------------------
N0 <- 20
r  <- 0.30
K_vals <- c(100, 300, 600)
t  <- seq(0, 35, by = 0.25)

tabla_e2 <- purrr::map_dfr(
  K_vals,
  function(Ki) {
    tibble::tibble(
      t = t,
      K = factor(Ki),
      N = logistico_N(t, N0 = N0, r = r, K = Ki)
    )
  }
)

fig_e2 <- ggplot2::ggplot(
  tabla_e2,
  ggplot2::aes(t, N, group = K, linetype = K)
) +
  ggplot2::geom_line(linewidth = 1.05) +
  ggplot2::labs(
    title = "Efecto de la capacidad de carga (K)",
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)",
    linetype = "K"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e2,
  filename = "fig-c4-14_logistico_efecto_K.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 3 — Comparación de distintos valores de r
# ---------------------------------------------------------
N0 <- 20
K  <- 400
r_vals <- c(0.10, 0.25, 0.50)
t  <- seq(0, 35, by = 0.25)

tabla_e3 <- purrr::map_dfr(
  r_vals,
  function(ri) {
    tibble::tibble(
      t = t,
      r = factor(ri),
      N = logistico_N(t, N0 = N0, r = ri, K = K)
    )
  }
)

fig_e3 <- ggplot2::ggplot(
  tabla_e3,
  ggplot2::aes(t, N, group = r, linetype = r)
) +
  ggplot2::geom_line(linewidth = 1.05) +
  ggplot2::geom_hline(yintercept = K, linetype = 2) +
  ggplot2::labs(
    title = "Efecto de la tasa intrínseca de crecimiento (r)",
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)",
    linetype = "r"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e3,
  filename = "fig-c4-15_logistico_efecto_r.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 4 — Velocidad de crecimiento dN/dt
# ---------------------------------------------------------
N_vals <- seq(0, K, length.out = 300)

tabla_e4 <- tibble::tibble(
  N = N_vals,
  dNdt = r * N_vals * (1 - N_vals / K)
)

fig_e4 <- ggplot2::ggplot(tabla_e4, ggplot2::aes(N, dNdt)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_vline(xintercept = K / 2, linetype = 2) +
  ggplot2::labs(
    title = "Velocidad de crecimiento en el modelo logístico",
    subtitle = "dN/dt = rN(1 - N/K)",
    x = "Tamaño poblacional (N)",
    y = "Velocidad de aumento (dN/dt)"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e4,
  filename = "fig-c4-16_logistico_dNdt.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 5 — Máximo crecimiento en K/2
# ---------------------------------------------------------
tabla_e5 <- tibble::tibble(
  r = c(0.10, 0.20, 0.35, 0.50),
  K = c(100, 200, 300, 500)
) |>
  dplyr::mutate(
    N_critico = K / 2,
    dNdt_max = r * (K / 2) * (1 - (K / 2) / K)
  )

guardar_tabla_csv(
  data = tabla_e5,
  filename = "tabla-c4-07_maximo_crecimiento_logistico.csv"
)

fig_e5 <- ggplot2::ggplot(tabla_e5, ggplot2::aes(K, dNdt_max)) +
  ggplot2::geom_point(size = 2.8) +
  ggplot2::geom_line() +
  ggplot2::labs(
    title = "Máximo crecimiento poblacional en el modelo logístico",
    subtitle = "dN/dt máx = rK/4",
    x = "Capacidad de carga (K)",
    y = "dN/dt máximo"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e5,
  filename = "fig-c4-17_logistico_maximo_crecimiento.png",
  width = 7,
  height = 4.8
)

cat("Finalizado: modelo logístico - fundamentos.\n")
