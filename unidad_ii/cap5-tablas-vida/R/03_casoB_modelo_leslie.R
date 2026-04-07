# =========================================================
# ANDIVEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 03_casoB_modelo_leslie.R
# Propósito: construir y analizar matrices de Leslie
#             pre y post-reproductivas como continuación
#             del caso A2 basado en datos de Gotelli
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

archivo_datos <- file.path(data_dir, "datos.c5.xlsx")

message("→ Leyendo tabla de vida derivada del caso A2...")

# ---------------------------------------------------------
# Paso 1. Lectura y validación de la tabla base
# ---------------------------------------------------------
tabla2 <- readxl::read_excel(archivo_datos, sheet = "t.vida") %>%
  dplyr::mutate(
    dplyr::across(
      .cols = c(x, Nx, Sx, Fpre, Fpost),
      .fns  = as.numeric
    )
  ) %>%
  dplyr::filter(!is.na(x), !is.na(Nx)) %>%
  dplyr::arrange(x)

columnas_necesarias <- c("x", "Nx", "Sx", "Fpre", "Fpost")
faltantes <- setdiff(columnas_necesarias, names(tabla2))

if (length(faltantes) > 0) {
  stop(
    paste0(
      "La hoja 't.vida' no contiene las columnas requeridas: ",
      paste(faltantes, collapse = ", ")
    )
  )
}

if (nrow(tabla2) < 2) {
  stop("La hoja 't.vida' debe contener al menos dos clases de edad.")
}

edades <- tabla2$x
Nx     <- tabla2$Nx
Sx     <- tabla2$Sx
Fpre   <- tabla2$Fpre
Fpost  <- tabla2$Fpost

# ---------------------------------------------------------
# Paso 2. Construcción de matrices de Leslie
# ---------------------------------------------------------
message("→ Construyendo matrices de Leslie pre y post-reproductivas...")

# En la matriz pre-reproductiva, la fecundidad del último intervalo
# suele omitirse si no hay una clase siguiente bien definida.
L_pre <- construir_matriz_leslie(
  F = Fpre[1:(length(edades) - 1)],
  S = Sx[1:(length(edades) - 2)]
)

# En la matriz post-reproductiva se conserva la estructura completa
# de fecundidades y supervivencias entre clases consecutivas.
L_post <- construir_matriz_leslie(
  F = Fpost[1:length(edades)],
  S = Sx[1:(length(edades) - 1)]
)

# Vectores iniciales compatibles con cada matriz
N0_pre  <- Nx[1:ncol(L_pre)]
N0_post <- Nx[1:ncol(L_post)]

# ---------------------------------------------------------
# Paso 3. Proyecciones poblacionales
# ---------------------------------------------------------
message("→ Proyectando la población con ambos modelos matriciales...")

proj_pre <- proyectar_matriz(L_pre, N0_pre, t_max = 20) %>%
  tidyr::pivot_longer(-t, names_to = "clase", values_to = "N") %>%
  dplyr::mutate(modelo = "Pre-reproductiva")

proj_post <- proyectar_matriz(L_post, N0_post, t_max = 20) %>%
  tidyr::pivot_longer(-t, names_to = "clase", values_to = "N") %>%
  dplyr::mutate(modelo = "Post-reproductiva")

proyecciones <- dplyr::bind_rows(proj_pre, proj_post)

# Totales poblacionales por tiempo
totales <- proyecciones %>%
  dplyr::group_by(modelo, t) %>%
  dplyr::summarise(N_total = sum(N, na.rm = TRUE), .groups = "drop")

# ---------------------------------------------------------
# Paso 4. Gráficos
# ---------------------------------------------------------
message("→ Generando figuras del caso B...")

p_pre <- ggplot2::ggplot(proj_pre, ggplot2::aes(t, N, color = clase)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Proyección Leslie pre-reproductiva",
    x = "Tiempo",
    y = "Abundancia",
    color = "Clase"
  ) +
  ggplot2::theme_bw()

p_post <- ggplot2::ggplot(proj_post, ggplot2::aes(t, N, color = clase)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Proyección Leslie post-reproductiva",
    x = "Tiempo",
    y = "Abundancia",
    color = "Clase"
  ) +
  ggplot2::theme_bw()

p_total <- ggplot2::ggplot(totales, ggplot2::aes(t, N_total, color = modelo)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_point(size = 2) +
  ggplot2::labs(
    title = "Tamaño poblacional total proyectado",
    x = "Tiempo",
    y = "N total",
    color = "Modelo"
  ) +
  ggplot2::theme_bw()

if (requireNamespace("cowplot", quietly = TRUE)) {
  fig_comb <- cowplot::plot_grid(p_pre, p_post, ncol = 2)
  guardar_figura(fig_comb, "cap5_leslie_proyecciones_clases.png", width = 11, height = 5)
} else {
  guardar_figura(p_pre, "cap5_leslie_pre_reproductiva.png", width = 7, height = 5)
  guardar_figura(p_post, "cap5_leslie_post_reproductiva.png", width = 7, height = 5)
}

guardar_figura(p_total, "cap5_leslie_proyecciones_totales.png", width = 8, height = 5)

# ---------------------------------------------------------
# Paso 5. Análisis matricial
# ---------------------------------------------------------
message("→ Calculando propiedades matriciales...")

analisis_pre <- analisis_matricial(L_pre)
analisis_post <- analisis_matricial(L_post)

resumen <- tibble::tibble(
  modelo = c("Pre-reproductiva", "Post-reproductiva"),
  lambda = c(analisis_pre$lambda, analisis_post$lambda)
)

# Distribución estable y valor reproductivo
dist_estable_pre <- tibble::as_tibble(as.data.frame(analisis_pre$w)) %>%
  dplyr::mutate(clase = paste0("clase_", seq_len(nrow(.)))) %>%
  dplyr::relocate(clase)

dist_estable_post <- tibble::as_tibble(as.data.frame(analisis_post$w)) %>%
  dplyr::mutate(clase = paste0("clase_", seq_len(nrow(.)))) %>%
  dplyr::relocate(clase)

valor_reprod_pre <- tibble::as_tibble(as.data.frame(analisis_pre$v)) %>%
  dplyr::mutate(clase = paste0("clase_", seq_len(nrow(.)))) %>%
  dplyr::relocate(clase)

valor_reprod_post <- tibble::as_tibble(as.data.frame(analisis_post$v)) %>%
  dplyr::mutate(clase = paste0("clase_", seq_len(nrow(.)))) %>%
  dplyr::relocate(clase)

# ---------------------------------------------------------
# Paso 6. Exportación de tablas
# ---------------------------------------------------------
message("→ Exportando resultados del caso B...")

Leslie_pre_df <- as.data.frame(L_pre)
colnames(Leslie_pre_df) <- paste0("c", seq_len(ncol(Leslie_pre_df)))
Leslie_pre_df <- tibble::add_column(
  Leslie_pre_df,
  fila = paste0("c", seq_len(nrow(Leslie_pre_df))),
  .before = 1
)

Leslie_post_df <- as.data.frame(L_post)
colnames(Leslie_post_df) <- paste0("c", seq_len(ncol(Leslie_post_df)))
Leslie_post_df <- tibble::add_column(
  Leslie_post_df,
  fila = paste0("c", seq_len(nrow(Leslie_post_df))),
  .before = 1
)

sens_pre_df <- as.data.frame(analisis_pre$sensibilidad)
colnames(sens_pre_df) <- paste0("c", seq_len(ncol(sens_pre_df)))
sens_pre_df <- tibble::add_column(
  sens_pre_df,
  fila = paste0("c", seq_len(nrow(sens_pre_df))),
  .before = 1
)

elas_pre_df <- as.data.frame(analisis_pre$elasticidad)
colnames(elas_pre_df) <- paste0("c", seq_len(ncol(elas_pre_df)))
elas_pre_df <- tibble::add_column(
  elas_pre_df,
  fila = paste0("c", seq_len(nrow(elas_pre_df))),
  .before = 1
)

sens_post_df <- as.data.frame(analisis_post$sensibilidad)
colnames(sens_post_df) <- paste0("c", seq_len(ncol(sens_post_df)))
sens_post_df <- tibble::add_column(
  sens_post_df,
  fila = paste0("c", seq_len(nrow(sens_post_df))),
  .before = 1
)

elas_post_df <- as.data.frame(analisis_post$elasticidad)
colnames(elas_post_df) <- paste0("c", seq_len(ncol(elas_post_df)))
elas_post_df <- tibble::add_column(
  elas_post_df,
  fila = paste0("c", seq_len(nrow(elas_post_df))),
  .before = 1
)

guardar_tabla_excel(
  list(
    tabla_vida_base = tabla2,
    Leslie_pre = Leslie_pre_df,
    Leslie_post = Leslie_post_df,
    resumen_lambda = resumen,
    distribucion_estable_pre = dist_estable_pre,
    distribucion_estable_post = dist_estable_post,
    valor_reproductivo_pre = valor_reprod_pre,
    valor_reproductivo_post = valor_reprod_post,
    sensibilidad_pre = sens_pre_df,
    elasticidad_pre = elas_pre_df,
    sensibilidad_post = sens_post_df,
    elasticidad_post = elas_post_df,
    proyecciones = proyecciones,
    totales = totales
  ),
  archivo = "cap5_modelo_leslie.xlsx"
)

message("✔ Capítulo 5 - Caso B ejecutado correctamente")
