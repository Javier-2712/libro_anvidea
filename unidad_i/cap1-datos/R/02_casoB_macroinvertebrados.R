# =========================================================
# ANVIDEA - Unidad I
# Capítulo 1 - Fundamentos de manipulación de datos
# Archivo: 02_casoB_macroinvertebrados_ajustado.R
# Propósito: desarrollar el caso de macroinvertebrados fluviales
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

# ---------------------------------------------------------
# 1. Cargar datos
# ---------------------------------------------------------

invert_path <- file.path(data_dir, "invert.xlsx")

if (!file.exists(invert_path)) {
  stop("No se encontró el archivo: ", invert_path)
}

inv1 <- readxl::read_xlsx(invert_path, sheet = "Taxones1")
inv2 <- readxl::read_xlsx(invert_path, sheet = "Taxones2")
fq   <- readxl::read_xlsx(invert_path, sheet = "fquímicos")

columnas_inv1 <- c("Sitio", "Microh", "Total")
columnas_inv2 <- c("Sitio")
columnas_fq   <- c("Sitio", "Oxigeno", "Conductividad", "Ancho")

faltan_inv1 <- setdiff(columnas_inv1, names(inv1))
faltan_inv2 <- setdiff(columnas_inv2, names(inv2))
faltan_fq   <- setdiff(columnas_fq, names(fq))

if (length(faltan_inv1) > 0) {
  stop("Faltan columnas en 'Taxones1': ", paste(faltan_inv1, collapse = ", "))
}
if (length(faltan_inv2) > 0) {
  stop("Faltan columnas en 'Taxones2': ", paste(faltan_inv2, collapse = ", "))
}
if (length(faltan_fq) > 0) {
  stop("Faltan columnas en 'fquímicos': ", paste(faltan_fq, collapse = ", "))
}

dplyr::glimpse(inv1)
dplyr::glimpse(inv2)
dplyr::glimpse(fq)

# Asegurar tipos apropiados
inv1 <- inv1 %>%
  dplyr::mutate(Sitio = as.character(Sitio))

inv2 <- inv2 %>%
  dplyr::mutate(Sitio = as.character(Sitio))

fq <- fq %>%
  dplyr::mutate(
    Sitio = as.character(Sitio),
    dplyr::across(-Sitio, as.numeric)
  )

# ---------------------------------------------------------
# 2. Selección y filtrado
# ---------------------------------------------------------

familias_ejemplo <- intersect(
  c("Baetidae", "Belidae", "Chironomidae"),
  names(inv1)
)

if (length(familias_ejemplo) == 0) {
  stop("No se encontraron las familias esperadas para la selección en 'Taxones1'.")
}

inv1a <- inv1 %>%
  dplyr::select(Sitio, dplyr::all_of(familias_ejemplo))

inv2a <- inv2 %>%
  dplyr::filter(Sitio != "Caracoli")

# ---------------------------------------------------------
# 3. Creación de nuevas variables
# ---------------------------------------------------------

inv1_taxones <- inv1 %>%
  dplyr::select(-dplyr::any_of(c("Sitio", "Microh", "Total"))) %>%
  dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric))

if (ncol(inv1_taxones) == 0) {
  stop("No quedaron columnas taxonómicas en 'Taxones1' para calcular abundancia.")
}

inv1 <- inv1 %>%
  dplyr::mutate(
    Abundancia = rowSums(inv1_taxones, na.rm = TRUE)
  )

# ---------------------------------------------------------
# 4. Resumen por sitio
# ---------------------------------------------------------

inv1b <- inv1 %>%
  dplyr::group_by(Sitio) %>%
  dplyr::summarise(
    Promedio_total = mean(Total, na.rm = TRUE),
    DE_total = sd(Total, na.rm = TRUE),
    n = dplyr::n(),
    .groups = "drop"
  )

guardar_tabla_excel(inv1b, "tabla_01_resumen_total_por_sitio.xlsx")

# ---------------------------------------------------------
# 5. Transformación log(x + 1)
# ---------------------------------------------------------

inv2_log <- inv2 %>%
  dplyr::mutate(
    dplyr::across(-Sitio, ~ log1p(as.numeric(.x)))
  )

guardar_tabla_excel(inv2_log, "tabla_02_taxones2_transformada_log.xlsx")

# ---------------------------------------------------------
# 6. Formato largo
# ---------------------------------------------------------

inv2_long <- inv2 %>%
  tidyr::pivot_longer(
    cols = -Sitio,
    names_to = "familia",
    values_to = "abundancia"
  ) %>%
  dplyr::mutate(abundancia = as.numeric(abundancia))

guardar_tabla_excel(inv2_long, "tabla_03_taxones2_formato_largo.xlsx")

# ---------------------------------------------------------
# 7. Unión de datos bióticos y fisicoquímicos
# ---------------------------------------------------------

inv2_join <- inv2 %>%
  dplyr::left_join(fq, by = "Sitio")

guardar_tabla_excel(inv2_join, "tabla_04_union_biotica_fisicoquimica.xlsx")

# ---------------------------------------------------------
# 8. Factor ordenado de sitio
# ---------------------------------------------------------

niveles_sitio <- c("Pozo Azul", "Arimaca", "Caracoli")
niveles_presentes <- intersect(niveles_sitio, unique(fq$Sitio))

fq_ord <- fq %>%
  dplyr::mutate(
    Sitio = factor(
      Sitio,
      levels = niveles_presentes,
      ordered = TRUE
    )
  )

# ---------------------------------------------------------
# 9. Abreviación de familias
# ---------------------------------------------------------

nombres <- names(inv2)[-1]

abreviaciones <- nombres %>%
  stringr::str_replace_all("idae", "") %>%
  stringr::str_sub(1, 4) %>%
  make.unique(sep = "_")

inv2_abrev <- inv2
names(inv2_abrev)[-1] <- abreviaciones

diccionario_familias <- tibble::tibble(
  nombre_original = nombres,
  abreviacion = abreviaciones
)

guardar_tabla_excel(diccionario_familias, "tabla_05_diccionario_familias.xlsx")

# ---------------------------------------------------------
# 10. Familias dominantes
# ---------------------------------------------------------

inv2_dom5 <- inv2_long %>%
  dplyr::group_by(familia) %>%
  dplyr::summarise(total = sum(abundancia, na.rm = TRUE), .groups = "drop") %>%
  dplyr::slice_max(order_by = total, n = 5, with_ties = FALSE)

guardar_tabla_excel(inv2_dom5, "tabla_06_top5_familias.xlsx")

# ---------------------------------------------------------
# 11. Gráfico de familias más abundantes
# ---------------------------------------------------------

p_dom5 <- inv2_long %>%
  dplyr::group_by(familia) %>%
  dplyr::summarise(media = mean(abundancia, na.rm = TRUE), .groups = "drop") %>%
  ggplot2::ggplot(ggplot2::aes(x = reorder(familia, media), y = media)) +
  ggplot2::geom_col(fill = "#1f78b4") +
  ggplot2::coord_flip() +
  ggplot2::labs(
    x = "Familias de macroinvertebrados",
    y = "Promedio de abundancia",
    title = "Familias más abundantes"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_dom5, "fig_01_familias_mas_abundantes.png")

# ---------------------------------------------------------
# 12. Categorización de oxígeno disuelto
# ---------------------------------------------------------

fq_cat <- fq %>%
  dplyr::mutate(
    Cat_oxigeno = dplyr::case_when(
      Oxigeno < 5.2  ~ "Bajo",
      Oxigeno <= 5.5 ~ "Medio",
      TRUE           ~ "Alto"
    ),
    Cat_oxigeno = factor(
      Cat_oxigeno,
      levels = c("Bajo", "Medio", "Alto"),
      ordered = TRUE
    )
  )

tabla_oxigeno <- fq_cat %>%
  dplyr::count(Cat_oxigeno)

inv_dom_ox <- inv2_long %>%
  dplyr::mutate(Sitio = std_sitio(Sitio)) %>%
  dplyr::semi_join(inv2_dom5, by = "familia") %>%
  dplyr::left_join(
    fq_cat %>%
      dplyr::mutate(Sitio = std_sitio(Sitio)) %>%
      dplyr::select(Sitio, Cat_oxigeno),
    by = "Sitio"
  )

p_dom_ox <- inv_dom_ox %>%
  dplyr::group_by(familia, Cat_oxigeno) %>%
  dplyr::summarise(
    n = sum(!is.na(abundancia)),
    media = mean(abundancia, na.rm = TRUE),
    ee = sd(abundancia, na.rm = TRUE) / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot2::ggplot(ggplot2::aes(x = Cat_oxigeno, y = media, fill = Cat_oxigeno)) +
  ggplot2::geom_col(width = 0.7) +
  ggplot2::geom_errorbar(
    ggplot2::aes(ymin = pmax(media - ee, 0), ymax = media + ee),
    width = 0.2
  ) +
  ggplot2::facet_wrap(~familia, scales = "free_y") +
  ggplot2::labs(
    x = "Categoría de oxígeno disuelto",
    y = "Abundancia promedio"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_tabla_excel(tabla_oxigeno, "tabla_07_categorias_oxigeno.xlsx")
guardar_figura(p_dom_ox, "fig_02_abundancia_por_categoria_oxigeno.png", width = 9, height = 6)

# ---------------------------------------------------------
# 13. Relación entre ensamblaje y ambiente
# ---------------------------------------------------------

inv2_numerica <- inv2 %>%
  dplyr::mutate(dplyr::across(-Sitio, as.numeric))

ab_total <- inv2_numerica %>%
  dplyr::mutate(Ab_total = rowSums(dplyr::across(-Sitio), na.rm = TRUE)) %>%
  dplyr::select(Sitio, Ab_total)

riqueza <- inv2_numerica %>%
  dplyr::mutate(Riqueza = rowSums(dplyr::across(-Sitio) > 0, na.rm = TRUE)) %>%
  dplyr::select(Sitio, Riqueza)

famil_ambiente <- ab_total %>%
  dplyr::left_join(riqueza, by = "Sitio") %>%
  dplyr::left_join(fq, by = "Sitio")

guardar_tabla_excel(famil_ambiente, "tabla_08_resumen_ensamblaje_ambiente.xlsx")

p_ab_ox <- ggplot2::ggplot(famil_ambiente, ggplot2::aes(x = Oxigeno, y = Ab_total)) +
  ggplot2::geom_point(size = 3) +
  ggplot2::geom_smooth(method = "lm", se = FALSE) +
  ggplot2::labs(
    x = "Oxígeno disuelto (mg/L)",
    y = "Abundancia total"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

p_riq_cond <- ggplot2::ggplot(famil_ambiente, ggplot2::aes(x = Conductividad, y = Riqueza)) +
  ggplot2::geom_point(size = 3) +
  ggplot2::geom_smooth(method = "lm", se = FALSE) +
  ggplot2::labs(
    x = "Conductividad",
    y = "Riqueza de familias"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

p_riq_ancho <- ggplot2::ggplot(famil_ambiente, ggplot2::aes(x = Ancho, y = Riqueza)) +
  ggplot2::geom_point(size = 3) +
  ggplot2::geom_smooth(method = "lm", se = FALSE) +
  ggplot2::labs(
    x = "Ancho del tramo (m)",
    y = "Riqueza de familias"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_ab_ox, "fig_03_abundancia_vs_oxigeno.png")
guardar_figura(p_riq_cond, "fig_04_riqueza_vs_conductividad.png")
guardar_figura(p_riq_ancho, "fig_05_riqueza_vs_ancho.png")

# ---------------------------------------------------------
# 14. Objeto de salida del caso
# ---------------------------------------------------------

resultados_casoB <- list(
  inv1a = inv1a,
  inv2a = inv2a,
  inv1 = inv1,
  inv1b = inv1b,
  inv2_log = inv2_log,
  inv2_long = inv2_long,
  inv2_join = inv2_join,
  fq_ord = fq_ord,
  diccionario_familias = diccionario_familias,
  inv2_abrev = inv2_abrev,
  inv2_dom5 = inv2_dom5,
  tabla_oxigeno = tabla_oxigeno,
  famil_ambiente = famil_ambiente,
  p_dom5 = p_dom5,
  p_dom_ox = p_dom_ox,
  p_ab_ox = p_ab_ox,
  p_riq_cond = p_riq_cond,
  p_riq_ancho = p_riq_ancho
)

message("Caso B completado. Revise outputs/tablas y outputs/figuras.")

resultados_casoB
