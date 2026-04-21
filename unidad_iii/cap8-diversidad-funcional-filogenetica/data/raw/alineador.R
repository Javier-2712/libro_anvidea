# alineador.R
# Alinea la lista de matrices de abundancia (biol_PD_beta) con el árbol (arbol_beta)
# Opcionalmente reetiqueta el árbol si viene en abreviaturas usando tax1 (Abbrev, LatinName)
# Devuelve: list(pairs_aligned, tree_aligned, report)

suppressWarnings({
  if (!requireNamespace("ape", quietly = TRUE)) stop("Falta 'ape'. Instálalo.")
})

.fix <- function(x) { x <- trimws(x); gsub("\\s+", " ", x) }

.pad_to_tree <- function(X, spp_ref){
  X <- as.data.frame(X)
  # añadir especies del árbol que falten en X como filas con ceros
  missing <- setdiff(spp_ref, rownames(X))
  if (length(missing) > 0) {
    add <- matrix(0, nrow = length(missing), ncol = ncol(X),
                  dimnames = list(missing, colnames(X)))
    X <- rbind(X, add)
  }
  # reordenar filas como el árbol y coercionar a numérico
  X <- X[spp_ref, , drop = FALSE]
  X[] <- lapply(X, function(v) suppressWarnings(as.numeric(v)))
  as.matrix(X)
}

alinear_beta <- function(biol_PD_beta, arbol_beta, tax1 = NULL, min_abbrev_prop = 0.6){
  # --- chequeos básicos ---
  if (!inherits(arbol_beta, "phylo")) stop("'arbol_beta' debe ser clase 'phylo'.")
  if (!is.list(biol_PD_beta) || length(biol_PD_beta) == 0) {
    stop("'biol_PD_beta' debe ser una lista no vacía de matrices Especies×Sitios (pares).")
  }
  if (!is.null(tax1)) {
    stopifnot(all(c("Abbrev","LatinName") %in% colnames(tax1)))
    tax1 <- data.frame(
      Abbrev    = .fix(as.character(tax1$Abbrev)),
      LatinName = .fix(as.character(tax1$LatinName)),
      stringsAsFactors = FALSE
    )
  }
  
  # 1) normalizar nombres en árbol y matrices
  arbol_beta$tip.label <- .fix(arbol_beta$tip.label)
  biol_PD_beta <- lapply(biol_PD_beta, function(X){ 
    rn <- rownames(X); 
    if (is.null(rn)) stop("Cada elemento de 'biol_PD_beta' debe tener rownames = nombres de especie.")
    rownames(X) <- .fix(rn); 
    X
  })
  
  # 2) (opcional) reetiquetar árbol Abbrev -> LatinName si hay diccionario
  changed <- FALSE
  dropped <- character(0)
  if (!is.null(tax1)) {
    prop_abbrev_arbol <- mean(arbol_beta$tip.label %in% tax1$Abbrev)
    if (!is.nan(prop_abbrev_arbol) && prop_abbrev_arbol > min_abbrev_prop) {
      mapA2L  <- setNames(tax1$LatinName, tax1$Abbrev)
      newtips <- unname(mapA2L[arbol_beta$tip.label])
      keep    <- !is.na(newtips)
      if (any(!keep)) {
        dropped <- arbol_beta$tip.label[!keep]
        arbol_beta <- ape::drop.tip(arbol_beta, dropped)
      }
      arbol_beta$tip.label <- .fix(newtips[keep])
      changed <- TRUE
    }
  }
  
  # 3) especies presentes en al menos un par
  spp_pairs <- unique(unlist(lapply(biol_PD_beta, rownames)))
  spp_pairs <- .fix(spp_pairs)
  
  # 4) intersección árbol ↔ datos
  keep_spp  <- intersect(spp_pairs, arbol_beta$tip.label)
  if (length(keep_spp) == 0) {
    faltan_en_arbol <- setdiff(spp_pairs, arbol_beta$tip.label)
    stop(
      "Intersección vacía entre árbol y datos.\n",
      "Ejemplos (en datos pero no en árbol): ",
      paste(utils::head(faltan_en_arbol, 10), collapse = "; ")
    )
  }
  
  # 5) podar árbol a keep_spp
  arbol_aligned <- ape::keep.tip(arbol_beta, keep_spp)
  spp_ref       <- arbol_aligned$tip.label
  
  # 6) rellenar faltantes y reordenar cada par
  pairs_aligned <- lapply(biol_PD_beta, .pad_to_tree, spp_ref = spp_ref)
  
  # 7) chequeo duro
  ok_all <- all(vapply(pairs_aligned, function(x) identical(rownames(x), spp_ref), logical(1)))
  if (!ok_all) stop("No todos los pares quedaron alineados con el árbol.")
  
  # 8) reporte
  report <- list(
    n_pairs          = length(biol_PD_beta),
    n_tips_tree_in   = length(arbol_beta$tip.label),
    n_tips_tree_out  = length(arbol_aligned$tip.label),
    relabeled_tree   = changed,
    tips_dropped     = dropped,
    species_union    = length(spp_pairs),
    species_kept     = length(keep_spp)
  )
  
  list(pairs_aligned = pairs_aligned, tree_aligned = arbol_aligned, report = report)
}
