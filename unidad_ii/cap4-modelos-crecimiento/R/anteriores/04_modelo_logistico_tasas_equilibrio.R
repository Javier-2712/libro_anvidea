# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: 04_modelo_logistico_tasas_equilibrio.R
# Propósito: explorar tasas específicas dependientes de la
#            densidad y condiciones de equilibrio
# =========================================================

source("R/00_setup.R")
source("R/07_funciones_auxiliares.R")

cat("Iniciando: modelo logístico - tasas y equilibrio...\n")

b_fun <- function(N, b0 = 0.60, a = 0.0012) b0 - a * N
d_fun <- function(N, d0 = 0.10, c = 0.0008) d0 + c * N

# ---------------------------------------------------------
# Ejemplo 1 — Tasas específicas en función de N
# ---------------------------------------------------------
N_vals <- seq(0, 500, by = 1)

tabla_e1 <- tibble::tibble(
  N = N_vals,
  b_prima = b_fun(N_vals),
  d_prima = d_fun(N_vals),
  r_prima = b_prima - d_prima
)

guardar_tabla_csv(
  data = dplyr::slice(tabla_e1, seq(1, n(), by = 25)),
  filename = "tabla-c4-08_tasas_especificas_densidad.csv"
)

fig_e1 <- ggplot2::ggplot(tabla_e1, ggplot2::aes(x = N)) +
  ggplot2::geom_line(ggplot2::aes(y = b_prima, linetype = "b'(N)")) +
  ggplot2::geom_line(ggplot2::aes(y = d_prima, linetype = "d'(N)")) +
  ggplot2::labs(
    title = "Tasas específicas dependientes de la densidad",
    x = "Tamaño poblacional (N)",
    y = "Tasa específica",
    linetype = "Función"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e1,
  filename = "fig-c4-18_tasas_especificas_b_d.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 2 — Tasa neta r'(N) = b'(N) - d'(N)
# ---------------------------------------------------------
fig_e2 <- ggplot2::ggplot(tabla_e1, ggplot2::aes(N, r_prima)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_hline(yintercept = 0, linetype = 2) +
  ggplot2::labs(
    title = "Cambio en la tasa neta per cápita",
    subtitle = "r'(N) = b'(N) - d'(N)",
    x = "Tamaño poblacional (N)",
    y = "Tasa neta"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e2,
  filename = "fig-c4-19_tasa_neta_dependiente_densidad.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 3 — Punto de equilibrio
# ---------------------------------------------------------
b0 <- 0.60
a  <- 0.0012
d0 <- 0.10
c  <- 0.0008

K_eq <- (b0 - d0) / (a + c)

tabla_e3 <- tibble::tibble(
  parametro = c("b0", "a", "d0", "c", "K_equilibrio"),
  valor = c(b0, a, d0, c, K_eq)
)

guardar_tabla_csv(
  data = tabla_e3,
  filename = "tabla-c4-09_equilibrio_logistico.csv"
)

fig_e3 <- ggplot2::ggplot(tabla_e1, ggplot2::aes(x = N)) +
  ggplot2::geom_line(ggplot2::aes(y = b_prima, linetype = "b'(N)")) +
  ggplot2::geom_line(ggplot2::aes(y = d_prima, linetype = "d'(N)")) +
  ggplot2::geom_vline(xintercept = K_eq, linetype = 2) +
  ggplot2::labs(
    title = "Equilibrio poblacional por intersección de tasas",
    subtitle = paste0("K ≈ ", round(K_eq, 1)),
    x = "Tamaño poblacional (N)",
    y = "Tasa específica",
    linetype = "Función"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e3,
  filename = "fig-c4-20_equilibrio_por_interseccion.png",
  width = 7,
  height = 4.8
)

# ---------------------------------------------------------
# Ejemplo 4 — Estabilidad alrededor del equilibrio
# ---------------------------------------------------------
tabla_e4 <- tibble::tibble(
  N = seq(0, 500, by = 1)
) |>
  dplyr::mutate(
    dNdt = 0.35 * N * (1 - N / K_eq)
  )

fig_e4 <- ggplot2::ggplot(tabla_e4, ggplot2::aes(N, dNdt)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_hline(yintercept = 0, linetype = 2) +
  ggplot2::geom_vline(xintercept = K_eq, linetype = 2) +
  ggplot2::labs(
    title = "Estabilidad del equilibrio logístico",
    x = "Tamaño poblacional (N)",
    y = "dN/dt"
  ) +
  ggplot2::theme_bw()

guardar_figura_anvidea(
  plot = fig_e4,
  filename = "fig-c4-21_estabilidad_equilibrio_logistico.png",
  width = 7,
  height = 4.8
)

cat("Finalizado: modelo logístico - tasas y equilibrio.\n")
