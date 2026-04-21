# =========================================================
# ANVIDEA - Capítulo 2
# Archivo: 03_funciones_auxiliares.R
# Propósito: funciones de apoyo para figuras, tablas y reportes
# Cargado automáticamente desde 00_setup.R
# =========================================================

# ---------------------------------------------------------
# 1. Guardar tablas en Excel
# ---------------------------------------------------------

guardar_xlsx <- function(df, ruta_archivo) {
  if (!grepl("\\.xlsx$", ruta_archivo, ignore.case = TRUE)) {
    ruta_archivo <- paste0(ruta_archivo, ".xlsx")
  }
  writexl::write_xlsx(df, path = ruta_archivo)
}

# ---------------------------------------------------------
# 2. Guardar figuras ggplot2
# ---------------------------------------------------------

guardar_figura <- function(plot, nombre, width = 8, height = 5, dpi = 300) {
  ruta <- file.path(ruta_figuras, nombre)
  if (!grepl("\\.png$", ruta, ignore.case = TRUE)) ruta <- paste0(ruta, ".png")
  ggplot2::ggsave(filename = ruta, plot = plot, width = width,
                  height = height, dpi = dpi, bg = "white")
}

# ---------------------------------------------------------
# 3. Guardar figuras base R (corrplot, pairs, gridExtra)
# ---------------------------------------------------------

guardar_base_plot <- function(nombre_archivo, expr,
                              width = 8, height = 6, res = 300) {
  ruta <- file.path(ruta_figuras, nombre_archivo)
  if (!grepl("\\.png$", ruta, ignore.case = TRUE)) ruta <- paste0(ruta, ".png")
  png(filename = ruta, width = width, height = height,
      units = "in", res = res, bg = "white")
  tryCatch(force(expr), finally = dev.off())
}

# ---------------------------------------------------------
# 4. Tabla HTML para reportes
# ---------------------------------------------------------

tabla_html <- function(df, digits = 2) {
  df %>%
    knitr::kable(format = "html", digits = digits, booktabs = TRUE) %>%
    kableExtra::kable_styling(
      bootstrap_options = c("striped", "hover", "condensed"),
      full_width = FALSE
    )
}

# ---------------------------------------------------------
# 5. Guardar y leer objetos RDS
# ---------------------------------------------------------

guardar_rds <- function(objeto, nombre_archivo) {
  ruta <- file.path(ruta_reportes, nombre_archivo)
  if (!grepl("\\.rds$", ruta, ignore.case = TRUE)) ruta <- paste0(ruta, ".rds")
  saveRDS(objeto, file = ruta)
}

leer_rds <- function(nombre_archivo) {
  ruta <- file.path(ruta_reportes, nombre_archivo)
  if (!grepl("\\.rds$", ruta, ignore.case = TRUE)) ruta <- paste0(ruta, ".rds")
  readRDS(ruta)
}

# ---------------------------------------------------------
# 6. Utilidades de apoyo
# ---------------------------------------------------------

# Escala logarítmica segura (log10 con desplazamiento)
log_seguro <- function(x) log10(x + 1)

# Estandarizar nombres de sitios (trim + título)
std_sitio <- function(x) {
  x %>% stringr::str_trim() %>% stringr::str_to_title()
}

# Insertar figura dentro de Quarto (produce sintaxis Markdown)
insertar_figura <- function(nombre_archivo, ancho = "85%") {
  ruta <- file.path("../figuras", nombre_archivo)
  cat(paste0("![](",  ruta, "){fig-align='center' width='", ancho, "'}"))
}

# Resumen numérico rápido (media, SD, min, max por columna)
resumen_numerico <- function(df) {
  df %>%
    dplyr::select(where(is.numeric)) %>%
    dplyr::summarise(dplyr::across(
      everything(),
      list(media = ~ mean(.x, na.rm = TRUE),
           sd    = ~ sd(.x,   na.rm = TRUE),
           min   = ~ min(.x,  na.rm = TRUE),
           max   = ~ max(.x,  na.rm = TRUE))
    )) %>%
    tidyr::pivot_longer(cols = everything(),
                        names_to  = c("variable", ".value"),
                        names_sep = "_")
}

# ---------------------------------------------------------
# 7. Paneles auxiliares para pairs()
# ---------------------------------------------------------

panel.hist <- function(x, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5))
  h  <- hist(x, plot = FALSE)
  y  <- h$counts / max(h$counts, na.rm = TRUE)
  rect(h$breaks[-length(h$breaks)], 0,
       h$breaks[-1], y, col = "gray80", border = "white", ...)
}

panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r   <- suppressWarnings(cor(x, y, use = "pairwise.complete.obs"))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  if (missing(cex.cor)) cex.cor <- 1
  text(0.5, 0.5, paste0(prefix, txt), cex = 1.2 * cex.cor)
}

panel.smooth2 <- function(x, y, col = "#377eb8", bg = NA,
                           pch = 21, cex = 0.8, ...) {
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)
  ok <- is.finite(x) & is.finite(y)
  if (sum(ok) > 2) lines(stats::lowess(x[ok], y[ok]), col = "red", lwd = 1.2)
}
