# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 7\n")
cat("Diversidad taxonómica\n")
cat("========================================\n")

required_pkgs <- c(
  "tidyverse","readxl","writexl","vegan",
  "ggrepel","viridis",
  "iNEXT","iNEXT.4steps","iNEXT.3D","iNEXTbeta3D",
  "adespatial","betapart","kableExtra"
)

missing_pkgs <- required_pkgs[
 !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
]

if(length(missing_pkgs)>0){
 stop("Instala estos paquetes: ", paste(missing_pkgs, collapse=", "))
}

invisible(lapply(required_pkgs, library, character.only = TRUE))

root_dir <- getwd()
data_dir <- file.path(root_dir,"data","raw")
fig_dir  <- file.path(root_dir,"outputs","figuras")
tab_dir  <- file.path(root_dir,"outputs","tablas")
rep_dir  <- file.path(root_dir,"outputs","reportes")

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(rep_dir, recursive = TRUE, showWarnings = FALSE)

archivo_datos <- file.path(data_dir,"datos.c7.xlsx")

if(!file.exists(archivo_datos)){
 stop("No se encontró datos.c7.xlsx en data/raw/")
}

cat("\nEntorno del Capítulo 7 configurado correctamente.\n")
