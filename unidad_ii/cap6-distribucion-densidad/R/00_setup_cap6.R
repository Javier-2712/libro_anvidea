# =========================================================
# ANDIVEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# Archivo: 00_setup.R
# Propósito: cargar paquetes y preparar el entorno de trabajo
#             para los casos del capítulo 6
# =========================================================

# ---------------------------------------------------------
# Paquetes requeridos
# ---------------------------------------------------------
required_packages <- c(
  "tidyverse",
  "readxl",
  "writexl",
  "MASS",
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
archivo_datos_cap6 <- file.path(data_dir, "datos.c6.xlsx")

if (!file.exists(archivo_datos_cap6)) {
  warning(
    paste0(
      "No se encontró el archivo principal del capítulo 6 en: ",
      archivo_datos_cap6
    )
  )
}

message("📁 Directorio de trabajo: ", root_dir)
message("📊 Directorio de datos esperado: ", data_dir)
message("✔ Entorno del Capítulo 6 cargado correctamente")
