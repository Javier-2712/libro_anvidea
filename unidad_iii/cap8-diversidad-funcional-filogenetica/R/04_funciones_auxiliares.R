# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 04_funciones_auxiliares.R
# Propósito: definir funciones auxiliares reutilizables
# =========================================================

# ---------------------------------------------------------
# 0. Utilidades internas
# ---------------------------------------------------------

asegurar_directorio <- function(ruta) {
  if (!dir.exists(ruta)) dir.create(ruta, recursive = TRUE, showWarnings = FALSE)
  invisible(ruta)
}

validar_columnas <- function(df, columnas, nombre_objeto = "data.frame") {
  faltantes <- setdiff(columnas, names(df))
  if (length(faltantes) > 0) {
    stop(
      "Faltan columnas en ", nombre_objeto, ": ",
      paste(faltantes, collapse = ", ")
    )
  }
  invisible(TRUE)
}

normalizar_binaria <- function(x) {
  x_chr <- trimws(as.character(x))

  dplyr::case_when(
    is.na(x) ~ NA_real_,
    x_chr %in% c("Sí", "Si", "sí", "si", "yes", "YES", "TRUE", "True", "true", "1") ~ 1,
    x_chr %in% c("No", "no", "NO", "FALSE", "False", "false", "0", "") ~ 0,
    TRUE ~ suppressWarnings(as.numeric(x_chr))
  )
}

leer_hoja_c8 <- function(data_dir, sheet_name) {
  archivo <- file.path(data_dir, "datos.c8.xlsx")

  if (!file.exists(archivo)) {
    stop("No se encontró el archivo de datos: ", archivo)
  }

  hojas <- readxl::excel_sheets(archivo)
  if (!sheet_name %in% hojas) {
    stop(
      "La hoja '", sheet_name, "' no existe en ", archivo,
      ". Hojas disponibles: ", paste(hojas, collapse = ", ")
    )
  }

  readxl::read_xlsx(archivo, sheet = sheet_name)
}

# ---------------------------------------------------------
# 1. Guardado de figuras y tablas
# ---------------------------------------------------------

guardar_figura <- function(plot_obj, nombre, width = 8, height = 5, dpi = 300) {
  if (missing(plot_obj) || is.null(plot_obj)) {
    stop("Debe suministrar un objeto gráfico válido en 'plot_obj'.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena de texto no vacía.")
  }

  ruta_salida <- file.path("outputs", "figuras")
  asegurar_directorio(ruta_salida)

  ggplot2::ggsave(
    filename = file.path(ruta_salida, nombre),
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi
  )
}

guardar_tabla_excel <- function(df, nombre) {
  if (missing(df) || is.null(df)) {
    stop("Debe suministrar un objeto válido en 'df'.")
  }

  if (!inherits(df, c("data.frame", "list"))) {
    stop("El objeto 'df' debe ser un data.frame o una lista de data.frames.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena de texto no vacía.")
  }

  ruta_salida <- file.path("outputs", "tablas")
  asegurar_directorio(ruta_salida)

  writexl::write_xlsx(df, file.path(ruta_salida, nombre))
}

# ---------------------------------------------------------
# 2. Lectura de datos del capítulo 8
# ---------------------------------------------------------

leer_tax_c8 <- function(data_dir) {
  leer_hoja_c8(data_dir, "tax")
}

leer_tax1_c8 <- function(data_dir) {
  leer_hoja_c8(data_dir, "tax1")
}

leer_rasgos_c8 <- function(data_dir) {
  leer_hoja_c8(data_dir, "rasgos")
}

leer_coord_c8 <- function(data_dir) {
  leer_hoja_c8(data_dir, "coord")
}

# ---------------------------------------------------------
# 3. Preparación de matrices biológicas
# ---------------------------------------------------------

preparar_biol_abrev <- function(taxas) {
  validar_columnas(taxas, c("Sites", "Sites1"), "taxas")

  biol <- taxas %>%
    dplyr::select(-dplyr::any_of(c("Sites", "Sites1")))

  if (ncol(biol) == 0) {
    stop("Después de excluir 'Sites' y 'Sites1', no quedaron columnas de especies.")
  }

  nombres_abrev <- abbreviate(names(biol), minlength = 4)
  names(biol) <- make.unique(nombres_abrev, sep = "_")

  biol
}

preparar_biol_zona <- function(taxas) {
  validar_columnas(taxas, c("Sites1"), "taxas")

  if (!any(vapply(taxas, is.numeric, logical(1)))) {
    stop("El objeto 'taxas' no contiene columnas numéricas de abundancia.")
  }

  taxas %>%
    dplyr::select(-dplyr::any_of("Sites")) %>%
    dplyr::group_by(Sites1) %>%
    dplyr::summarise(
      dplyr::across(where(is.numeric), ~ sum(.x, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    tibble::column_to_rownames("Sites1") %>%
    as.data.frame()
}

# ---------------------------------------------------------
# 4. Preparación de rasgos funcionales
# ---------------------------------------------------------

preparar_rasgos_fd <- function(rasgos) {
  columnas_requeridas <- c(
    "Abrev", "LatinName", "CommonName", "Family", "Guild",
    "TrophicLevel", "BodyLength", "BodyLengthMax", "ShapeFactor",
    "omnivory", "detritivory", "herbivory", "invertivory",
    "piscivory", "carnivory"
  )
  validar_columnas(rasgos, columnas_requeridas, "rasgos")

  rasgos_limpios <- rasgos %>%
    dplyr::mutate(
      dplyr::across(
        c(TrophicLevel, BodyLength, BodyLengthMax, ShapeFactor),
        ~ suppressWarnings(as.numeric(.x))
      ),
      dplyr::across(
        c(omnivory, detritivory, herbivory, invertivory, piscivory, carnivory),
        normalizar_binaria
      )
    ) %>%
    dplyr::filter(
      dplyr::if_all(
        c(TrophicLevel, BodyLength, BodyLengthMax, ShapeFactor,
          omnivory, detritivory, herbivory, invertivory, piscivory, carnivory),
        ~ !is.na(.x)
      )
    ) %>%
    as.data.frame()

  if (nrow(rasgos_limpios) == 0) {
    stop("No quedaron filas válidas en la tabla de rasgos después de la depuración.")
  }

  rasgos_limpios
}

# ---------------------------------------------------------
# 5. Construcción de matrices de rasgos
# ---------------------------------------------------------

matriz_fd <- function(rasgos_df) {
  validar_columnas(
    rasgos_df,
    c("LatinName", "Abrev", "CommonName", "Family", "Guild"),
    "rasgos_df"
  )

  r <- as.data.frame(rasgos_df)
  rownames(r) <- r$LatinName
  r <- r[, setdiff(names(r), c("Abrev", "LatinName", "CommonName", "Family", "Guild")), drop = FALSE]

  if (ncol(r) == 0) {
    stop("La matriz funcional quedó sin columnas de rasgos.")
  }

  r
}

alinear_matriz_rasgos_abrev <- function(rasgos_df) {
  validar_columnas(
    rasgos_df,
    c("Abrev", "LatinName", "CommonName", "Family", "Guild"),
    "rasgos_df"
  )

  r <- as.data.frame(rasgos_df)
  rownames(r) <- r$Abrev
  r <- r[, setdiff(names(r), c("Abrev", "LatinName", "CommonName", "Family", "Guild")), drop = FALSE]

  if (ncol(r) == 0) {
    stop("La matriz de rasgos abreviada quedó sin columnas.")
  }

  r
}

# ---------------------------------------------------------
# 6. Resúmenes de Rao
# ---------------------------------------------------------

resumen_rao <- function(obj, dim_name = "FD") {
  campos_requeridos <- c("Mean_Alpha", "Gamma", "Beta_add", "Beta_prop")
  faltantes <- setdiff(campos_requeridos, names(obj))

  if (length(faltantes) > 0) {
    stop(
      "El objeto de Rao no contiene los campos requeridos: ",
      paste(faltantes, collapse = ", ")
    )
  }

  tibble::tibble(
    Dimension = dim_name,
    Mean_Alpha = obj$Mean_Alpha,
    Gamma = obj$Gamma,
    Beta_add = obj$Beta_add,
    Beta_prop = obj$Beta_prop
  )
}
