# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 06_Rao_ajustado.R
# Propósito: calcular componentes alfa, gamma y beta de diversidad
#            taxonómica (TD), funcional (FD) y filogenética (PD)
#            mediante la entropía cuadrática de Rao.
# =========================================================

if (!requireNamespace("ade4", quietly = TRUE)) {
  stop("Falta el paquete 'ade4'. Instálalo antes de usar esta función.")
}

# ---------------------------------------------------------
# 1. Utilidades internas
# ---------------------------------------------------------

.validar_matriz_distancias <- function(d, nombre = "distancia") {
  if (inherits(d, "dist")) d <- as.matrix(d)

  if (!is.matrix(d)) {
    stop("El objeto '", nombre, "' debe ser una matriz o un objeto de clase 'dist'.")
  }

  if (nrow(d) != ncol(d)) {
    stop("La matriz '", nombre, "' debe ser cuadrada.")
  }

  if (anyNA(d)) {
    stop("La matriz '", nombre, "' contiene valores NA.")
  }

  d <- apply(d, 2, as.numeric)
  d <- as.matrix(d)
  rownames(d) <- rownames(as.matrix(d))
  colnames(d) <- colnames(as.matrix(d))

  d
}

.validar_muestra <- function(sample) {
  if (!(is.matrix(sample) || is.data.frame(sample))) {
    stop("'sample' debe ser matriz o data.frame de comunidades × especies.")
  }

  sample <- as.data.frame(sample, stringsAsFactors = FALSE)

  if (nrow(sample) == 0 || ncol(sample) == 0) {
    stop("'sample' no puede estar vacío.")
  }

  if (is.null(rownames(sample))) {
    rownames(sample) <- paste0("Sitio_", seq_len(nrow(sample)))
  }

  sample[] <- lapply(sample, function(v) suppressWarnings(as.numeric(v)))

  if (any(vapply(sample, function(v) all(is.na(v)), logical(1)))) {
    stop("'sample' contiene columnas no numéricas o totalmente NA.")
  }

  sample[is.na(sample)] <- 0

  if (any(as.matrix(sample) < 0)) {
    stop("'sample' contiene abundancias negativas.")
  }

  if (any(rowSums(sample) <= 0)) {
    stop("Todas las comunidades deben tener abundancia total positiva.")
  }

  if (any(colSums(sample) <= 0)) {
    stop("Todas las especies deben tener abundancia total positiva.")
  }

  as.data.frame(sample)
}

.validar_coincidencia <- function(sample, d, nombre = "distancia") {
  if (ncol(sample) != nrow(d)) {
    stop(
      "Dimensiones incompatibles entre 'sample' y '", nombre,
      "': ncol(sample) = ", ncol(sample),
      ", nrow(", nombre, ") = ", nrow(d), "."
    )
  }
  invisible(TRUE)
}

# ---------------------------------------------------------
# 2. Funciones internas del cálculo de Rao
# ---------------------------------------------------------

Qdecomp <- function(functdist, abundances, w = TRUE) {
  abundances <- as.matrix(abundances)
  functdist  <- .validar_matriz_distancias(functdist, "functdist")

  if (ncol(abundances) != nrow(functdist)) {
    stop("Diferente número de especies entre 'functdist' y 'abundances'.")
  }

  abundances[is.na(abundances)] <- 0

  abloc <- apply(abundances, 1, sum)
  if (any(abloc <= 0)) {
    stop("Todas las comunidades deben tener abundancia total positiva en 'abundances'.")
  }

  nbsploc <- apply(abundances, 1, function(x) length(which(x > 0)))
  locabrel <- abundances / abloc

  Qalpha <- apply(locabrel, 1, function(x) as.numeric(t(x) %*% functdist %*% x))
  Wc <- abloc / sum(abloc)

  if (w) {
    mQalpha <- as.numeric(Qalpha %*% abloc / sum(abloc))
    totabrel <- apply(abundances, 2, sum) / sum(abundances)
    Qalpha <- Qalpha * Wc
  } else {
    mQalpha <- mean(Qalpha)
    totabrel <- apply(locabrel, 2, mean)
  }

  Qgamma <- as.numeric((totabrel %*% functdist %*% totabrel)[1])
  Qbeta <- as.numeric(Qgamma - mQalpha)
  Qbetastd <- if (isTRUE(all.equal(Qgamma, 0))) NA_real_ else as.numeric(Qbeta / Qgamma)

  list(
    Richness_per_plot = nbsploc,
    Relative_abundance = locabrel,
    Pi = totabrel,
    Wc = Wc,
    Species_abundance_per_plot = abloc,
    Alpha = Qalpha,
    Mean_alpha = mQalpha,
    Gamma = Qgamma,
    Beta = Qbeta,
    Standardize_Beta = Qbetastd
  )
}

disc <- function(samples, dis = NULL, structures = NULL, Jost = FALSE) {
  if (!inherits(samples, "data.frame"))
    stop("Non convenient samples")
  if (any(samples < 0))
    stop("Negative value in samples")
  if (any(apply(samples, 2, sum) < 1e-16))
    stop("Empty samples")

  if (!is.null(dis)) {
    if (!inherits(dis, "dist"))
      stop("Object of class 'dist' expected for distance")
    dis <- as.matrix(dis)
    if (nrow(samples) != nrow(dis))
      stop("Non convenient samples")
  }

  if (!is.null(structures)) {
    if (!inherits(structures, "data.frame"))
      stop("Non convenient structures")
    m <- match(apply(structures, 2, function(x) length(x)), ncol(samples), 0)
    if (length(m[m == 1]) != ncol(structures))
      stop("Non convenient structures")
    m <- match(
      tapply(1:ncol(structures), as.factor(1:ncol(structures)),
             function(x) is.factor(structures[, x])),
      TRUE, 0
    )
    if (length(m[m == 1]) != ncol(structures))
      stop("Non convenient structures")
  }

  Structutil <- function(dp2, Np, unit, Jost) {
    if (!is.null(unit)) {
      modunit <- model.matrix(~ -1 + unit)
      sumcol <- apply(Np, 2, sum)
      Ng <- modunit * sumcol
      lesnoms <- levels(unit)
    } else {
      Ng <- as.matrix(Np)
      lesnoms <- colnames(Np)
    }

    sumcol <- apply(Ng, 2, sum)
    Lg <- t(t(Ng) / sumcol)
    colnames(Lg) <- lesnoms
    Pg <- as.matrix(apply(Ng, 2, sum) / nbhaplotypes)
    rownames(Pg) <- lesnoms
    deltag <- as.matrix(apply(Lg, 2, function(x) t(x) %*% dp2 %*% x))
    ug <- matrix(1, ncol(Lg), 1)

    if (Jost) {
      X <- t(Lg) %*% dp2 %*% Lg
      alpha <- 1 / 2 * (deltag %*% t(ug) + ug %*% t(deltag))
      Gam <- (X + alpha) / 2
      alpha <- 1 / (1 - alpha)
      Gam <- 1 / (1 - Gam)
      Beta_add <- Gam - alpha
      Beta_mult <- 100 * (Gam - alpha) / Gam
    } else {
      X <- t(Lg) %*% dp2 %*% Lg
      alpha <- 1 / 2 * (deltag %*% t(ug) + ug %*% t(deltag))
      Gam <- (X + alpha) / 2
      Beta_add <- Gam - alpha
      Beta_mult <- 100 * (Gam - alpha) / Gam
    }

    colnames(Beta_add) <- lesnoms
    rownames(Beta_add) <- lesnoms

    list(
      Beta_add = as.dist(Beta_add),
      Beta_mult = as.dist(Beta_mult),
      Gamma = as.dist(Gam),
      Alpha = as.dist(alpha),
      Ng = Ng,
      Pg = Pg
    )
  }

  Diss <- function(dis, nbhaplotypes, samples, structures, Jost) {
    structutil <- list(0)
    structutil[[1]] <- Structutil(dp2 = dis, Np = samples, unit = NULL, Jost = Jost)
    diss <- list(
      structutil[[1]]$Alpha,
      structutil[[1]]$Gamma,
      structutil[[1]]$Beta_add,
      structutil[[1]]$Beta_mult
    )

    if (!is.null(structures)) {
      for (i in 1:length(structures)) {
        structutil[[i + 1]] <- Structutil(
          as.matrix(structutil[[1]]$Beta_add),
          structutil[[1]]$Ng,
          structures[, i],
          Jost
        )
      }
      diss <- c(
        diss,
        tapply(1:length(structures), factor(1:length(structures)),
               function(x) as.dist(structutil[[x + 1]]$Beta_add))
      )
    }

    diss
  }

  nbhaplotypes <- sum(samples)
  diss <- Diss(dis, nbhaplotypes, samples, structures, Jost)

  if (!is.null(structures)) {
    names(diss) <- c("Alpha", "Gamma", "Beta_add", "Beta_prop", "Beta_region")
  } else {
    names(diss) <- c("Alpha", "Gamma", "Beta_add", "Beta_prop")
  }

  diss
}

# ---------------------------------------------------------
# 3. Función principal
# ---------------------------------------------------------

Rao <- function(sample,
                dfunc = NULL,
                dphyl = NULL,
                weight = FALSE,
                Jost = FALSE,
                structure = NULL) {

  sample <- .validar_muestra(sample)

  if (!is.null(dfunc)) {
    dfunc <- .validar_matriz_distancias(dfunc, "dfunc")
    .validar_coincidencia(sample, dfunc, "dfunc")
  }

  if (!is.null(dphyl)) {
    dphyl <- .validar_matriz_distancias(dphyl, "dphyl")
    .validar_coincidencia(sample, dphyl, "dphyl")
  }

  TD <- list()
  FD <- NULL
  PD <- NULL

  # -------------------------------------------------------
  # 3.1 Diversidad taxonómica
  # -------------------------------------------------------

  dS <- matrix(1, ncol(sample), ncol(sample)) - diag(rep(1, ncol(sample)))
  temp_qdec <- Qdecomp(dS, t(sample), w = weight)

  TD$Richness_per_plot <- temp_qdec$Richness_per_plot
  TD$Relative_abundance <- temp_qdec$Relative_abundance
  TD$Pi <- temp_qdec$Pi
  TD$Wc <- temp_qdec$Wc

  if (Jost) {
    TD$Mean_Alpha <- 1 / (1 - temp_qdec$Mean_alpha)
    TD$Alpha <- 1 / (1 - temp_qdec$Alpha)
    TD$Gamma <- 1 / (1 - temp_qdec$Gamma)
  } else {
    TD$Mean_Alpha <- temp_qdec$Mean_alpha
    TD$Alpha <- temp_qdec$Alpha
    TD$Gamma <- temp_qdec$Gamma
  }

  TD$Beta_add <- TD$Gamma - TD$Mean_Alpha
  TD$Beta_prop <- 100 * TD$Beta_add / TD$Gamma
  TD$Pairwise_samples <- disc(
    as.data.frame(sample),
    as.dist(dS),
    structures = structure,
    Jost = Jost
  )

  # -------------------------------------------------------
  # 3.2 Diversidad funcional
  # -------------------------------------------------------

  if (!is.null(dfunc)) {
    FD <- list()
    dfunc_use <- dfunc

    if (Jost && max(dfunc_use) > 1) {
      dfunc_use <- dfunc_use / max(dfunc_use)
    }

    temp_qdec <- Qdecomp(dfunc_use, t(sample), w = weight)

    if (Jost) {
      FD$Mean_Alpha <- 1 / (1 - temp_qdec$Mean_alpha)
      FD$Alpha <- 1 / (1 - temp_qdec$Alpha)
      FD$Gamma <- 1 / (1 - temp_qdec$Gamma)
    } else {
      FD$Mean_Alpha <- temp_qdec$Mean_alpha
      FD$Alpha <- temp_qdec$Alpha
      FD$Gamma <- temp_qdec$Gamma
    }

    FD$Beta_add <- FD$Gamma - FD$Mean_Alpha
    FD$Beta_prop <- 100 * FD$Beta_add / FD$Gamma
    FD$Pairwise_samples <- disc(
      as.data.frame(sample),
      as.dist(dfunc_use),
      structures = structure,
      Jost = Jost
    )
  }

  # -------------------------------------------------------
  # 3.3 Diversidad filogenética
  # -------------------------------------------------------

  if (!is.null(dphyl)) {
    PD <- list()
    dphyl_use <- dphyl

    if (Jost && max(dphyl_use) > 1) {
      dphyl_use <- dphyl_use / max(dphyl_use)
    }

    temp_qdec <- Qdecomp(dphyl_use, t(sample), w = weight)

    if (Jost) {
      PD$Mean_Alpha <- 1 / (1 - temp_qdec$Mean_alpha)
      PD$Alpha <- 1 / (1 - temp_qdec$Alpha)
      PD$Gamma <- 1 / (1 - temp_qdec$Gamma)
    } else {
      PD$Mean_Alpha <- temp_qdec$Mean_alpha
      PD$Alpha <- temp_qdec$Alpha
      PD$Gamma <- temp_qdec$Gamma
    }

    PD$Beta_add <- PD$Gamma - PD$Mean_Alpha
    PD$Beta_prop <- 100 * PD$Beta_add / PD$Gamma
    PD$Pairwise_samples <- disc(
      as.data.frame(sample),
      as.dist(dphyl_use),
      structures = structure,
      Jost = Jost
    )
  }

  out <- list(TD = TD, FD = FD, PD = PD)
  out
}
