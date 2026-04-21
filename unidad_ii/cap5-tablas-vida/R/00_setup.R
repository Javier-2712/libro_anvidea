# =========================================================
# ANVIDEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 00_setup.R
# Propósito: preparar el entorno de trabajo del capítulo
# =========================================================

required_packages <- c(
  "tidyverse",
  "readxl",
  "writexl",
  "ggplot2",
  "tibble",
  "patchwork",
  "quarto"
)

missing_packages <- required_packages[
  !(required_packages %in% installed.packages()[, 1])
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

invisible(
  lapply(required_packages, library, character.only = TRUE)
)

root_dir <- getwd()
data_dir <- file.path(root_dir, "data", "raw")
fig_dir  <- file.path(root_dir, "outputs", "figuras")
tab_dir  <- file.path(root_dir, "outputs", "tablas")
rep_dir  <- file.path(root_dir, "outputs", "reportes")

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(rep_dir, recursive = TRUE, showWarnings = FALSE)

options(
  scipen = 999,
  dplyr.summarise.inform = FALSE
)

theme_set(
  ggplot2::theme_minimal(base_size = 12)
)

archivo_datos_cap5 <- file.path(data_dir, "datos.c5.xlsx")

if (!file.exists(archivo_datos_cap5)) {
  warning(
    paste0(
      "No se encontró el archivo principal del capítulo 5 en: ",
      archivo_datos_cap5
    )
  )
}

# Alias corto para uso directo en los scripts de casos guiados
archivo_datos <- archivo_datos_cap5

cat("Entorno del Capítulo 5 configurado correctamente.\n")
