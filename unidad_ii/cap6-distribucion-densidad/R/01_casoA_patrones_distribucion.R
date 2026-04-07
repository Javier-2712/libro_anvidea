# =========================================================
# ANDIVEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# Archivo: 01_casoA_patrones_distribucion.R
# Propósito: evaluar el ajuste a Poisson, Binomial Negativa
#             e índices de dispersión para conteos espaciales
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

archivo_datos <- file.path(data_dir, "datos.c6.xlsx")

message("→ Leyendo datos del caso A...")

# ---------------------------------------------------------
# Paso 1. Lectura y validación de la base
# ---------------------------------------------------------
datos <- readxl::read_excel(archivo_datos, sheet = "poisson")

if (!("Individuos" %in% names(datos))) {
  stop("La hoja 'poisson' debe incluir la columna 'Individuos'.")
}

conteos <- datos %>%
  dplyr::transmute(x = as.integer(Individuos)) %>%
  dplyr::filter(!is.na(x), x >= 0) %>%
  dplyr::pull(x)

if (length(conteos) == 0) {
  stop("No hay conteos válidos en la columna 'Individuos'.")
}

if (length(unique(conteos)) < 2) {
  warning("Los conteos tienen muy poca variación; el ajuste de distribuciones puede ser poco informativo.")
}

message("→ Ajustando distribuciones teóricas...")

# ---------------------------------------------------------
# Paso 2. Ajuste a Poisson
# ---------------------------------------------------------
tab_pois <- ajuste_poisson(conteos)
chi_pois <- sum(tab_pois$chi, na.rm = TRUE)

# ---------------------------------------------------------
# Paso 3. Ajuste a Binomial Negativa
# ---------------------------------------------------------
aj_bn <- ajuste_binomial_negativa(conteos)
tab_bn <- aj_bn$tabla
chi_bn <- sum(tab_bn$chi, na.rm = TRUE)

# ---------------------------------------------------------
# Paso 4. Índices de dispersión
# ---------------------------------------------------------
idx <- indices_dispersion(conteos)

# ---------------------------------------------------------
# Paso 5. Tabla comparativa para gráficos y exportación
# ---------------------------------------------------------
tab_modelos <- dplyr::bind_rows(
  tab_pois %>% dplyr::mutate(modelo = "Poisson"),
  tab_bn %>% dplyr::mutate(modelo = "Binomial negativa")
)

resumen_modelos <- tibble::tibble(
  modelo = c("Poisson", "Binomial negativa"),
  chi_cuadrado = c(chi_pois, chi_bn),
  parametro = c(mean(conteos, na.rm = TRUE), aj_bn$size)
)

# ---------------------------------------------------------
# Paso 6. Visualización comparativa
# ---------------------------------------------------------
message("→ Generando figura comparativa...")

p <- ggplot2::ggplot(tab_modelos, ggplot2::aes(x = x)) +
  ggplot2::geom_col(ggplot2::aes(y = observada), fill = "grey80") +
  ggplot2::geom_line(ggplot2::aes(y = esperada, color = modelo), linewidth = 1) +
  ggplot2::geom_point(ggplot2::aes(y = esperada, color = modelo), size = 2) +
  ggplot2::facet_wrap(~modelo, scales = "free_y") +
  ggplot2::labs(
    title = "Frecuencias observadas y esperadas",
    x = "Número de individuos por unidad muestral",
    y = "Frecuencia"
  ) +
  ggplot2::theme_bw()

guardar_figura(
  p,
  "cap6_poisson_vs_binomial_negativa.png",
  width = 10,
  height = 5
)

# ---------------------------------------------------------
# Paso 7. Exportación de resultados
# ---------------------------------------------------------
message("→ Exportando tablas del caso A...")

guardar_tabla_excel(
  list(
    poisson = tab_pois,
    binomial_negativa = tab_bn,
    indices_dispersion = idx,
    resumen_modelos = resumen_modelos,
    comparacion_modelos = tab_modelos
  ),
  archivo = "cap6_patrones_distribucion.xlsx"
)

message("✔ Capítulo 6 - Caso A ejecutado correctamente")
