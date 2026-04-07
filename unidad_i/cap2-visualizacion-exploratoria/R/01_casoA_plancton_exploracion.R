# =========================================================
# ANVIDEA - Unidad I
# Capítulo 2 - Visualización exploratoria de datos ecológicos
# Archivo: 01_casoA_plancton_exploracion_ajustado.R
# Propósito: desarrollar el caso de mesozooplancton estuarino
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

# ---------------------------------------------------------
# 1. Cargar datos en formato largo
# ---------------------------------------------------------

plancton_path <- file.path(data_dir, "plancton.xlsx")

if (!file.exists(plancton_path)) {
  stop("No se encontró el archivo: ", plancton_path)
}

biol <- readxl::read_xlsx(plancton_path, sheet = "Riqueza")

columnas_requeridas <- c(
  "Station", "Size", "Layers", "Groups",
  "Abundance", "Temperature", "Salinity", "Density"
)

faltantes <- setdiff(columnas_requeridas, names(biol))
if (length(faltantes) > 0) {
  stop(
    "Faltan columnas requeridas en la hoja 'Riqueza': ",
    paste(faltantes, collapse = ", ")
  )
}

biol <- biol %>%
  dplyr::mutate(
    dplyr::across(c(Station, Size, Layers, Groups), as.factor),
    dplyr::across(c(Abundance, Temperature, Salinity, Density), as.numeric)
  )

# ---------------------------------------------------------
# 2. Crear base en formato ancho para visualizaciones
# ---------------------------------------------------------

biol1 <- biol %>%
  dplyr::mutate(Abrev = abreviar_taxones(Groups, minlength = 4)) %>%
  dplyr::group_by(Station, Size, Layers) %>%
  dplyr::summarise(
    Temperature = round(mean(Temperature, na.rm = TRUE), 2),
    Salinity    = round(mean(Salinity, na.rm = TRUE), 2),
    Density     = round(mean(Density, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  dplyr::left_join(
    biol %>%
      dplyr::mutate(Abrev = abreviar_taxones(Groups, minlength = 4)) %>%
      dplyr::group_by(Station, Size, Layers, Abrev) %>%
      dplyr::summarise(Abund = sum(Abundance, na.rm = TRUE), .groups = "drop") %>%
      tidyr::pivot_wider(
        names_from = Abrev,
        values_from = Abund,
        values_fill = 0
      ),
    by = c("Station", "Size", "Layers")
  ) %>%
  dplyr::mutate(
    Ref = paste0(substr(as.character(Station), 1, 2),
                 substr(as.character(Size), 1, 1),
                 substr(as.character(Layers), 1, 1))
  ) %>%
  dplyr::relocate(Ref, .before = 1)

cols_taxa <- setdiff(names(biol1), c("Ref", "Station", "Size", "Layers", "Temperature", "Salinity", "Density"))
if (length(cols_taxa) == 0) {
  stop("No se generaron columnas taxonómicas en la base ancha.")
}

biol1 <- biol1 %>%
  dplyr::mutate(
    Ab = rowSums(dplyr::across(dplyr::all_of(cols_taxa)), na.rm = TRUE)
  ) %>%
  dplyr::select(Ref, Station, Size, Layers, Temperature, Salinity, Density, Ab, dplyr::everything())

guardar_tabla_excel(biol1, "tabla_01_base_ancha_plancton.xlsx")

# ---------------------------------------------------------
# 3. Matrices de correlación
# ---------------------------------------------------------

M <- stats::cor(
  biol1[, c("Ab", cols_taxa)],
  use = "pairwise.complete.obs"
)

M1 <- stats::cor(
  biol1[, c("Temperature", "Salinity", "Density")],
  biol1[, c("Ab", cols_taxa)],
  use = "pairwise.complete.obs"
)

grDevices::png("outputs/figuras/fig_01_corr_ellipse.png", width = 1800, height = 1200, res = 220)
corrplot::corrplot(M, method = "ellipse")
grDevices::dev.off()

grDevices::png("outputs/figuras/fig_02_corr_mixed.png", width = 1800, height = 1500, res = 220)
corrplot::corrplot.mixed(M, upper = "ellipse")
grDevices::dev.off()

grDevices::png("outputs/figuras/fig_03_corr_coeficientes.png", width = 1800, height = 1500, res = 220)
corrplot::corrplot(
  M,
  method = "circle",
  type = "lower",
  insig = "blank",
  order = "AOE",
  diag = FALSE,
  addCoef.col = "black",
  number.cex = 0.8,
  col = corrplot::COL2("RdYlBu", 200)
)
grDevices::dev.off()

grDevices::png("outputs/figuras/fig_04_corr_ambiente_taxones.png", width = 1800, height = 1500, res = 220)
corrplot::corrplot(M1, method = "ellipse", type = "upper")
grDevices::dev.off()

# ---------------------------------------------------------
# 4. Pairs con variables ambientales
# ---------------------------------------------------------

grDevices::png("outputs/figuras/fig_05_pairs_ambientales.png", width = 1800, height = 1800, res = 220)
pairs(
  biol1[, c("Temperature", "Salinity", "Density")],
  diag.panel = panel.hist,
  upper.panel = panel.cor,
  lower.panel = panel.smooth
)
grDevices::dev.off()

# ---------------------------------------------------------
# 5. Histogramas y densidades
# ---------------------------------------------------------

biol1 <- biol1 %>%
  dplyr::mutate(
    Layers = dplyr::recode_factor(
      Layers,
      "Depth" = "Profunda",
      "Surface" = "Superficial"
    )
  )

p_densidad <- ggplot2::ggplot(biol1, ggplot2::aes(x = Ab, color = Layers)) +
  ggplot2::geom_density(ggplot2::aes(fill = Layers), alpha = 0.5) +
  ggplot2::labs(y = "Densidad", x = "Abundancia", color = "Capas", fill = "Capas") +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_densidad, "fig_06_densidad_capas.png")

p_densidad_size <- ggplot2::ggplot(biol1, ggplot2::aes(x = Ab, color = Layers)) +
  ggplot2::geom_density(ggplot2::aes(fill = Layers), alpha = 0.4) +
  ggplot2::labs(y = "Densidad", x = "Abundancia", color = "Capas", fill = "Capas") +
  ggplot2::facet_wrap(~Size) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_densidad_size, "fig_07_densidad_capas_talla.png")

# ---------------------------------------------------------
# 6. Dispersión X-Y
# ---------------------------------------------------------

p_lm <- ggplot2::ggplot(biol1, ggplot2::aes(x = Density, y = Ab)) +
  ggplot2::geom_point(ggplot2::aes(color = Layers), size = 3) +
  ggplot2::geom_smooth(method = "lm", se = FALSE) +
  ggplot2::labs(y = "Abundancia de zooplancton", x = "Densidad del agua", color = "Capas") +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_lm, "fig_08_dispersion_lm.png")

p_loess <- ggplot2::ggplot(biol1, ggplot2::aes(x = Density, y = Ab)) +
  ggplot2::geom_point(ggplot2::aes(color = Layers), size = 3) +
  ggplot2::geom_smooth(method = "loess", se = TRUE) +
  ggplot2::labs(y = "Abundancia de zooplancton", x = "Densidad del agua", color = "Capas") +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_loess, "fig_09_dispersion_loess.png")

# ---------------------------------------------------------
# 7. Burbujas por salinidad
# ---------------------------------------------------------

biol_burb <- biol %>%
  dplyr::mutate(
    Abrev = abreviar_taxones(Groups, minlength = 4)
  ) %>%
  dplyr::group_by(Station, Groups, Abrev) %>%
  dplyr::summarise(
    Abundance = mean(Abundance, na.rm = TRUE),
    Salinity = mean(Salinity, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::group_by(Groups) %>%
  dplyr::mutate(total_ab = sum(Abundance, na.rm = TRUE)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    Groups = forcats::fct_reorder(Groups, total_ab, .desc = TRUE),
    Abrev = forcats::fct_reorder(Abrev, total_ab, .desc = TRUE)
  )

guardar_tabla_excel(biol_burb, "tabla_02_burbujas_salinidad.xlsx")

p_burb <- ggplot2::ggplot(biol_burb, ggplot2::aes(x = Salinity, y = Abrev)) +
  ggplot2::geom_point(
    ggplot2::aes(size = Abundance, fill = Station),
    shape = 21, alpha = 0.7, color = "grey20"
  ) +
  ggplot2::scale_size_continuous(range = c(2, 12), name = "Abundancia") +
  ggplot2::labs(x = "Salinidad", y = "Grupos abreviados", fill = "Estación") +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_burb, "fig_10_burbujas_salinidad.png", width = 9, height = 6)

# ---------------------------------------------------------
# 8. Objeto de salida del caso
# ---------------------------------------------------------

resultados_casoA <- list(
  biol1 = biol1,
  M = M,
  M1 = M1,
  biol_burb = biol_burb,
  p_densidad = p_densidad,
  p_densidad_size = p_densidad_size,
  p_lm = p_lm,
  p_loess = p_loess,
  p_burb = p_burb
)

message("Caso A terminado. Revise outputs/figuras y outputs/tablas.")

resultados_casoA
