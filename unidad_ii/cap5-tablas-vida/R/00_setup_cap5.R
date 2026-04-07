# =========================================================
# ANDIVEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 00_setup.R
# Propósito: preparar el entorno de trabajo para los casos
#             A1, A2, B y C del capítulo 5
# =========================================================

# ---------------------------------------------------------
# Paquetes requeridos
# ---------------------------------------------------------
required_packages <- c(
  "tidyverse",
  "readxl",
  "writexl",
  "ggplot2",
  "tidyr",
  "tibble"
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
# Rutas de trabajo
# ---------------------------------------------------------
root_dir <- getwd()
data_dir <- file.path(root_dir, "data", "raw")
fig_dir  <- file.path(root_dir, "outputs", "figuras")
tab_dir  <- file.path(root_dir, "outputs", "tablas")

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------
# Verificación mínima de insumos
# ---------------------------------------------------------
archivo_datos_cap5 <- file.path(data_dir, "datos.c5.xlsx")

if (!file.exists(archivo_datos_cap5)) {
  warning(
    paste0(
      "No se encontró el archivo principal del capítulo 5 en: ",
      archivo_datos_cap5
    )
  )
}

message("✔ Entorno del Capítulo 5 cargado correctamente")
