# =========================================================
# ANVIDEA - Unidad I
# Capítulo 2 - Visualización exploratoria de datos ecológicos
# Archivo: 03_funciones_auxiliares_ajustado.R
# Propósito: definir funciones auxiliares reutilizables
# =========================================================

# ---------------------------------------------------------
# 1. Guardar figuras
# ---------------------------------------------------------

guardar_figura <- function(plot_obj, nombre, width = 8, height = 5, dpi = 300) {
  if (missing(plot_obj) || is.null(plot_obj)) {
    stop("Debe suministrar un objeto gráfico válido en 'plot_obj'.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena no vacía.")
  }

  dir.create(file.path("outputs", "figuras"), recursive = TRUE, showWarnings = FALSE)

  ggplot2::ggsave(
    filename = file.path("outputs", "figuras", nombre),
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi
  )
}

# ---------------------------------------------------------
# 2. Guardar tablas en Excel
# ---------------------------------------------------------

guardar_tabla_excel <- function(df, nombre) {
  if (missing(df) || is.null(df)) {
    stop("Debe suministrar un objeto válido en 'df'.")
  }

  if (!inherits(df, c("data.frame", "list"))) {
    stop("El objeto 'df' debe ser un data.frame o una lista de data.frames.")
  }

  if (!is.character(nombre) || length(nombre) != 1 || !nzchar(nombre)) {
    stop("El argumento 'nombre' debe ser una cadena no vacía.")
  }

  dir.create(file.path("outputs", "tablas"), recursive = TRUE, showWarnings = FALSE)

  writexl::write_xlsx(df, file.path("outputs", "tablas", nombre))
}

# ---------------------------------------------------------
# 3. Abreviar taxones
# ---------------------------------------------------------

abreviar_taxones <- function(x, minlength = 4, unique_names = TRUE) {
  x <- as.character(x)

  if (!is.numeric(minlength) || length(minlength) != 1 || is.na(minlength) || minlength < 1) {
    stop("'minlength' debe ser un número positivo.")
  }

  abrev <- abbreviate(x, minlength = minlength)

  if (isTRUE(unique_names)) {
    abrev <- make.unique(abrev, sep = "_")
  }

  abrev
}

# ---------------------------------------------------------
# 4. Panel para histogramas
# ---------------------------------------------------------

panel.hist <- function(x, ...) {
  x <- x[is.finite(x)]

  if (length(x) == 0) {
    return(invisible(NULL))
  }

  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5))

  h <- hist(x, plot = FALSE)
  breaks <- h$breaks
  nB <- length(breaks)
  y <- h$counts

  if (max(y) == 0) {
    return(invisible(NULL))
  }

  y <- y / max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "grey80", ...)
}

# ---------------------------------------------------------
# 5. Panel para correlaciones
# ---------------------------------------------------------

panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  ok <- is.finite(x) & is.finite(y)

  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))

  if (sum(ok) < 2) {
    text(0.5, 0.5, "NA", cex = 0.9)
    return(invisible(NULL))
  }

  r <- abs(stats::cor(x[ok], y[ok], use = "pairwise.complete.obs"))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste0(prefix, txt)

  if (missing(cex.cor)) {
    cex.cor <- 0.8 / strwidth(txt)
  }

  text(0.5, 0.5, txt, cex = cex.cor * r)
}

# ---------------------------------------------------------
# 6. Panel para suavizado
# ---------------------------------------------------------

panel.smooth <- function(x, y, col = par("col"), bg = NA, pch = par("pch"),
                         cex = 1, col.smooth = "red", span = 2/3, iter = 3, ...) {
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)

  ok <- is.finite(x) & is.finite(y)
  if (sum(ok) > 1) {
    lines(
      stats::lowess(x[ok], y[ok], f = span, iter = iter),
      col = col.smooth, ...
    )
  }
}
