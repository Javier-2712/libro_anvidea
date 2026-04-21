# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# ---------------------------------------------------------
# Archivo : 00_setup.R
# Propósito: cargar paquetes, definir rutas y preparar el
#             entorno de trabajo para los casos del capítulo 7
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Cap\u00edtulo 7\n")
cat("Diversidad taxon\u00f3mica\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paquetes requeridos
# ---------------------------------------------------------

required_pkgs <- c(
  "tidyverse", "readxl", "writexl",
  "vegan", "ggrepel", "viridis",
  "iNEXT", "iNEXT.4steps", "iNEXT.3D", "iNEXT.beta3D",
  "adespatial", "betapart", "ade4",
  "cluster", "factoextra", "gridExtra",
  "ggforce", "patchwork",
  "mvabund", "MASS", "glmmTMB", "RVAideMemoire",
  "MVN", "car", "corrplot",
  "kableExtra"
)

missing_pkgs <- required_pkgs[
  !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_pkgs) > 0) {
  stop("Instala estos paquetes antes de continuar: ",
       paste(missing_pkgs, collapse = ", "))
}

invisible(lapply(required_pkgs, library, character.only = TRUE))

# ---------------------------------------------------------
# Opciones generales
# ---------------------------------------------------------

options(
  scipen                 = 999,
  dplyr.summarise.inform = FALSE
)

# ---------------------------------------------------------
# Rutas de trabajo
# ---------------------------------------------------------

root_dir <- getwd()
data_dir <- file.path(root_dir, "data", "raw")
fig_dir  <- file.path(root_dir, "outputs", "figuras")
tab_dir  <- file.path(root_dir, "outputs", "tablas")
rep_dir  <- file.path(root_dir, "outputs", "reportes")

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(rep_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------
# Archivo principal del capítulo
# ---------------------------------------------------------

archivo_datos <- file.path(data_dir, "datos.c7.xlsx")

if (!file.exists(archivo_datos)) {
  stop("No se encontr\u00f3 datos.c7.xlsx en data/raw/.\n",
       "Verifica la ruta: ", archivo_datos)
}

cat("\nEntorno del Cap\u00edtulo 7 configurado correctamente.\n")
