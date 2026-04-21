# =========================================================
# ANVIDEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# ---------------------------------------------------------
# Archivo : 00_setup.R
# Propósito: cargar paquetes, definir rutas y preparar el
#             entorno de trabajo para los casos guiados del
#             capítulo 6.
# =========================================================

cat("\n========================================\n")
cat("ANVIDEA - Cap\u00edtulo 6\n")
cat("Patrones de distribuci\u00f3n y estimaci\u00f3n de la densidad\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paquetes requeridos
# ---------------------------------------------------------

required_packages <- c(
  "tidyverse",
  "readxl",
  "writexl",
  "MASS",
  "ggplot2",
  "tibble",
  "dplyr",
  "tidyr",
  "kableExtra"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Instale primero estos paquetes: ",
      paste(missing_packages, collapse = ", ")
    )
  )
}

invisible(lapply(required_packages, library, character.only = TRUE))

# ---------------------------------------------------------
# Opciones generales
# ---------------------------------------------------------

options(
  scipen = 999,
  dplyr.summarise.inform = FALSE
)

# ---------------------------------------------------------
# Directorio de trabajo y rutas
# ---------------------------------------------------------

root_dir   <- getwd()
data_dir   <- file.path(root_dir, "data", "raw")
output_dir <- file.path(root_dir, "outputs")
fig_dir    <- file.path(output_dir, "figuras")
tab_dir    <- file.path(output_dir, "tablas")
rep_dir    <- file.path(output_dir, "reportes")

rutas_requeridas <- c(data_dir, fig_dir, tab_dir, rep_dir)
invisible(lapply(rutas_requeridas, dir.create,
                 recursive = TRUE, showWarnings = FALSE))

# ---------------------------------------------------------
# Archivos principales del capítulo
# ---------------------------------------------------------

archivo_datos_cap6  <- file.path(data_dir, "datos.c6.xlsx")
archivo_reporte_cap6 <- file.path(root_dir, "reporte_cap6.qmd")

if (!file.exists(archivo_datos_cap6)) {
  warning(
    paste0(
      "No se encontr\u00f3 el archivo principal del cap\u00edtulo 6 en: ",
      archivo_datos_cap6
    )
  )
}

# Alias corto para uso directo en los scripts de casos guiados
archivo_datos <- archivo_datos_cap6

# ---------------------------------------------------------
# Mensajes de control
# ---------------------------------------------------------

cat("\nDirectorio de trabajo:\n")
cat(root_dir, "\n")

cat("\nRutas principales del cap\u00edtulo:\n")
cat("- Datos   : ", data_dir,  "\n", sep = "")
cat("- Figuras : ", fig_dir,   "\n", sep = "")
cat("- Tablas  : ", tab_dir,   "\n", sep = "")
cat("- Reportes: ", rep_dir,   "\n", sep = "")

cat("\nEntorno del Cap\u00edtulo 6 configurado correctamente.\n")
