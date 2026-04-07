# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 00_setup.R
# Propósito: cargar paquetes y preparar el entorno de trabajo
# =========================================================

required_pkgs <- c(
  "tidyverse", "readxl", "writexl", "FD", "cluster", "ape",
  "picante", "vegan", "ggrepel", "viridis", "cowplot",
  "iNEXT.3D", "iNEXTbeta3D", "ade4"
)

missing_pkgs <- required_pkgs[
  !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_pkgs) > 0) {
  message("Instale primero estos paquetes: ", paste(missing_pkgs, collapse = ", "))
}

invisible(lapply(
  intersect(required_pkgs, rownames(installed.packages())),
  library,
  character.only = TRUE
))

if (!dir.exists("outputs/figuras")) dir.create("outputs/figuras", recursive = TRUE)
if (!dir.exists("outputs/tablas")) dir.create("outputs/tablas", recursive = TRUE)

root_dir <- getwd()
data_dir <- file.path(root_dir, "data", "raw")

message("Proyecto cargado desde: ", root_dir)
message("Directorio de datos esperado: ", data_dir)
