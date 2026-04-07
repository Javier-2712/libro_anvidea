# =========================================================
# ANDIVEA - Unidad III
# Capítulo 7 - Diversidad taxonómica (TD)
# Caso B: Diversidad alfa y Hill
# Propósito: Caso guiado de diversidad beta y gamma con peces de Máxico
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

biol <- readxl::read_xlsx(file.path(data_dir,"datos.c7.xlsx"), sheet="tax")

biol_sit <- biol %>%
  dplyr::group_by(Sites1) %>%
  dplyr::summarise(across(where(is.numeric), sum, na.rm=TRUE))

mat <- biol_sit %>% dplyr::select(-Sites1) %>% as.matrix()
rownames(mat) <- biol_sit$Sites1

# beta
beta_j <- vegan::vegdist(mat, method="jaccard")
guardar_tabla_excel(as.data.frame(as.matrix(beta_j)),"beta_jaccard.xlsx")

# LCBD
res <- adespatial::beta.div(mat)
lcbd <- data.frame(Sitio=rownames(mat), LCBD=res$LCBD)

guardar_tabla_excel(lcbd,"lcbd.xlsx")