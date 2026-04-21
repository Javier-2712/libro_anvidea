# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: 00_setup.R
# Propósito: Configuración inicial del entorno de trabajo
# =========================================================

required_packages <- c(
  "tidyverse",
  "ggplot2",
  "readxl",
  "readr",
  "knitr",
  "kableExtra",
  "scales",
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

cat("Entorno configurado correctamente.\n")
