# =========================================================
# ANVIDEA - Capítulo 1
# Archivo: 05_render_reporte.R
# Propósito: renderizar reporte HTML con Quarto
# =========================================================

cat("Renderizando reporte del capítulo 1 con Quarto...\n")

archivo_reporte   <- file.path(root_dir, "reporte_cap1.qmd")
dir_salida        <- file.path(root_dir, "outputs", "reportes")
archivo_salida    <- "reporte_cap1.html"
salida_html_final <- file.path(dir_salida, archivo_salida)
salida_html_tmp   <- file.path(root_dir, archivo_salida)
carpeta_files_tmp   <- file.path(root_dir, "reporte_cap1_files")
carpeta_files_final <- file.path(dir_salida, "reporte_cap1_files")

# ---------------------------------------------------------
# 1. Verificaciones
# ---------------------------------------------------------

if (!file.exists(archivo_reporte)) stop("No se encontró: ", archivo_reporte)
if (!dir.exists(dir_salida)) dir.create(dir_salida, recursive = TRUE, showWarnings = FALSE)

quarto_bin <- Sys.which("quarto")
if (quarto_bin == "") stop("Quarto no encontrado. Instálalo o agrégalo al PATH.")

# ---------------------------------------------------------
# 2. Renderizar
# ---------------------------------------------------------

old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(root_dir)

# Limpiar salidas previas
for (f in c(salida_html_tmp, salida_html_final)) {
  if (file.exists(f)) file.remove(f)
}
for (d in c(carpeta_files_tmp, carpeta_files_final)) {
  if (dir.exists(d)) unlink(d, recursive = TRUE, force = TRUE)
}

salida <- system2(
  command = quarto_bin,
  args    = c("render", "reporte_cap1.qmd", "--to", "html", "--output", archivo_salida),
  stdout  = TRUE, stderr = TRUE
)

estado <- attr(salida, "status")
if (is.null(estado)) estado <- 0L

cat("\n================ SALIDA DE QUARTO ================\n")
cat(paste(salida, collapse = "\n"))
cat("\n==================================================\n\n")

if (estado != 0) stop("Quarto finalizó con error.")

# ---------------------------------------------------------
# 3. Mover HTML y carpeta auxiliar a outputs/reportes
# ---------------------------------------------------------

if (!file.exists(salida_html_tmp)) stop("No se generó: ", salida_html_tmp)

ok_html <- file.rename(salida_html_tmp, salida_html_final)
if (!ok_html) {
  ok_html <- file.copy(salida_html_tmp, salida_html_final, overwrite = TRUE)
  if (!ok_html) stop("No fue posible mover el HTML a: ", salida_html_final)
  file.remove(salida_html_tmp)
}

if (dir.exists(carpeta_files_tmp)) {
  ok_dir <- file.rename(carpeta_files_tmp, carpeta_files_final)
  if (!ok_dir) {
    dir.create(carpeta_files_final, recursive = TRUE, showWarnings = FALSE)
    archivos_aux <- list.files(carpeta_files_tmp, full.names = TRUE,
                               all.files = TRUE, no.. = TRUE)
    file.copy(archivos_aux, carpeta_files_final, overwrite = TRUE, recursive = TRUE)
    unlink(carpeta_files_tmp, recursive = TRUE, force = TRUE)
  }
}

cat("Reporte generado en: ", salida_html_final, "\n", sep = "")
