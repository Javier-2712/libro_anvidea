# =========================================================
# ANVIDEA - Unidad I
# Capítulo 1 - Fundamentos de manipulación de datos
# Archivo: 01_casoA_mesozooplancton_ajustado.R
# Propósito: desarrollar el caso de mesozooplancton estuarino
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

# ---------------------------------------------------------
# 1. Cargar datos
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

# Exploración básica
dplyr::glimpse(biol)
summary(biol)

# Asegurar tipos de variables
biol <- biol %>%
  dplyr::mutate(
    dplyr::across(c(Station, Size, Layers, Groups), as.factor),
    dplyr::across(c(Abundance, Temperature, Salinity, Density), as.numeric)
  )

if (any(is.na(biol$Abundance))) {
  warning("Existen valores NA en 'Abundance'. Revise la base de datos.")
}

# ---------------------------------------------------------
# 2. Selección y filtrado
# ---------------------------------------------------------

datos_select <- biol %>%
  dplyr::select(Station, Size, Layers, Abundance, Temperature, Salinity)

datos_filtro <- biol %>%
  dplyr::filter(Temperature > 28)

# ---------------------------------------------------------
# 3. Creación de variables derivadas
# ---------------------------------------------------------

biol_rel <- biol %>%
  dplyr::mutate(
    rel_Ab_Temp = dplyr::if_else(
      Temperature > 0,
      Abundance / Temperature,
      NA_real_
    )
  )

# ---------------------------------------------------------
# 4. Resúmenes agrupados
# ---------------------------------------------------------

datos_resumidos <- biol %>%
  dplyr::group_by(Station, Size) %>%
  dplyr::summarise(
    datos_m   = mean(Abundance, na.rm = TRUE),
    datos_de  = sd(Abundance, na.rm = TRUE),
    datos_var = var(Abundance, na.rm = TRUE),
    datos_n   = dplyr::n(),
    .groups   = "drop"
  )

datos_resumidos1 <- biol %>%
  dplyr::group_by(Station, Size, Layers) %>%
  dplyr::summarise(
    datos_m   = mean(Abundance, na.rm = TRUE),
    datos_de  = sd(Abundance, na.rm = TRUE),
    datos_var = var(Abundance, na.rm = TRUE),
    datos_n   = dplyr::n(),
    datos_ee  = sd(Abundance, na.rm = TRUE) / sqrt(dplyr::n()),
    .groups   = "drop"
  )

guardar_tabla_excel(datos_resumidos,  "tabla_01_resumen_abundancia_estacion_talla.xlsx")
guardar_tabla_excel(datos_resumidos1, "tabla_02_resumen_abundancia_estacion_talla_capa.xlsx")

# ---------------------------------------------------------
# 5. Transformación de datos
# ---------------------------------------------------------

biol_largo <- biol %>%
  tidyr::pivot_longer(
    cols = c(Temperature, Salinity, Density),
    names_to = "Variable",
    values_to = "Valor"
  )

biol_ancho_amb <- biol_largo %>%
  tidyr::pivot_wider(
    names_from = Variable,
    values_from = Valor
  )

biol_transf <- biol %>%
  dplyr::mutate(
    Temperature_log = log1p(Temperature),
    Salinity_sqrt   = sqrt(pmax(Salinity, 0)),
    Density_z       = as.numeric(scale(Density))
  )

# ---------------------------------------------------------
# 6. Matriz taxón × estación
# ---------------------------------------------------------

biol_ancho <- biol %>%
  dplyr::group_by(Groups, Station) %>%
  dplyr::summarise(
    Abundance = sum(Abundance, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::pivot_wider(
    names_from = Station,
    values_from = Abundance,
    values_fill = 0
  )

biol_largo2 <- biol_ancho %>%
  tidyr::pivot_longer(
    cols = -Groups,
    names_to = "Station",
    values_to = "Abundance"
  )

guardar_tabla_excel(biol_ancho, "tabla_03_matriz_taxon_estacion.xlsx")

# ---------------------------------------------------------
# 7. Unión de datos bióticos y ambientales
# ---------------------------------------------------------

amb_station <- biol %>%
  dplyr::group_by(Station) %>%
  dplyr::summarise(
    Temperature = mean(Temperature, na.rm = TRUE),
    Salinity    = mean(Salinity, na.rm = TRUE),
    Density     = mean(Density, na.rm = TRUE),
    .groups     = "drop"
  ) %>%
  dplyr::mutate(Station = as.factor(Station))

biol_station <- biol %>%
  dplyr::group_by(Station) %>%
  dplyr::summarise(
    Abundance = mean(Abundance, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::left_join(amb_station, by = "Station")

guardar_tabla_excel(biol_station, "tabla_04_resumen_biotico_ambiental_por_estacion.xlsx")

# ---------------------------------------------------------
# 8. Abreviación de nombres de grupos
# ---------------------------------------------------------

diccionario_base <- biol %>%
  dplyr::distinct(Groups) %>%
  dplyr::mutate(
    Abrev = stringr::str_replace_all(as.character(Groups), " ", "_") %>%
      stringr::str_sub(1, 6)
  )

if (anyDuplicated(diccionario_base$Abrev)) {
  diccionario_abrev <- diccionario_base %>%
    dplyr::mutate(Abrev = make.unique(Abrev, sep = "_"))
} else {
  diccionario_abrev <- diccionario_base
}

biol_abrev <- biol %>%
  dplyr::left_join(diccionario_abrev, by = "Groups")

guardar_tabla_excel(diccionario_abrev, "tabla_05_diccionario_abreviaturas.xlsx")

# ---------------------------------------------------------
# 9. Cinco taxones más abundantes
# ---------------------------------------------------------

top5_taxones <- biol %>%
  dplyr::group_by(Groups) %>%
  dplyr::summarise(total = sum(Abundance, na.rm = TRUE), .groups = "drop") %>%
  dplyr::slice_max(order_by = total, n = 5, with_ties = FALSE)

biol_selec <- biol %>%
  dplyr::semi_join(top5_taxones, by = "Groups")

guardar_tabla_excel(top5_taxones, "tabla_06_top5_taxones.xlsx")

# ---------------------------------------------------------
# 10. Visualización básica
# ---------------------------------------------------------

p_estacion <- ggplot2::ggplot(biol, ggplot2::aes(x = Station, y = Abundance)) +
  ggplot2::geom_boxplot(ggplot2::aes(fill = Station)) +
  ggplot2::scale_y_continuous(trans = "log10") +
  ggplot2::labs(
    title = "Distribución de la abundancia por estación",
    x = "Estación",
    y = expression(log[10]~(Abundancia))
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

biol_layers <- biol %>%
  dplyr::mutate(
    Layers = dplyr::recode_factor(
      Layers,
      "Depth" = "Profunda",
      "Surface" = "Superficial"
    )
  )

p_layers <- ggplot2::ggplot(biol_layers, ggplot2::aes(x = Station, y = Abundance)) +
  ggplot2::geom_boxplot(ggplot2::aes(fill = Layers)) +
  ggplot2::scale_y_continuous(trans = "log10") +
  ggplot2::labs(
    title = "Distribución de la abundancia por estación y capa",
    x = "Estación",
    y = expression(log[10]~(Abundancia)),
    fill = "Capa"
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_figura(p_estacion, "fig_01_abundancia_por_estacion.png")
guardar_figura(p_layers, "fig_02_abundancia_por_estacion_y_capa.png")

# ---------------------------------------------------------
# 11. Categorización de salinidad
# ---------------------------------------------------------

q1 <- stats::quantile(biol$Salinity, 1/3, na.rm = TRUE)
q2 <- stats::quantile(biol$Salinity, 2/3, na.rm = TRUE)

biol_terciles <- biol %>%
  dplyr::mutate(
    Salinity_Level = dplyr::case_when(
      Salinity <= q1 ~ "Baja",
      Salinity <= q2 ~ "Media",
      TRUE ~ "Alta"
    ),
    Salinity_Level = factor(
      Salinity_Level,
      levels = c("Baja", "Media", "Alta"),
      ordered = TRUE
    )
  )

resumen_salinidad <- resumen_salinidad_fun(biol, "Salinity")

biol_sal <- biol %>%
  dplyr::mutate(
    salinidad_categoria = dplyr::case_when(
      Salinity < 5  ~ "Dulce",
      Salinity < 18 ~ "Oligohalina",
      Salinity < 30 ~ "Mesohalina",
      Salinity < 40 ~ "Polihalina",
      TRUE          ~ "Euhalina"
    ),
    zona_estuarina = dplyr::case_when(
      Salinity < 15 ~ "Zona Fluvial",
      Salinity < 25 ~ "Zona de Mezcla",
      Salinity < 35 ~ "Zona Marina",
      TRUE          ~ "Zona Hipersalina"
    )
  ) %>%
  dplyr::mutate(
    salinidad_categoria = factor(
      salinidad_categoria,
      levels = c("Dulce", "Oligohalina", "Mesohalina", "Polihalina", "Euhalina"),
      ordered = TRUE
    )
  )

tabla_salinidad <- biol_sal %>%
  dplyr::count(salinidad_categoria, zona_estuarina) %>%
  tidyr::pivot_wider(
    names_from = zona_estuarina,
    values_from = n,
    values_fill = 0
  )

p_salinidad <- ggplot2::ggplot(biol_terciles, ggplot2::aes(x = Salinity_Level, y = Abundance)) +
  ggplot2::geom_boxplot(ggplot2::aes(fill = Salinity_Level)) +
  ggplot2::scale_y_continuous(trans = "log10") +
  ggplot2::labs(
    title = "Abundancia según terciles de salinidad",
    x = "Nivel de salinidad",
    y = expression(log[10]~(Abundancia))
  ) +
  ggplot2::theme_bw() +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

guardar_tabla_excel(resumen_salinidad, "tabla_07_resumen_salinidad.xlsx")
guardar_tabla_excel(tabla_salinidad, "tabla_08_tabla_salinidad.xlsx")
guardar_figura(p_salinidad, "fig_03_abundancia_por_terciles_salinidad.png")

# ---------------------------------------------------------
# 12. Objeto de salida del caso
# ---------------------------------------------------------

resultados_casoA <- list(
  datos_select = datos_select,
  datos_filtro = datos_filtro,
  biol_rel = biol_rel,
  datos_resumidos = datos_resumidos,
  datos_resumidos1 = datos_resumidos1,
  biol_largo = biol_largo,
  biol_ancho_amb = biol_ancho_amb,
  biol_transf = biol_transf,
  biol_ancho = biol_ancho,
  biol_largo2 = biol_largo2,
  biol_station = biol_station,
  diccionario_abrev = diccionario_abrev,
  top5_taxones = top5_taxones,
  biol_selec = biol_selec,
  resumen_salinidad = resumen_salinidad,
  tabla_salinidad = tabla_salinidad,
  p_estacion = p_estacion,
  p_layers = p_layers,
  p_salinidad = p_salinidad
)

message("Caso A completado. Revise outputs/tablas y outputs/figuras.")

resultados_casoA
