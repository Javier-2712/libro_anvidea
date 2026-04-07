# =========================================================
# ANVIDEA - Unidad I
# Capítulo 3 - Visualización gráfica de patrones climáticos
# Archivo: 01_casoA_series_climaticas_ajustado.R
# Propósito: desarrollar el caso de series climáticas mensuales e interanuales
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

# ---------------------------------------------------------
# 1. Cargar datos
# ---------------------------------------------------------

estaciones_path <- file.path(data_dir, "estaciones.xlsx")
datos_path <- file.path(data_dir, "datos.xlsx")

if (!file.exists(estaciones_path)) {
  stop("No se encontró el archivo: ", estaciones_path)
}

if (!file.exists(datos_path)) {
  stop("No se encontró el archivo: ", datos_path)
}

estaciones <- readxl::read_xlsx(estaciones_path, sheet = "estaciones") %>%
  janitor::clean_names()

serie_temp <- readxl::read_xlsx(datos_path, sheet = "serie_temp")
serie_precip <- readxl::read_xlsx(datos_path, sheet = "serie_precipit")

columnas_requeridas <- c("Estación", "Meses")
faltan_temp <- setdiff(columnas_requeridas, names(serie_temp))
faltan_precip <- setdiff(columnas_requeridas, names(serie_precip))

if (length(faltan_temp) > 0) {
  stop("Faltan columnas en 'serie_temp': ", paste(faltan_temp, collapse = ", "))
}

if (length(faltan_precip) > 0) {
  stop("Faltan columnas en 'serie_precipit': ", paste(faltan_precip, collapse = ", "))
}

# ---------------------------------------------------------
# 2. Preparar series climáticas
# ---------------------------------------------------------

serie_temp_long <- serie_temp %>%
  tidyr::pivot_longer(
    cols = -c(`Estación`, Meses),
    names_to = "anio",
    values_to = "temperatura"
  ) %>%
  dplyr::filter(!is.na(temperatura), anio != "Promedio") %>%
  dplyr::mutate(
    anio = suppressWarnings(as.numeric(anio)),
    temperatura = as.numeric(temperatura),
    Meses = ordenar_meses_min(Meses)
  ) %>%
  dplyr::filter(!is.na(anio), !is.na(Meses))

serie_precip_long <- serie_precip %>%
  tidyr::pivot_longer(
    cols = -c(`Estación`, Meses),
    names_to = "anio",
    values_to = "precip_mm"
  ) %>%
  dplyr::filter(!is.na(precip_mm), anio != "Promedio") %>%
  dplyr::mutate(
    anio = suppressWarnings(as.numeric(anio)),
    precip_mm = as.numeric(precip_mm),
    Meses = ordenar_meses_min(Meses)
  ) %>%
  dplyr::filter(!is.na(anio), !is.na(Meses))

if (nrow(serie_temp_long) == 0) {
  stop("La serie de temperatura quedó vacía después de la transformación.")
}

if (nrow(serie_precip_long) == 0) {
  stop("La serie de precipitación quedó vacía después de la transformación.")
}

guardar_tabla_excel(estaciones, "tabla_00_estaciones_limpias.xlsx")
guardar_tabla_excel(serie_temp_long, "tabla_01_serie_temperatura_larga.xlsx")
guardar_tabla_excel(serie_precip_long, "tabla_02_serie_precipitacion_larga.xlsx")

# ---------------------------------------------------------
# 3. Temperatura mensual e interanual
# ---------------------------------------------------------

p_temp_mensual <- ggplot2::ggplot(
  serie_temp_long,
  ggplot2::aes(x = Meses, y = temperatura, group = anio, color = anio)
) +
  ggplot2::geom_line(alpha = 0.25, linewidth = 0.6) +
  ggplot2::stat_summary(
    fun = mean,
    geom = "line",
    color = "black",
    linewidth = 1.2,
    ggplot2::aes(group = 1)
  ) +
  ggplot2::facet_wrap(~ `Estación`, ncol = 1) +
  ggplot2::scale_color_viridis_c(option = "plasma", guide = "none") +
  ggplot2::labs(
    title = "Variación mensual de la temperatura",
    x = "Mes",
    y = "Temperatura (°C)"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    strip.text = ggplot2::element_text(face = "bold"),
    panel.grid = ggplot2::element_blank()
  )

guardar_figura(p_temp_mensual, "fig_01_temperatura_mensual.png", width = 10, height = 8)

media_anual_temp <- serie_temp_long %>%
  dplyr::group_by(`Estación`, anio) %>%
  dplyr::summarise(temp_media = mean(temperatura, na.rm = TRUE), .groups = "drop")

xmin_temp <- min(serie_temp_long$anio, na.rm = TRUE)
xmax_temp <- max(serie_temp_long$anio, na.rm = TRUE)

p_temp_interanual <- ggplot2::ggplot(
  serie_temp_long,
  ggplot2::aes(x = anio, y = temperatura, color = Meses, group = Meses)
) +
  ggplot2::geom_line(alpha = 0.55, linewidth = 0.7) +
  ggplot2::geom_point(alpha = 0.4, size = 0.8) +
  ggplot2::geom_line(
    data = media_anual_temp,
    ggplot2::aes(x = anio, y = temp_media, group = 1),
    inherit.aes = FALSE,
    color = "black",
    linewidth = 1.2
  ) +
  ggplot2::facet_wrap(~ `Estación`, ncol = 1, scales = "free_y") +
  ggplot2::scale_x_continuous(
    limits = c(xmin_temp, xmax_temp),
    breaks = scales::pretty_breaks(n = 8)
  ) +
  ggplot2::scale_color_viridis_d(option = "plasma", end = 0.95, name = "Mes") +
  ggplot2::labs(
    title = "Variación interanual de la temperatura",
    x = "Año",
    y = "Temperatura (°C)"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(
    strip.text = ggplot2::element_text(face = "bold"),
    panel.grid = ggplot2::element_blank()
  )

guardar_figura(p_temp_interanual, "fig_02_temperatura_interanual.png", width = 10, height = 10)

# ---------------------------------------------------------
# 4. Precipitación mensual e interanual
# ---------------------------------------------------------

p_precip_mensual <- ggplot2::ggplot(
  serie_precip_long,
  ggplot2::aes(x = Meses, y = precip_mm, group = anio, color = anio)
) +
  ggplot2::geom_line(alpha = 0.25, linewidth = 0.6) +
  ggplot2::stat_summary(
    fun = mean,
    geom = "line",
    color = "black",
    linewidth = 1.2,
    ggplot2::aes(group = 1)
  ) +
  ggplot2::facet_wrap(~ `Estación`, ncol = 1, scales = "free_y") +
  ggplot2::scale_color_viridis_c(option = "plasma", guide = "none") +
  ggplot2::labs(
    title = "Variación mensual de la precipitación",
    x = "Mes",
    y = "Precipitación (mm)"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    strip.text = ggplot2::element_text(face = "bold"),
    panel.grid = ggplot2::element_blank()
  )

guardar_figura(p_precip_mensual, "fig_03_precipitacion_mensual.png", width = 10, height = 8)

media_anual_precip <- serie_precip_long %>%
  dplyr::group_by(`Estación`, anio) %>%
  dplyr::summarise(precip_media_anual = mean(precip_mm, na.rm = TRUE), .groups = "drop")

xmin_precip <- min(serie_precip_long$anio, na.rm = TRUE)
xmax_precip <- max(serie_precip_long$anio, na.rm = TRUE)

p_precip_interanual <- ggplot2::ggplot(
  serie_precip_long,
  ggplot2::aes(x = anio, y = precip_mm, color = Meses, group = Meses)
) +
  ggplot2::geom_line(alpha = 0.55, linewidth = 0.7) +
  ggplot2::geom_point(alpha = 0.4, size = 0.8) +
  ggplot2::geom_line(
    data = media_anual_precip,
    ggplot2::aes(x = anio, y = precip_media_anual, group = 1),
    inherit.aes = FALSE,
    color = "black",
    linewidth = 1.2
  ) +
  ggplot2::facet_wrap(~ `Estación`, ncol = 1, scales = "free_y") +
  ggplot2::scale_x_continuous(
    limits = c(xmin_precip, xmax_precip),
    breaks = scales::pretty_breaks(n = 8)
  ) +
  ggplot2::scale_color_viridis_d(option = "plasma", end = 0.95, name = "Mes") +
  ggplot2::labs(
    title = "Variación interanual de la precipitación",
    x = "Año",
    y = "Precipitación (mm)"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(
    strip.text = ggplot2::element_text(face = "bold"),
    panel.grid = ggplot2::element_blank()
  )

guardar_figura(p_precip_interanual, "fig_04_precipitacion_interanual.png", width = 10, height = 10)

# ---------------------------------------------------------
# 5. Objeto de salida del caso
# ---------------------------------------------------------

resultados_casoA <- list(
  estaciones = estaciones,
  serie_temp_long = serie_temp_long,
  serie_precip_long = serie_precip_long,
  media_anual_temp = media_anual_temp,
  media_anual_precip = media_anual_precip,
  p_temp_mensual = p_temp_mensual,
  p_temp_interanual = p_temp_interanual,
  p_precip_mensual = p_precip_mensual,
  p_precip_interanual = p_precip_interanual
)

message("Caso A completado. Revise outputs/figuras y outputs/tablas.")

resultados_casoA
