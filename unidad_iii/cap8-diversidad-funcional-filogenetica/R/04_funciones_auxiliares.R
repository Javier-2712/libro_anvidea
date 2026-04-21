# =========================================================
# ANVIDEA - Unidad III
# Cap\u00edtulo 8 - Diversidad funcional y filogen\u00e9tica
# ---------------------------------------------------------
# Archivo : 04_funciones_auxiliares.R
# Prop\u00f3sito: funciones de apoyo reutilizables para los
#            scripts del cap\u00edtulo 8
# =========================================================

# ---------------------------------------------------------
# 1. Resumen tabular de componentes Rao
# ---------------------------------------------------------

# Extrae alfa, gamma y beta (TD, FD, PD) desde la salida de Rao()
# y los devuelve como un data.frame limpio para tablas y exportación.

resumen_rao <- function(rao_out, dimensiones = c("TD", "FD", "PD")) {
  purrr::map_dfr(dimensiones, function(dim) {
    comp <- rao_out[[dim]]
    if (is.null(comp)) return(NULL)
    tibble::tibble(
      Dimension  = dim,
      Mean_Alpha = comp$Mean_Alpha,
      Gamma      = comp$Gamma,
      Beta_add   = comp$Beta_add,
      Beta_prop  = comp$Beta_prop
    )
  })
}


# ---------------------------------------------------------
# 2. Resumen tabular de iNEXT3D (DataInfo)
# ---------------------------------------------------------

# Extrae la tabla DataInfo de un objeto iNEXT3D y añade
# la columna Dimension para facilitar comparaciones.

extraer_datainfo <- function(obj, dim_name) {
  campo <- paste0(dim_name, "Info")
  if (!campo %in% names(obj) || is.null(obj[[campo]])) return(NULL)
  as.data.frame(obj[[campo]]) %>%
    dplyr::mutate(Dimension = dim_name)
}


# ---------------------------------------------------------
# 3. Resumen tabular de AsyEst (iNEXT3D)
# ---------------------------------------------------------

# Extrae la tabla de estimaciones asintóticas de un objeto
# iNEXT3D añadiendo la columna Dimension.

extraer_asyest <- function(obj, dim_name) {
  campo <- paste0(dim_name, "AsyEst")
  if (!campo %in% names(obj) || is.null(obj[[campo]])) return(NULL)
  as.data.frame(obj[[campo]]) %>%
    dplyr::mutate(Dimension = dim_name)
}


# ---------------------------------------------------------
# 4. Validar coincidencia de especies entre matrices
# ---------------------------------------------------------

# Comprueba que las especies (rownames/colnames) de dos
# objetos coincidan. Devuelve TRUE o lanza error.

validar_especies <- function(mat_abund, mat_dist,
                              nombre_abund = "abundancias",
                              nombre_dist  = "distancias") {
  sp_abund <- colnames(mat_abund)
  sp_dist  <- rownames(mat_dist)

  if (!setequal(sp_abund, sp_dist)) {
    solo_abund <- setdiff(sp_abund, sp_dist)
    solo_dist  <- setdiff(sp_dist, sp_abund)
    stop(
      "Las especies no coinciden entre '", nombre_abund,
      "' y '", nombre_dist, "'.\n",
      if (length(solo_abund) > 0)
        paste0("  Solo en abundancias: ",
               paste(utils::head(solo_abund, 5), collapse = ", "), "\n"),
      if (length(solo_dist) > 0)
        paste0("  Solo en distancias: ",
               paste(utils::head(solo_dist, 5), collapse = ", "), "\n")
    )
  }

  invisible(TRUE)
}


# ---------------------------------------------------------
# 5. Alinear matriz de abundancia con matriz de distancias
# ---------------------------------------------------------

# Reduce ambas matrices a las especies comunes y las reordena
# para que coincidan. Devuelve lista con $abund y $dist.

alinear_abund_dist <- function(mat_abund, mat_dist) {
  sp_comunes <- intersect(colnames(mat_abund), rownames(mat_dist))

  if (length(sp_comunes) == 0) {
    stop("No hay especies comunes entre la matriz de abundancias y la de distancias.")
  }

  list(
    abund = mat_abund[, sp_comunes, drop = FALSE],
    dist  = mat_dist[sp_comunes, sp_comunes, drop = FALSE]
  )
}

cat("Funciones auxiliares del cap\u00edtulo 8 cargadas correctamente.\n")
