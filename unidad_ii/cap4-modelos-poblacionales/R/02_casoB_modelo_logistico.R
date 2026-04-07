# =========================================================
# ANVIDEA - Unidad II
# Capítulo 4 - Modelos poblacionales
# Archivo: 02_casoB_modelo_logistico_ajustado.R
# Propósito: desarrollar ejemplos y visualizaciones del modelo logístico
# =========================================================

source("R/00_setup.R")

if (!exists("modelo_logistico")) {
  source("R/03_funciones_auxiliares.R")
}

# ---------------------------------------------------------
# B. Modelo logístico
# ---------------------------------------------------------

# =========================================================
# B.1 Trayectoria y velocidad de cambio
# =========================================================

N0 <- 50
K <- 1000
r <- 0.2
t <- seq(0, 40, by = 0.25)

datos_log <- modelo_logistico(N0 = N0, K = K, r = r, t = t) %>%
  dplyr::mutate(
    dNdt = velocidad_logistica(N, r, K),
    N_k2 = K / 2
  )

p_n <- ggplot2::ggplot(datos_log, ggplot2::aes(t, N)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_hline(yintercept = K, linetype = 2) +
  ggplot2::labs(
    title = "Crecimiento logístico",
    subtitle = paste0("N0 = ", N0, ", K = ", K, ", r = ", r),
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)"
  ) +
  ggplot2::theme_bw()

p_v <- ggplot2::ggplot(datos_log, ggplot2::aes(N, dNdt)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_vline(xintercept = K / 2, linetype = 2) +
  ggplot2::labs(
    title = "Velocidad de cambio logístico",
    subtitle = "Máximo crecimiento en K/2",
    x = "Tamaño poblacional (N)",
    y = "dN/dt"
  ) +
  ggplot2::theme_bw()

guardar_figura(
  cowplot::plot_grid(p_n, p_v, ncol = 2),
  "cap4_logistico_trayectoria_y_velocidad.png",
  width = 11,
  height = 5
)

# =========================================================
# B.2 Sensibilidad a parámetros
# =========================================================

datos_r <- purrr::map_dfr(
  c(0.1, 0.2, 0.4),
  function(rv) {
    modelo_logistico(
      N0 = 50,
      K = 1000,
      r = rv,
      t = seq(0, 40, by = 0.25)
    ) %>%
      dplyr::mutate(escenario = paste0("r = ", rv))
  }
)

datos_k <- purrr::map_dfr(
  c(500, 1000, 1500),
  function(Kv) {
    modelo_logistico(
      N0 = 50,
      K = Kv,
      r = 0.2,
      t = seq(0, 40, by = 0.25)
    ) %>%
      dplyr::mutate(escenario = paste0("K = ", Kv))
  }
)

p_r <- ggplot2::ggplot(datos_r, ggplot2::aes(t, N, color = escenario)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Efecto de r",
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)",
    color = "Escenario"
  ) +
  ggplot2::theme_bw()

p_k <- ggplot2::ggplot(datos_k, ggplot2::aes(t, N, color = escenario)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Efecto de K",
    x = "Tiempo (t)",
    y = "Tamaño poblacional (N)",
    color = "Escenario"
  ) +
  ggplot2::theme_bw()

guardar_figura(
  cowplot::plot_grid(p_r, p_k, ncol = 2),
  "cap4_logistico_efecto_r_y_K.png",
  width = 11,
  height = 5
)

# =========================================================
# B.3 Preguntas de cálculo
# =========================================================

preguntas <- tibble::tribble(
  ~N0, ~K, ~r, ~t, ~fraccion_K,
   100,  400, 0.02, 180, 0.80,
    50,  800, 0.08,  NA, 0.75,
   200, 1000, 0.05,  NA, 0.95
) %>%
  dplyr::mutate(
    N_t = dplyr::if_else(
      is.na(t),
      NA_real_,
      K / (1 + ((K - N0) / N0) * exp(-r * t))
    ),
    tiempo_umbral = tiempo_hasta_fraccion_K(N0, K, r, fraccion_K),
    dNdt_max = r * (K / 2) * (1 - (K / 2) / K)
  )

guardar_tabla_excel(preguntas, "cap4_tabla_preguntas_logistico.xlsx")

# =========================================================
# B.4 Natalidad y mortalidad dependientes de la densidad
# =========================================================

b_p <- function(N) 0.12 + 0.01 * N - 0.0001 * N^2
d_p <- function(N) 0.18 + 0.008 * N

tabla_bd <- tibble::tibble(N = seq(0, 60, by = 1)) %>%
  dplyr::mutate(
    b = b_p(N),
    d = d_p(N),
    balance = b - d
  )

tabla_bd_larga <- tabla_bd %>%
  tidyr::pivot_longer(
    cols = c(b, d, balance),
    names_to = "tasa",
    values_to = "valor"
  )

p_bd <- ggplot2::ggplot(tabla_bd_larga, ggplot2::aes(N, valor, color = tasa, linetype = tasa)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_hline(yintercept = 0, linetype = 3) +
  ggplot2::labs(
    title = "b'(N), d'(N) y balance per cápita",
    x = "Densidad poblacional (N)",
    y = "Tasa per cápita",
    color = "Componente",
    linetype = "Componente"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_bd, "cap4_b_y_d_dependientes_densidad.png", width = 8, height = 5)

# ---------------------------------------------------------
# Exportación
# ---------------------------------------------------------

writexl::write_xlsx(
  list(
    trayectoria_logistica = datos_log,
    sensibilidad_r = datos_r,
    sensibilidad_K = datos_k,
    preguntas_logistico = preguntas,
    tasas_dependientes_densidad = tabla_bd,
    tasas_dependientes_densidad_larga = tabla_bd_larga
  ),
  path = file.path("outputs", "tablas", "cap4_modelo_logistico.xlsx")
)

# ---------------------------------------------------------
# Objeto de salida
# ---------------------------------------------------------

resultados_casoB <- list(
  datos_log = datos_log,
  datos_r = datos_r,
  datos_k = datos_k,
  preguntas = preguntas,
  tabla_bd = tabla_bd,
  tabla_bd_larga = tabla_bd_larga,
  p_n = p_n,
  p_v = p_v,
  p_r = p_r,
  p_k = p_k,
  p_bd = p_bd
)

message("✔ Tablas guardadas en: outputs/tablas/")
message("✔ Figuras guardadas en: outputs/figuras/")
message("✔ Capítulo 4 - Caso B ejecutado correctamente")

resultados_casoB
