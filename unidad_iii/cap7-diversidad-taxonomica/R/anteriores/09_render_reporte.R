# =========================================================
# ANVIDEA - Capítulo 7
# Archivo: 09_render_reporte.R
# =========================================================

source("R/00_setup.R")

cat("Renderizando reporte del capítulo 7...\n")

archivo_qmd <- "reporte_cap7.qmd"

if (!file.exists(archivo_qmd)) {
  stop("No se encontró reporte_cap7.qmd")
}

quarto::quarto_render(input = archivo_qmd)

html <- "reporte_cap7.html"
dest <- file.path(rep_dir, html)

if (file.exists(html)) {
  if (file.exists(dest)) file.remove(dest)
  file.rename(html, dest)
  cat("Reporte movido a outputs/reportes/\n")
}
