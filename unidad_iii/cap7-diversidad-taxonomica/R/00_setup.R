# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# =========================================================

required_pkgs <- c(
  "tidyverse","readxl","writexl","vegan",
  "ggrepel","viridis",
  "iNEXT","iNEXT.4steps","iNEXT.3D","iNEXTbeta3D",
  "adespatial","betapart"
)

missing_pkgs <- required_pkgs[
  !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
]

if(length(missing_pkgs)>0){
  stop("Instala estos paquetes: ", paste(missing_pkgs, collapse=", "))
}

invisible(lapply(required_pkgs, library, character.only = TRUE))

if(!dir.exists("outputs/figuras")) dir.create("outputs/figuras", recursive = TRUE)
if(!dir.exists("outputs/tablas")) dir.create("outputs/tablas", recursive = TRUE)

root_dir <- getwd()
data_dir <- file.path(root_dir,"data","raw")