# =========================================================
# ANVIDEA - Unidad I
# Capítulo 2 - Visualización exploratoria de datos ecológicos
# Archivo: 02_casoB_macroinvertebrados_exploracion_ajustado.R
# Propósito: desarrollar el caso de ensamblajes fluviales de macroinvertebrados
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

# ---------------------------------------------------------
# 1. Cargar bases
# ---------------------------------------------------------

invert_path <- file.path(data_dir, "invert.xlsx")

if (!file.exists(invert_path)) {
  stop("No se encontró el archivo: ", invert_path)
}

biol <- readxl::read_xlsx(invert_path, sheet = "Taxones1")
amb  <- readxl::read_xlsx(invert_path, sheet = "fquímicos")

columnas_biol <- c("Sitio", "Microh")
columnas_amb  <- c("Sitio")

faltan_biol <- setdiff(columnas_biol, names(biol))
faltan_amb  <- setdiff(columnas_amb, names(amb))

if (length(faltan_biol) > 0) {
  stop("Faltan columnas en 'Taxones1': ", paste(faltan_biol, collapse = ", "))
}
if (length(faltan_amb) > 0) {
  stop("Faltan columnas en 'fquímicos': ", paste(faltan_amb, collapse = ", "))
}

# En la versión original se eliminaban columnas por posición.
# Aquí se conservan solo Sitio y las variables ambientales numéricas.
amb <- amb %>%
  dplyr::select(Sitio, where(is.numeric))

# ---------------------------------------------------------
# 2. Abreviar taxones y seleccionar los más abundantes
# ---------------------------------------------------------

biol_taxa <- biol %>%
  dplyr::select(-dplyr::any_of(c("Sitio", "Microh", "Total"))) %>%
  dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric))

if (ncol(biol_taxa) == 0) {
  stop("No se encontraron columnas taxonómicas en 'Taxones1'.")
}

nombres_abrev <- abreviar_taxones(names(biol_taxa), minlength = 4)
nombres_abrev <- make.unique(nombres_abrev, sep = "_")
names(biol_taxa) <- nombres_abrev

prom <- colMeans(biol_taxa, na.rm = TRUE)

n_top <- min(15, length(prom))
ab <- names(sort(prom, decreasing = TRUE)[seq_len(n_top)])

biol2 <- dplyr::bind_cols(
  biol %>% dplyr::select(Sitio),
  biol_taxa[, ab, drop = FALSE]
)

biol3 <- biol2 %>%
  dplyr::group_by(Sitio) %>%
  dplyr::summarise(
    dplyr::across(dplyr::everything(), ~ mean(.x, na.rm = TRUE)),
    .groups = "drop"
  )

guardar_tabla_excel(biol3, "tabla_01_taxones_abundantes_por_sitio.xlsx")

# ---------------------------------------------------------
# 3. Promedios de variables ambientales por sitio
# ---------------------------------------------------------

amb1 <- amb %>%
  dplyr::group_by(Sitio) %>%
  dplyr::summarise(
    dplyr::across(where(is.numeric), ~ mean(.x, na.rm = TRUE)),
    .groups = "drop"
  )

guardar_tabla_excel(amb1, "tabla_02_promedios_ambientales_por_sitio.xlsx")

# ---------------------------------------------------------
# 4. Integración biológica y ambiental
# ---------------------------------------------------------

bioamb <- dplyr::left_join(amb1, biol3, by = "Sitio")
guardar_tabla_excel(bioamb, "tabla_03_integracion_bioambiental.xlsx")

# ---------------------------------------------------------
# 5. Correlograma
# ---------------------------------------------------------

mat_rel <- bioamb %>% dplyr::select(where(is.numeric))

if (ncol(mat_rel) < 2) {
  stop("No hay suficientes variables numéricas para calcular la matriz de correlación.")
}

M <- stats::cor(mat_rel, use = "pairwise.complete.obs")

grDevices::png("outputs/figuras/fig_01_correlograma.png", width = 1800, height = 1500, res = 220)
corrplot::corrplot(M, method = "ellipse", type = "upper")
grDevices::dev.off()

# ---------------------------------------------------------
# 6. Abundancia total por sitio y microhábitat
# ---------------------------------------------------------

ab_total <- biol_taxa %>%
  dplyr::mutate(Ab = rowSums(dplyr::across(dplyr::everything()), na.rm = TRUE)) %>%
  dplyr::bind_cols(
    biol %>% dplyr::select(Sitio, Microh)
  )

p_box_sitio <- ggplot2::ggplot(ab_total, ggplot2::aes(x = Sitio, y = Ab, fill = Sitio)) +
  ggplot2::geom_boxplot(alpha = 0.8) +
  ggplot2::labs(x = "Sitio", y = "Abundancia total") +
  ggplot2::theme_bw() +
  ggplot2::theme(legend.position = "none", panel.grid = ggplot2::element_blank())

guardar_figura(p_box_sitio, "fig_02_boxplot_sitio.png")

p_box_microh <- ggplot2::ggplot(ab_total, ggplot2::aes(x = Microh, y = Ab, fill = Microh)) +
  ggplot2::geom_boxplot(alpha = 0.8) +
  ggplot2::labs(x = "Microhábitat", y = "Abundancia total") +
  ggplot2::theme_bw() +
  ggplot2::theme(legend.position = "none", panel.grid = ggplot2::element_blank())

guardar_figura(p_box_microh, "fig_03_boxplot_microhabitat.png")

p_box_inter <- ggplot2::ggplot(ab_total, ggplot2::aes(x = Sitio, y = Ab, fill = Microh)) +
  ggplot2::geom_boxplot() +
  ggplot2::labs(x = "Sitio", y = "Abundancia total", fill = "Microhábitat") +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_box_inter, "fig_04_boxplot_sitio_microhabitat.png", width = 9, height = 5)

# ---------------------------------------------------------
# 7. Figura con estimadores estadísticos
# ---------------------------------------------------------

resumen_sitio <- ab_total %>%
  dplyr::group_by(Sitio) %>%
  dplyr::summarise(
    media = mean(Ab, na.rm = TRUE),
    se = stats::sd(Ab, na.rm = TRUE) / sqrt(dplyr::n()),
    .groups = "drop"
  )

guardar_tabla_excel(resumen_sitio, "tabla_04_estimadores_por_sitio.xlsx")

p_est <- ggplot2::ggplot(resumen_sitio, ggplot2::aes(x = Sitio, y = media)) +
  ggplot2::geom_col(fill = "grey70", color = "grey20") +
  ggplot2::geom_errorbar(
    ggplot2::aes(ymin = pmax(media - se, 0), ymax = media + se),
    width = 0.15
  ) +
  ggplot2::labs(x = "Sitio", y = "Abundancia media ± EE") +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_est, "fig_05_estimadores_sitio.png")

# ---------------------------------------------------------
# 8. Burbujas con oxígeno
# ---------------------------------------------------------

if ("Oxigeno" %in% names(amb1)) {
  ox <- amb1 %>%
    dplyr::select(Sitio, Oxigeno)

  top_taxa <- biol3 %>%
    tidyr::pivot_longer(-Sitio, names_to = "Taxon", values_to = "Abundancia") %>%
    dplyr::left_join(ox, by = "Sitio")

  guardar_tabla_excel(top_taxa, "tabla_05_burbujas_oxigeno.xlsx")

  p_burb_ox <- ggplot2::ggplot(top_taxa, ggplot2::aes(x = Oxigeno, y = Taxon)) +
    ggplot2::geom_point(
      ggplot2::aes(size = Abundancia, fill = Sitio),
      shape = 21, alpha = 0.7, color = "grey20"
    ) +
    ggplot2::scale_size_continuous(range = c(2, 11), name = "Abundancia") +
    ggplot2::labs(x = "Oxígeno disuelto", y = "Taxones abreviados", fill = "Sitio") +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.grid = ggplot2::element_blank())

  guardar_figura(p_burb_ox, "fig_06_burbujas_oxigeno.png", width = 9, height = 6)
} else {
  top_taxa <- NULL
  p_burb_ox <- NULL
}

# ---------------------------------------------------------
# 9. Objeto de salida del caso
# ---------------------------------------------------------

resultados_casoB <- list(
  biol2 = biol2,
  biol3 = biol3,
  amb1 = amb1,
  bioamb = bioamb,
  M = M,
  ab_total = ab_total,
  resumen_sitio = resumen_sitio,
  top_taxa = top_taxa,
  p_box_sitio = p_box_sitio,
  p_box_microh = p_box_microh,
  p_box_inter = p_box_inter,
  p_est = p_est,
  p_burb_ox = p_burb_ox
)

message("Caso B terminado. Revise outputs/figuras y outputs/tablas.")

resultados_casoB
