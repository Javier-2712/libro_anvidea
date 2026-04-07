# =========================================================
# ANVIDEA - Unidad I
# Capítulo 3 - Visualización gráfica de patrones climáticos
# Archivo: 00_setup.R
# Propósito: cargar paquetes y preparar el entorno de trabajo
# =========================================================

# ---------------------------------------------------------
# 1. Paquetes requeridos
# ---------------------------------------------------------

required_packages <- c(
  "tidyverse",
  "readxl",
  "janitor",
  "cowplot",
  "viridis",
  "writexl"
)

# Detectar paquetes faltantes
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

# Verificación
if (length(missing_packages) > 0) {
  stop(
    "Instale primero estos paquetes: ",
    paste(missing_packages, collapse = ", ")
  )
}

# ---------------------------------------------------------
# 2. Cargar paquetes
# ---------------------------------------------------------

invisible(lapply(
  required_packages,
  function(pkg) suppressPackageStartupMessages(
    library(pkg, character.only = TRUE)
  )
))

# ---------------------------------------------------------
# 3. Crear carpetas de salida
# ---------------------------------------------------------

if (!dir.exists("outputs/figuras")) {
  dir.create("outputs/figuras", recursive = TRUE, showWarnings = FALSE)
}

if (!dir.exists("outputs/tablas")) {
  dir.create("outputs/tablas", recursive = TRUE, showWarnings = FALSE)
}

# ---------------------------------------------------------
# 4. Directorios de trabajo
# ---------------------------------------------------------

root_dir <- getwd()
data_dir <- file.path(root_dir, "data", "raw")

if (!dir.exists(data_dir)) {
  stop(
    "No se encontró el directorio de datos esperado: ", data_dir,
    "\nVerifique que la estructura del proyecto incluya la carpeta data/raw."
  )
}

# ---------------------------------------------------------
# 5. Mensajes de verificación
# ---------------------------------------------------------

message("Proyecto cargado desde: ", root_dir)
message("Directorio de datos: ", data_dir)
message("Carpetas de salida listas en: outputs/figuras y outputs/tablas")
