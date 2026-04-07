# =========================================================
# ANDIVEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 04_casoC_modelo_lefkovitch.R
# Propósito: construir y analizar una matriz de Lefkovitch
#             por estados para Calotropis procera
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

archivo_datos <- file.path(data_dir, "datos.c5.xlsx")

message("→ Leyendo datos del caso por estados...")

# ---------------------------------------------------------
# Paso 1. Lectura y validación de la base
# ---------------------------------------------------------
datos <- readxl::read_excel(archivo_datos, sheet = "caltropis") %>%
  dplyr::mutate(
    dplyr::across(
      dplyr::any_of(c("Long.Tot", "Ancho", "Radio", "Cobertura", "Semillas")),
      as.numeric
    )
  )

if (!("Cobertura" %in% names(datos))) {
  stop("La hoja 'caltropis' debe incluir la columna 'Cobertura'.")
}

if (!("Semillas" %in% names(datos))) {
  warning("La hoja 'caltropis' no incluye la columna 'Semillas'; las fecundidades se asumirán como cero.")
}

datos <- datos %>%
  dplyr::filter(!is.na(Cobertura), is.finite(Cobertura), Cobertura >= 0)

if (nrow(datos) == 0) {
  stop("No hay datos válidos de cobertura para construir la matriz por estados.")
}

# ---------------------------------------------------------
# Paso 2. Clasificación de estados
# ---------------------------------------------------------
message("→ Clasificando individuos por estados de tamaño...")

datos <- datos %>%
  dplyr::mutate(
    estado = clasificar_cobertura(Cobertura, n_clases = 5),
    estado = factor(estado, levels = sort(unique(estado)))
  )

niveles_estado <- levels(datos$estado)

tabla_estados <- datos %>%
  dplyr::count(estado, name = "nx") %>%
  tidyr::complete(estado = niveles_estado, fill = list(nx = 0)) %>%
  dplyr::arrange(estado)

# ---------------------------------------------------------
# Paso 3. Fecundidad media por estado
# ---------------------------------------------------------
message("→ Estimando fecundidades promedio por estado...")

if ("Semillas" %in% names(datos)) {
  fec <- datos %>%
    dplyr::group_by(estado) %>%
    dplyr::summarise(
      Fpost = mean(Semillas, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::right_join(
      tibble::tibble(estado = factor(niveles_estado, levels = niveles_estado)),
      by = "estado"
    ) %>%
    dplyr::mutate(Fpost = tidyr::replace_na(Fpost, 0)) %>%
    dplyr::arrange(estado) %>%
    dplyr::pull(Fpost)
} else {
  fec <- rep(0, length(niveles_estado))
}

# Escalamiento simple para evitar fecundidades desproporcionadas
if (max(fec, na.rm = TRUE) > 0) {
  fec <- fec / max(fec, na.rm = TRUE) * 0.6
}

# ---------------------------------------------------------
# Paso 4. Construcción de matriz de Lefkovitch
# ---------------------------------------------------------
message("→ Construyendo matriz de Lefkovitch por estados...")

k <- nrow(tabla_estados)

# Plantilla base:
# - primera fila: fecundidades por estado
# - diagonal: permanencia en el mismo estado
# - subdiagonal inferior: crecimiento hacia el estado siguiente
# - última diagonal: permanencia relativamente alta en el estado final
M <- matrix(0, nrow = k, ncol = k)
M[1, ] <- fec

# Permanencia y crecimiento definidos como una plantilla pedagógica
diag(M) <- c(rep(0.35, max(k - 1, 1)), 0.70)[1:k]

if (k > 1) {
  M[cbind(2:k, 1:(k - 1))] <- 0.45
}

# Ajuste de la última clase para evitar salidas fuera del sistema
if (k >= 1) {
  M[k, k] <- max(M[k, k], 0.70)
}

colnames(M) <- paste0("estado_", seq_len(k))
rownames(M) <- paste0("estado_", seq_len(k))

# ---------------------------------------------------------
# Paso 5. Proyección poblacional
# ---------------------------------------------------------
message("→ Proyectando la dinámica poblacional por estados...")

N0 <- as.numeric(tabla_estados$nx)

proj <- proyectar_matriz(M, N0, t_max = 20) %>%
  tidyr::pivot_longer(-t, names_to = "estado_id", values_to = "N")

totales <- proj %>%
  dplyr::group_by(t) %>%
  dplyr::summarise(N_total = sum(N, na.rm = TRUE), .groups = "drop")

# ---------------------------------------------------------
# Paso 6. Análisis matricial
# ---------------------------------------------------------
message("→ Calculando propiedades matriciales...")

analisis <- analisis_matricial(M)

resumen <- tibble::tibble(
  lambda = analisis$lambda
)

dist_estable <- tibble::as_tibble(as.data.frame(analisis$w)) %>%
  dplyr::mutate(estado = paste0("estado_", seq_len(nrow(.)))) %>%
  dplyr::relocate(estado)

valor_reproductivo <- tibble::as_tibble(as.data.frame(analisis$v)) %>%
  dplyr::mutate(estado = paste0("estado_", seq_len(nrow(.)))) %>%
  dplyr::relocate(estado)

# ---------------------------------------------------------
# Paso 7. Figuras
# ---------------------------------------------------------
message("→ Guardando figuras del caso C...")

p_estados <- ggplot2::ggplot(proj, ggplot2::aes(t, N, color = estado_id)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Proyección por estados (modelo de Lefkovitch)",
    x = "Tiempo",
    y = "Abundancia",
    color = "Estado"
  ) +
  ggplot2::theme_bw()

p_total <- ggplot2::ggplot(totales, ggplot2::aes(t, N_total)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_point(size = 2) +
  ggplot2::labs(
    title = "Tamaño poblacional total proyectado",
    x = "Tiempo",
    y = "N total"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_estados, "cap5_modelo_lefkovitch_proyeccion_estados.png", width = 8, height = 5)
guardar_figura(p_total, "cap5_modelo_lefkovitch_proyeccion_total.png", width = 8, height = 5)

# ---------------------------------------------------------
# Paso 8. Exportación de tablas
# ---------------------------------------------------------
message("→ Exportando resultados del caso C...")

matriz_estados_df <- as.data.frame(M)
colnames(matriz_estados_df) <- paste0("e", seq_len(ncol(matriz_estados_df)))
matriz_estados_df <- tibble::add_column(
  matriz_estados_df,
  fila = paste0("e", seq_len(nrow(matriz_estados_df))),
  .before = 1
)

sens_df <- as.data.frame(analisis$sensibilidad)
colnames(sens_df) <- paste0("e", seq_len(ncol(sens_df)))
sens_df <- tibble::add_column(
  sens_df,
  fila = paste0("e", seq_len(nrow(sens_df))),
  .before = 1
)

elas_df <- as.data.frame(analisis$elasticidad)
colnames(elas_df) <- paste0("e", seq_len(ncol(elas_df)))
elas_df <- tibble::add_column(
  elas_df,
  fila = paste0("e", seq_len(nrow(elas_df))),
  .before = 1
)

guardar_tabla_excel(
  list(
    datos_iniciales = datos,
    tabla_estados = tabla_estados,
    fecundidad_por_estado = tibble::tibble(
      estado = niveles_estado,
      Fpost = fec
    ),
    matriz_lefkovitch = matriz_estados_df,
    resumen_lambda = resumen,
    distribucion_estable = dist_estable,
    valor_reproductivo = valor_reproductivo,
    sensibilidad = sens_df,
    elasticidad = elas_df,
    proyeccion_estados = proj,
    proyeccion_total = totales
  ),
  archivo = "cap5_modelo_lefkovitch.xlsx"
)

message("✔ Capítulo 5 - Caso C ejecutado correctamente")
