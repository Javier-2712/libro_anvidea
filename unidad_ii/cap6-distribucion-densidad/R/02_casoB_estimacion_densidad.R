# =========================================================
# ANDIVEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# Archivo: 02_casoB_estimacion_densidad.R
# Propósito: estimar densidad con métodos basados en distancias
#             (Holgate, King y Hayne)
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

archivo_datos <- file.path(data_dir, "datos.c6.xlsx")

message("→ Leyendo datos del caso B...")

# ---------------------------------------------------------
# Paso 1. Método de Holgate (IH)
# ---------------------------------------------------------
datos1 <- readxl::read_excel(archivo_datos, sheet = "densidad1") %>%
  dplyr::rename_with(tolower)

col_x2 <- names(datos1)[names(datos1) %in% c("x2_m", "x2", "xi2", "dist2_m")]

if (length(col_x2) == 0) {
  stop("No se encontró una columna equivalente a 'x2_m' en la hoja 'densidad1'.")
}

ih <- datos1 %>%
  dplyr::transmute(x2 = as.numeric(.data[[col_x2[1]]])) %>%
  dplyr::filter(is.finite(x2), x2 > 0)

if (nrow(ih) == 0) {
  stop("No hay valores válidos para el método de Holgate en la hoja 'densidad1'.")
}

dens_ih_m2 <- 1 / (pi * mean(ih$x2, na.rm = TRUE))
dens_ih_ha <- dens_ih_m2 * 10000

res_ih <- tibble::tibble(
  metodo = "Holgate",
  densidad_m2 = dens_ih_m2,
  densidad_ha = dens_ih_ha
)

# ---------------------------------------------------------
# Paso 2. Métodos de King y Hayne
# ---------------------------------------------------------
datos2 <- readxl::read_excel(archivo_datos, sheet = "densidad2") %>%
  dplyr::rename_with(tolower)

col_di <- names(datos2)[names(datos2) %in% c("di_m", "di", "distancia", "d")]
col_inv <- names(datos2)[names(datos2) %in% c("1/di", "invdi", "inv_di")]

if (length(col_di) == 0) {
  stop("No se encontró una columna equivalente a 'di_m' en la hoja 'densidad2'.")
}

d <- datos2 %>%
  dplyr::transmute(
    di = as.numeric(.data[[col_di[1]]]),
    invdi = if (length(col_inv) > 0) {
      as.numeric(.data[[col_inv[1]]])
    } else {
      1 / as.numeric(.data[[col_di[1]]])
    }
  ) %>%
  dplyr::filter(is.finite(di), di > 0, is.finite(invdi), invdi > 0)

if (nrow(d) == 0) {
  stop("No hay valores válidos para los métodos de King y Hayne en la hoja 'densidad2'.")
}

# Longitud de referencia reportada en el material original
L <- 28.284271

dens_king_m2 <- 1 / (2 * mean(d$di, na.rm = TRUE)^2)
dens_hayne_m2 <- (mean(d$invdi, na.rm = TRUE)^2) / pi

res_dist <- tibble::tibble(
  metodo = c("King", "Hayne"),
  densidad_m2 = c(dens_king_m2, dens_hayne_m2),
  densidad_ha = c(dens_king_m2, dens_hayne_m2) * 10000,
  longitud_referencia = L
)

resumen_general <- dplyr::bind_rows(res_ih, res_dist)

# ---------------------------------------------------------
# Paso 3. Visualización
# ---------------------------------------------------------
message("→ Generando figuras del caso B...")

p1 <- ggplot2::ggplot(d, ggplot2::aes(di)) +
  ggplot2::geom_histogram(bins = 15) +
  ggplot2::geom_vline(xintercept = mean(d$di, na.rm = TRUE), linetype = 2) +
  ggplot2::labs(
    title = "Distribución de distancias d[i] (King)",
    x = "Distancia perpendicular (m)",
    y = "Frecuencia"
  ) +
  ggplot2::theme_bw()

p2 <- ggplot2::ggplot(d, ggplot2::aes(invdi)) +
  ggplot2::geom_histogram(bins = 15) +
  ggplot2::geom_vline(xintercept = mean(d$invdi, na.rm = TRUE), linetype = 2) +
  ggplot2::labs(
    title = "Distribución de 1/d[i] (Hayne)",
    x = "1 / distancia",
    y = "Frecuencia"
  ) +
  ggplot2::theme_bw()

if (requireNamespace("cowplot", quietly = TRUE)) {
  fig <- cowplot::plot_grid(p1, p2, ncol = 2)
  guardar_figura(fig, "cap6_metodos_densidad_distancias.png", width = 11, height = 5)
} else {
  guardar_figura(p1, "cap6_histograma_king.png", width = 7, height = 5)
  guardar_figura(p2, "cap6_histograma_hayne.png", width = 7, height = 5)
}

# ---------------------------------------------------------
# Paso 4. Exportación de resultados
# ---------------------------------------------------------
message("→ Exportando tablas del caso B...")

guardar_tabla_excel(
  list(
    datos_holgate = ih,
    datos_king_hayne = d,
    holgate = res_ih,
    king_hayne = res_dist,
    resumen_general = resumen_general
  ),
  archivo = "cap6_estimacion_densidad.xlsx"
)

message("✔ Capítulo 6 - Caso B ejecutado correctamente")
