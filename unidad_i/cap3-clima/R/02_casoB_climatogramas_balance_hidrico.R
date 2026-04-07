# =========================================================
# ANVIDEA - Unidad I
# Capítulo 3 - Visualización gráfica de patrones climáticos
# Archivo: 02_casoB_climatogramas_balance_hidrico_ajustado.R
# Propósito: construir climatogramas, índice de Lang y balance hídrico
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

bal_hid_path <- file.path(data_dir, "bal_hid.R")
datos_path <- file.path(data_dir, "datos.xlsx")

if (!file.exists(bal_hid_path)) {
  stop("No se encontró el archivo: ", bal_hid_path)
}

if (!file.exists(datos_path)) {
  stop("No se encontró el archivo: ", datos_path)
}

source(bal_hid_path)

if (!exists("bal_hid")) {
  stop("La función 'bal_hid' no quedó disponible después de cargar bal_hid.R")
}

if (!exists("thornthwaite_a")) {
  thornthwaite_a <- function(I) 6.75e-7 * I^3 - 7.71e-5 * I^2 + 1.792e-2 * I + 0.49239
}

# ---------------------------------------------------------
# 1. Cargar y preparar datos climáticos
# ---------------------------------------------------------

clima <- readxl::read_xlsx(datos_path, sheet = "clima") %>%
  dplyr::rename(
    estacion = `Estación`,
    mes = Mes,
    temp = Temp,
    pp = pp,
    horas_luz = horas_luz,
    dias_mes = `días_mes`,
    altura = altura
  ) %>%
  dplyr::filter(!is.na(mes), mes != "") %>%
  dplyr::mutate(
    estacion = as.character(estacion),
    mes = ifelse(mes %in% meses_may, mes, toupper(as.character(mes))),
    mes = ordenar_meses_may(mes),
    dplyr::across(c(temp, pp, horas_luz, dias_mes, altura), as.numeric),
    temp_pos = pmax(temp, 0)
  ) %>%
  dplyr::filter(!is.na(estacion), !is.na(mes))

columnas_requeridas <- c("estacion", "mes", "temp", "pp", "horas_luz", "dias_mes", "altura")
faltantes <- setdiff(columnas_requeridas, names(clima))
if (length(faltantes) > 0) {
  stop("Faltan columnas requeridas en la hoja 'clima': ", paste(faltantes, collapse = ", "))
}

if (nrow(clima) == 0) {
  stop("La base climática quedó vacía después de la preparación.")
}

guardar_tabla_excel(clima, "tabla_03_base_climatica.xlsx")

# ---------------------------------------------------------
# 2. Índice de Lang
# ---------------------------------------------------------

lang_tabla <- clima %>%
  dplyr::group_by(estacion) %>%
  dplyr::summarise(
    pp_anual_mm = sum(pp, na.rm = TRUE),
    t_media_c   = mean(temp, na.rm = TRUE),
    altura      = mean(altura, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    lang = dplyr::if_else(t_media_c > 0, pp_anual_mm / t_media_c, NA_real_),
    clase = clasificar_lang(lang)
  ) %>%
  dplyr::arrange(dplyr::desc(lang))

guardar_tabla_excel(lang_tabla, "tabla_04_indice_lang.xlsx")

cortes_plot <- c(20, 40, 60, 100, 160)

pal <- c(
  "Muy árido" = "grey30",
  "Árido" = "grey50",
  "Semiárido" = "#9FD0F1",
  "Subhúmedo seco" = "#6BAED6",
  "Húmedo" = "#4A79C5",
  "Hiperhúmedo" = "#D33F3F"
)

niveles_presentes <- levels(droplevels(lang_tabla$clase))

p_lang <- ggplot2::ggplot(lang_tabla, ggplot2::aes(x = reorder(estacion, lang), y = lang, fill = clase)) +
  ggplot2::geom_col(width = 0.75, alpha = 0.9) +
  ggplot2::geom_text(
    ggplot2::aes(label = ifelse(is.na(lang), "NA", sprintf("%.1f", lang))),
    hjust = -0.15,
    size = 3.7
  ) +
  ggplot2::geom_hline(yintercept = cortes_plot, linetype = "dashed", linewidth = 0.4, color = "grey40") +
  ggplot2::coord_flip(ylim = c(0, max(lang_tabla$lang, na.rm = TRUE) * 1.10)) +
  ggplot2::scale_fill_manual(values = pal[niveles_presentes], breaks = niveles_presentes, name = "Clase") +
  ggplot2::labs(
    title = "Índice de Lang por estación",
    subtitle = "Lang = precipitación anual / temperatura media anual",
    x = "Estación",
    y = "Índice de Lang (mm/°C)"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_lang, "fig_05_indice_lang.png", width = 9, height = 6)

# ---------------------------------------------------------
# 3. Climatogramas
# ---------------------------------------------------------

p_clima <- function(df_est, titulo = NULL) {
  ggplot2::ggplot(df_est, ggplot2::aes(x = mes)) +
    ggplot2::geom_col(
      ggplot2::aes(y = pp / 2),
      fill = "skyblue",
      alpha = 0.85,
      width = 0.8
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = temp, group = 1),
      color = "firebrick",
      linewidth = 1
    ) +
    ggplot2::geom_point(
      ggplot2::aes(y = temp),
      color = "firebrick",
      size = 2
    ) +
    ggplot2::scale_y_continuous(
      name = NULL,
      sec.axis = ggplot2::sec_axis(~ . * 2, name = NULL),
      expand = ggplot2::expansion(mult = c(0, .03))
    ) +
    ggplot2::labs(
      title = if (is.null(titulo)) unique(df_est$estacion) else titulo,
      x = "Mes"
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank()
    )
}

estaciones_plot <- c("APTO", "PNNT", "SL")
estaciones_presentes <- intersect(estaciones_plot, unique(clima$estacion))

if (length(estaciones_presentes) == 0) {
  stop("No se encontraron estaciones esperadas (APTO, PNNT, SL) en la base climática.")
}

titulos_est <- c(
  "APTO" = "APTO – Aeropuerto Simón Bolívar",
  "PNNT" = "PNNT – Parque Tayrona",
  "SL"   = "SL – San Lorenzo"
)

plots_clima <- lapply(estaciones_presentes, function(est) {
  p_clima(dplyr::filter(clima, estacion == est), titulos_est[[est]])
})

combo_clima <- cowplot::plot_grid(plotlist = plots_clima, ncol = 1, align = "v")

climatograma_final <- cowplot::ggdraw() +
  cowplot::draw_plot(combo_clima, x = 0.08, y = 0, width = 0.84, height = 1) +
  cowplot::draw_label("Temperatura (°C)", x = 0.03, y = 0.5, angle = 90, fontface = "bold", size = 13) +
  cowplot::draw_label("Precipitación (mm)", x = 0.97, y = 0.5, angle = -90, fontface = "bold", size = 13)

guardar_figura(climatograma_final, "fig_06_climatogramas.png", width = 10, height = 12)

# ---------------------------------------------------------
# 4. ETP corregida
# ---------------------------------------------------------

clima_etp <- clima %>%
  dplyr::group_by(estacion) %>%
  dplyr::mutate(I = sum((temp_pos / 5)^1.514, na.rm = TRUE)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    a_tw     = thornthwaite_a(I),
    etp_base = dplyr::if_else(I > 0, 16 * ((10 * temp_pos / I)^a_tw), 0),
    etp_cor  = etp_base * (dias_mes / 30) * (horas_luz / 12)
  )

guardar_tabla_excel(clima_etp, "tabla_05_clima_con_etp_corregida.xlsx")

# ---------------------------------------------------------
# 5. Balance hídrico
# ---------------------------------------------------------

S_max <- 100

balance <- bal_hid(
  clima,
  S_max = S_max,
  corr_horas_dias = TRUE
)

if (nrow(balance) == 0) {
  stop("El balance hídrico quedó vacío.")
}

guardar_tabla_excel(balance, "tabla_06_balance_hidrico.xlsx")

p_balance <- ggplot2::ggplot(balance, ggplot2::aes(x = mes)) +
  ggplot2::geom_col(ggplot2::aes(y = pp), fill = "skyblue", alpha = 0.6, width = 0.8) +
  ggplot2::geom_line(
    ggplot2::aes(y = etp_cor, group = 1, linetype = "ETP corregida"),
    color = "#e41a1c",
    linewidth = 1
  ) +
  ggplot2::geom_point(ggplot2::aes(y = etp_cor), color = "#e41a1c", size = 1.8) +
  ggplot2::geom_line(
    ggplot2::aes(y = ETR, group = 1, linetype = "ETR"),
    color = "#377eb8",
    linewidth = 1
  ) +
  ggplot2::geom_point(ggplot2::aes(y = ETR), color = "#377eb8", size = 1.8) +
  ggplot2::facet_wrap(~ estacion, ncol = 1, scales = "free_y") +
  ggplot2::scale_linetype_manual(
    values = c("ETP corregida" = "solid", "ETR" = "dashed"),
    name = NULL
  ) +
  ggplot2::labs(
    title = "Balance hídrico mensual por estación",
    subtitle = paste0("S_max = ", S_max, " mm"),
    x = "Mes",
    y = "mm"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(
    plot.title = ggplot2::element_text(face = "bold"),
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    legend.position = "top",
    strip.background = ggplot2::element_rect(fill = "grey90", colour = NA),
    panel.grid.minor = ggplot2::element_blank()
  )

guardar_figura(p_balance, "fig_07_balance_hidrico.png", width = 10, height = 10)

# ---------------------------------------------------------
# 6. Objeto de salida del caso
# ---------------------------------------------------------

resultados_casoB <- list(
  clima = clima,
  lang_tabla = lang_tabla,
  clima_etp = clima_etp,
  balance = balance,
  p_lang = p_lang,
  climatograma_final = climatograma_final,
  p_balance = p_balance
)

message("Caso B completado. Revise outputs/figuras y outputs/tablas.")

resultados_casoB
