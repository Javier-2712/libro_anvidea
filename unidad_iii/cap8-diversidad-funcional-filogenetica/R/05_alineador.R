# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 05_alineador_final.R
# Propósito: alinear matrices de abundancia por pares con un árbol
#            filogenético, reordenando especies, rellenando ausencias
#            con ceros y generando un reporte de la alineación.
# =========================================================

if (!requireNamespace("ape", quietly = TRUE)) {
  stop("Falta el paquete 'ape'. Instálalo antes de usar esta función.")
}

# ---------------------------------------------------------
# 1. Utilidades internas
# ---------------------------------------------------------

.fix <- function(x) {
  x <- trimws(as.character(x))
  gsub("\\s+", " ", x)
}

.validar_par <- function(X, nombre = "par") {
  if (!(is.matrix(X) || is.data.frame(X))) {
    stop("El objeto '", nombre, "' debe ser matriz o data.frame.")
  }

  if (is.null(rownames(X))) {
    stop("El objeto '", nombre, "' debe tener rownames con nombres de especie.")
  }

  if (nrow(X) == 0 || ncol(X) == 0) {
    stop("El objeto '", nombre, "' no puede estar vacío.")
  }

  X <- as.data.frame(X, stringsAsFactors = FALSE)
  rownames(X) <- .fix(rownames(X))

  if (anyDuplicated(rownames(X))) {
    dups <- unique(rownames(X)[duplicated(rownames(X))])
    stop(
      "El objeto '", nombre, "' tiene nombres de especie duplicados: ",
      paste(utils::head(dups, 10), collapse = ", ")
    )
  }

  X[] <- lapply(X, function(v) suppressWarnings(as.numeric(v)))

  if (any(vapply(X, function(v) all(is.na(v)), logical(1)))) {
    stop("El objeto '", nombre, "' contiene columnas no numéricas o totalmente NA.")
  }

  as.matrix(X)
}

.preparar_tax1 <- function(tax1) {
  if (!is.data.frame(tax1)) {
    stop("'tax1' debe ser un data.frame.")
  }

  nombres_validos <- c("Abbrev", "Abrev")
  col_abrev <- intersect(nombres_validos, colnames(tax1))

  if (length(col_abrev) == 0 || !"LatinName" %in% colnames(tax1)) {
    stop("'tax1' debe contener 'LatinName' y una columna 'Abbrev' o 'Abrev'.")
  }

  col_abrev <- col_abrev[1]

  tax1 <- data.frame(
    Abbrev = .fix(tax1[[col_abrev]]),
    LatinName = .fix(tax1$LatinName),
    stringsAsFactors = FALSE
  )

  tax1 <- tax1[!is.na(tax1$Abbrev) & !is.na(tax1$LatinName), , drop = FALSE]
  tax1 <- tax1[tax1$Abbrev != "" & tax1$LatinName != "", , drop = FALSE]
  tax1 <- unique(tax1)

  if (nrow(tax1) == 0) {
    stop("El diccionario 'tax1' quedó vacío después de la depuración.")
  }

  tax1
}

.pad_to_tree <- function(X, spp_ref) {
  X <- .validar_par(X, "par_alineado")

  faltantes <- setdiff(spp_ref, rownames(X))
  if (length(faltantes) > 0) {
    add <- matrix(
      0,
      nrow = length(faltantes),
      ncol = ncol(X),
      dimnames = list(faltantes, colnames(X))
    )
    X <- rbind(X, add)
  }

  X <- X[spp_ref, , drop = FALSE]
  storage.mode(X) <- "numeric"
  X
}

# ---------------------------------------------------------
# 2. Función principal
# ---------------------------------------------------------

alinear_beta <- function(biol_PD_beta, arbol_beta, tax1 = NULL, min_abbrev_prop = 0.6) {

  if (!inherits(arbol_beta, "phylo")) {
    stop("'arbol_beta' debe ser de clase 'phylo'.")
  }

  if (is.null(arbol_beta$tip.label) || length(arbol_beta$tip.label) == 0) {
    stop("El árbol no contiene etiquetas de puntas ('tip.label').")
  }

  if (!is.list(biol_PD_beta) || length(biol_PD_beta) == 0) {
    stop("'biol_PD_beta' debe ser una lista no vacía de matrices Especies × Sitios.")
  }

  if (!is.numeric(min_abbrev_prop) || length(min_abbrev_prop) != 1 ||
      is.na(min_abbrev_prop) || min_abbrev_prop < 0 || min_abbrev_prop > 1) {
    stop("'min_abbrev_prop' debe ser un número entre 0 y 1.")
  }

  n_tips_tree_original <- length(arbol_beta$tip.label)

  if (!is.null(tax1)) {
    tax1 <- .preparar_tax1(tax1)
  }

  # -------------------------------------------------------
  # 2.1 Normalizar nombres en árbol y matrices
  # -------------------------------------------------------

  arbol_beta$tip.label <- .fix(arbol_beta$tip.label)

  if (anyDuplicated(arbol_beta$tip.label)) {
    dups <- unique(arbol_beta$tip.label[duplicated(arbol_beta$tip.label)])
    stop(
      "El árbol contiene etiquetas de puntas duplicadas: ",
      paste(utils::head(dups, 10), collapse = ", ")
    )
  }

  nombres_pares <- names(biol_PD_beta)
  if (is.null(nombres_pares)) {
    nombres_pares <- paste0("par_", seq_along(biol_PD_beta))
  } else {
    nombres_pares[nombres_pares == ""] <- paste0("par_", which(nombres_pares == ""))
  }

  biol_PD_beta <- stats::setNames(
    lapply(seq_along(biol_PD_beta), function(i) {
      .validar_par(biol_PD_beta[[i]], nombre = nombres_pares[i])
    }),
    nm = nombres_pares
  )

  # -------------------------------------------------------
  # 2.2 Reetiquetar árbol si viene en abreviaturas
  # -------------------------------------------------------

  changed <- FALSE
  dropped <- character(0)
  prop_abbrev_arbol <- NA_real_

  if (!is.null(tax1)) {
    prop_abbrev_arbol <- mean(arbol_beta$tip.label %in% tax1$Abbrev)

    if (!is.nan(prop_abbrev_arbol) && prop_abbrev_arbol >= min_abbrev_prop) {
      mapA2L <- stats::setNames(tax1$LatinName, tax1$Abbrev)
      newtips <- unname(mapA2L[arbol_beta$tip.label])
      keep <- !is.na(newtips)

      if (any(!keep)) {
        dropped <- arbol_beta$tip.label[!keep]
        arbol_beta <- ape::drop.tip(arbol_beta, dropped)
      }

      arbol_beta$tip.label <- .fix(newtips[keep])

      if (anyDuplicated(arbol_beta$tip.label)) {
        dups <- unique(arbol_beta$tip.label[duplicated(arbol_beta$tip.label)])
        stop(
          "Después de reetiquetar el árbol quedaron puntas duplicadas: ",
          paste(utils::head(dups, 10), collapse = ", ")
        )
      }

      changed <- TRUE
    }
  }

  # -------------------------------------------------------
  # 2.3 Intersección árbol ↔ datos
  # -------------------------------------------------------

  spp_pairs <- unique(unlist(lapply(biol_PD_beta, rownames)))
  spp_pairs <- .fix(spp_pairs)

  keep_spp <- intersect(spp_pairs, arbol_beta$tip.label)

  if (length(keep_spp) == 0) {
    faltan_en_arbol <- setdiff(spp_pairs, arbol_beta$tip.label)
    stop(
      "Intersección vacía entre árbol y datos. Ejemplos (datos pero no árbol): ",
      paste(utils::head(faltan_en_arbol, 10), collapse = "; ")
    )
  }

  if (length(keep_spp) < 2) {
    stop("La intersección entre árbol y datos tiene menos de dos especies.")
  }

  # -------------------------------------------------------
  # 2.4 Podar árbol y alinear pares
  # -------------------------------------------------------

  arbol_aligned <- ape::keep.tip(arbol_beta, keep_spp)
  spp_ref <- arbol_aligned$tip.label

  pairs_aligned <- lapply(biol_PD_beta, .pad_to_tree, spp_ref = spp_ref)

  ok_all <- all(vapply(pairs_aligned, function(x) identical(rownames(x), spp_ref), logical(1)))
  if (!ok_all) {
    stop("No todos los pares quedaron alineados con el árbol.")
  }

  if (any(vapply(pairs_aligned, function(x) all(colSums(x, na.rm = TRUE) == 0), logical(1)))) {
    stop("Al menos uno de los pares quedó sin abundancias positivas después de la alineación.")
  }

  # -------------------------------------------------------
  # 2.5 Reporte
  # -------------------------------------------------------

  report <- list(
    n_pairs = length(biol_PD_beta),
    pairs_names = names(biol_PD_beta),
    n_tips_tree_in = n_tips_tree_original,
    n_tips_tree_out = length(arbol_aligned$tip.label),
    relabeled_tree = changed,
    prop_abbrev_in_tree = prop_abbrev_arbol,
    tips_dropped = dropped,
    species_union = length(spp_pairs),
    species_kept = length(keep_spp),
    species_dropped_from_data = setdiff(spp_pairs, keep_spp)
  )

  list(
    pairs_aligned = pairs_aligned,
    tree_aligned = arbol_aligned,
    report = report
  )
}
