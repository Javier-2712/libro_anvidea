# =========================================================
# ANDIVEA - Unidad III
# Capítulo 7 - Diversidad taxonómica (TD)
# Caso A: Diversidad alfa y Hill
# Propósito: Caso guiado de diversidad alfa con peces de Máxico
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

biol <- readxl::read_xlsx(file.path(data_dir,"datos.c7.xlsx"), sheet="tax")

# Matriz por zonas
biol_sit <- biol %>%
  dplyr::group_by(Sites1) %>%
  dplyr::summarise(across(where(is.numeric), sum, na.rm=TRUE)) %>%
  tidyr::pivot_longer(-Sites1, names_to="sp", values_to="ab") %>%
  tidyr::pivot_wider(names_from=Sites1, values_from=ab, values_fill=0)

# formato zona × especie
biol_zona <- biol_sit %>%
  tibble::column_to_rownames("sp") %>%
  as.matrix() %>% t()

# diversidad
N0 <- vegan::specnumber(biol_zona)
H  <- vegan::diversity(biol_zona)
N1 <- exp(H)
N2 <- 1/vegan::diversity(biol_zona,"simpson")

tabla <- data.frame(
  Zona = rownames(biol_zona),
  q0 = N0,
  q1 = N1,
  q2 = N2
)

guardar_tabla_excel(tabla,"tabla_alfa.xlsx")

# RAD simple
rad <- sort(colSums(biol_zona), decreasing=TRUE)
df <- data.frame(rango=1:length(rad), abund=rad/sum(rad))

p <- ggplot2::ggplot(df, ggplot2::aes(rango, abund))+
  ggplot2::geom_point()+
  ggplot2::scale_y_log10()+
  ggplot2::theme_bw()

guardar_figura(p,"rad.png")