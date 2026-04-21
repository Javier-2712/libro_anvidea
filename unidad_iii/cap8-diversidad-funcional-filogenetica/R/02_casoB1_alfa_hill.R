# =========================================================
# ANVIDEA - Cap\u00edtulo 8
# Diversidad funcional y filogen\u00e9tica
# ---------------------------------------------------------
# Archivo : 02_casoB1_alfa_hill.R
# Caso    : B.1 iNEXT.3D Diversidad alfa: TD, PD y FD
# =========================================================

cat("\n========================================\n")
cat("Caso B.1 - N\u00fameros de Hill (alfa)\n")
cat("========================================\n")

# ---------------------------------------------------------
# Librer\u00edas
# ---------------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(tibble)
library(kableExtra)
library(ape)
library(FD)
library(iNEXT.3D)

# ---------------------------------------------------------
# B.1.1 Diversidad alfa taxon\u00f3mica (TD)
# ---------------------------------------------------------

# El an\u00e1lisis TD usa biol_PD construida en la secci\u00f3n B.1.2
# y se ejecuta tras construir las matrices necesarias.


# ---------------------------------------------------------
# B.1.2 Diversidad alfa filogen\u00e9tica (PD)
# ---------------------------------------------------------

# 1) Construir la matriz de abundancias (Especies \u00d7 Sitios)

biol_PD <- read_xlsx(archivo_datos, sheet = "tax") %>%
  dplyr::select(-1) %>%
  pivot_longer(-Sites1,
               names_to  = "Especies",
               values_to = "Abundancia") %>%
  group_by(Sites1, Especies) %>%
  summarise(Abundance = sum(Abundancia, na.rm = TRUE),
            .groups = "drop") %>%
  pivot_wider(names_from  = Sites1,
              values_from = Abundance,
              values_fill = 0) %>%
  tibble::column_to_rownames("Especies") %>%
  { .[rownames(.) != "Notropis aguirrepequenoi", , drop = FALSE] } %>%
  mutate(across(everything(), ~ suppressWarnings(as.numeric(.)))) %>%
  { .[, colSums(.) > 0, drop = FALSE] } %>%
  { .[rowSums(.) > 0 & !is.na(rownames(.)), , drop = FALSE] }

biol_PD %>%
  head() %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 2) Armonizar nombres y alinear con el \u00e1rbol (LatinName exacto)

.fix <- function(x) {
  x <- trimws(gsub("_", " ", x))
  x <- gsub("\\s+", " ", x)
  tolower(x)
}

arbol_filo_alfa <- readRDS(file.path(data_dir, "arbol_filo_alfa.rds"))

rownames(biol_PD)          <- .fix(rownames(biol_PD))
arbol_filo_alfa$tip.label  <- .fix(arbol_filo_alfa$tip.label)

comunes <- intersect(rownames(biol_PD), arbol_filo_alfa$tip.label)
stopifnot(length(comunes) > 0)

arbol_filo_alfa <- ape::drop.tip(arbol_filo_alfa,
                                  setdiff(arbol_filo_alfa$tip.label, comunes))
biol_PD <- biol_PD[match(arbol_filo_alfa$tip.label, rownames(biol_PD)),
                   , drop = FALSE]


# 3) C\u00e1lculo de la diversidad filogen\u00e9tica (PD)

salida_abun2 <-
  iNEXT3D(
    biol_PD,
    diversity = "PD",
    q         = c(0, 1, 2),
    datatype  = "abundance",
    nboot     = 20,
    PDtree    = arbol_filo_alfa,
    PDtype    = "meanPD"
  )


# Tabla: resumen de diversidad filogen\u00e9tica (PDInfo)
salida_abun2$PDInfo %>%
  head() %>%
  dplyr::select(1:9) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 4) Estimaciones estandarizadas de diversidad filogen\u00e9tica

salida_abun2$PDiNextEst$size_based %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 5) Diversidad filogen\u00e9tica estandarizada por cobertura muestral

salida_abun2$PDiNextEst$coverage_based %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 6) Estimaciones observadas y asint\u00f3ticas de la diversidad filogen\u00e9tica

salida_abun2$PDAsyEst %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE)


# Figuras PD

# 1. Curvas R/E por ensamblaje
fig_PD_1 <- ggiNEXT3D(salida_abun2, type = 1, facet.var = "Assemblage") +
  labs(title    = "",
       x        = "N\u00famero de individuos",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva")
print(fig_PD_1)

# 2. Curvas R/E por orden de diversidad
fig_PD_2 <- ggiNEXT3D(salida_abun2, type = 1, facet.var = "Order.q") +
  labs(title    = "",
       x        = "N\u00famero de individuos",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva")
print(fig_PD_2)

# 3. Curvas de completitud muestral
fig_PD_3 <- ggiNEXT3D(salida_abun2, type = 2, color.var = "Assemblage") +
  labs(x        = "Cobertura de la muestra",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(fig_PD_3)

# 4. Curvas R/E basadas en cobertura — por ensamblaje
fig_PD_4 <- ggiNEXT3D(salida_abun2, type = 3, facet.var = "Assemblage") +
  labs(x        = "Cobertura de la muestra",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva")
print(fig_PD_4)

# 5. Curvas R/E basadas en cobertura — por orden de diversidad
fig_PD_5 <- ggiNEXT3D(salida_abun2, type = 3, facet.var = "Order.q") +
  labs(x        = "Cobertura de la muestra",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva")
print(fig_PD_5)


# 7) Perfiles tau de diversidad filogen\u00e9tica con datos de abundancia

salida_abun2 <- ObsAsy3D(
  biol_PD,
  diversity   = "PD",
  q           = c(0, 1, 2),
  PDreftime   = seq(0.01, 400, length.out = 20),
  datatype    = "abundance",
  nboot       = 20,
  PDtree      = arbol_filo_alfa
)

salida_abun2 %>%
  head() %>%
  kbl(digits = 2, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: perfiles tau de diversidad filogen\u00e9tica
fig_PD_tau <- ggObsAsy3D(salida_abun2, profile = "time") +
  labs(x        = "Tiempo de referencia",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Ensamblaje",
       fill     = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Asint\u00f3tica", "Observada"))
print(fig_PD_tau)


# ---------------------------------------------------------
# B.1.3 Diversidad alfa funcional (FD)
# ---------------------------------------------------------

# 1) Matriz de distancias de Gower

rasgos <- read_xlsx(archivo_datos, sheet = "rasgos")

vars_cont <- c("TrophicLevel", "BodyLength", "BodyLengthMax", "ShapeFactor")
vars_bin  <- c("omnivory", "detritivory", "herbivory",
               "invertivory", "piscivory", "carnivory")

rasgos2 <- rasgos %>%
  mutate(
    across(all_of(vars_cont), as.numeric),
    across(all_of(vars_bin), ~ dplyr::case_when(
      .x %in% c("S\u00ed", "Si", "s\u00ed", "si", "yes", "TRUE", "True", "true", "1") ~ 1,
      .x %in% c("No", "no", "FALSE", "False", "false", "0", "")                    ~ 0,
      TRUE ~ suppressWarnings(as.numeric(.x))
    ))
  ) %>%
  drop_na(all_of(c(vars_cont, vars_bin))) %>%
  tibble::column_to_rownames("LatinName")

biol.dist.alfa <- FD::gowdis(rasgos2[, c(vars_cont, vars_bin)]) %>%
  as.matrix()

stopifnot(is.matrix(biol.dist.alfa), isSymmetric(biol.dist.alfa))
stopifnot(identical(rownames(biol.dist.alfa), colnames(biol.dist.alfa)))


# 2) Base de abundancia por cada zona comparada (M, P y RM)

tax <- read_xlsx(archivo_datos, sheet = "tax")
names(tax) <- str_replace(names(tax), "\\s+$", "")

site_col <- dplyr::first(intersect(
  c("Sites1", "Sites", "Sitio", "Station", "Site"), names(tax)))
stopifnot(!is.null(site_col))

biol <- tax %>%
  dplyr::rename(Site = !!site_col) %>%
  pivot_longer(cols      = where(is.numeric),
               names_to  = "Especies",
               values_to = "Abundancia") %>%
  mutate(Abundancia = suppressWarnings(as.numeric(Abundancia))) %>%
  group_by(Especies, Site) %>%
  summarise(Abundancia = sum(Abundancia, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from  = Site,
              values_from = Abundancia,
              values_fill = 0) %>%
  tibble::column_to_rownames("Especies") %>%
  as.data.frame()

stopifnot(nrow(biol) > 0, ncol(biol) > 0)

spp_keep       <- intersect(rownames(biol), rownames(biol.dist.alfa))
stopifnot(length(spp_keep) > 0)
biol           <- biol[spp_keep, , drop = FALSE]
biol.dist.alfa <- biol.dist.alfa[spp_keep, spp_keep, drop = FALSE]
biol           <- biol[rownames(biol.dist.alfa), , drop = FALSE]

biol %>%
  head() %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 3) Estimaci\u00f3n general de la diversidad funcional (FD)

set.seed(1)
salida_abun3 <- iNEXT3D(
  biol,
  diversity = "FD",
  q         = c(0, 1, 2),
  datatype  = "abundance",
  nboot     = 5,
  knots     = 20,
  endpoint  = NULL,
  FDdistM   = biol.dist.alfa,
  FDtype    = "AUC"
)

salida_abun3$FDInfo %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 4) Estimaciones estandarizadas de diversidad funcional (FD)

salida_abun3$FDiNextEst$size_based %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 5) Diversidad funcional estandarizada por cobertura muestral

salida_abun3$FDiNextEst$coverage_based %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE)


# 6) Estimaciones asint\u00f3ticas de diversidad funcional (FDAsyEst)

salida_abun3$FDAsyEst %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# Figuras FD

# 1. Curvas R/E por ensamblaje
fig_FD_1 <- ggiNEXT3D(salida_abun3, type = 1, facet.var = "Assemblage") +
  labs(title    = "",
       x        = "N\u00famero de individuos",
       y        = "Diversidad funcional (AUC)",
       color    = "Orden q",
       shape    = "Orden q",
       fill     = "Orden q",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_FD_1)

# 2. Curvas R/E por orden de diversidad
fig_FD_2 <- ggiNEXT3D(salida_abun3, type = 1, facet.var = "Order.q") +
  labs(title    = "",
       x        = "N\u00famero de individuos",
       y        = "Diversidad funcional (AUC)",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       fill     = "Ensamblaje",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_FD_2)

# 3. Curvas de completitud muestral
fig_FD_3 <- ggiNEXT3D(salida_abun3, type = 2, color.var = "Assemblage") +
  labs(title    = "",
       x        = "N\u00famero de individuos",
       y        = "Cobertura de la muestra",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       fill     = "Ensamblaje",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_FD_3)

# 4. Curvas R/E basadas en cobertura — por ensamblaje
fig_FD_4 <- ggiNEXT3D(salida_abun3, type = 3, facet.var = "Assemblage") +
  labs(title    = "",
       x        = "Cobertura de la muestra",
       y        = "Diversidad funcional (AUC)",
       color    = "Orden q",
       shape    = "Orden q",
       fill     = "Orden q",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_FD_4)

# 5. Curvas R/E basadas en cobertura — por orden de diversidad
fig_FD_5 <- ggiNEXT3D(salida_abun3, type = 3, facet.var = "Order.q") +
  labs(title    = "",
       x        = "Cobertura de la muestra",
       y        = "Diversidad funcional (AUC)",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       fill     = "Ensamblaje",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_FD_5)


# 7) Perfiles de distintividad funcional (\u03c4-profiles)

salida_abun3a <- ObsAsy3D(
  biol,
  diversity = "FD",
  q         = c(0, 1, 2),
  datatype  = "abundance",
  nboot     = 5,
  FDdistM   = biol.dist.alfa,
  FDtype    = "tau_values",
  FDtau     = seq(0, 1, 0.05)
)

salida_abun3a %>%
  head() %>%
  kbl(digits = 2, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: perfiles tau de diversidad funcional
fig_FD_tau <- ggObsAsy3D(salida_abun3a, profile = "tau") +
  labs(title    = "",
       x        = "Tau (\u03c4)",
       y        = "Diversidad funcional",
       linetype = "Tipo de estimaci\u00f3n",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       fill     = "Ensamblaje") +
  scale_linetype_discrete(labels = c("Asint\u00f3tica", "Observada"))
print(fig_FD_tau)


# 8) Estimaci\u00f3n de la diversidad funcional basada en n\u00fameros de Hill (AUC)

salida_abun3b <- ObsAsy3D(
  biol,
  diversity = "FD",
  q         = seq(0, 2, 0.5),
  datatype  = "abundance",
  nboot     = 5,
  FDdistM   = biol.dist.alfa,
  FDtype    = "AUC"
)

salida_abun3b %>%
  head() %>%
  kbl(digits = 2, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: perfil-q de diversidad funcional
fig_FD_q <- ggObsAsy3D(salida_abun3b, profile = "q") +
  labs(title    = "",
       x        = "Orden q",
       y        = "Diversidad funcional (AUC)",
       linetype = "Tipo de estimaci\u00f3n",
       color    = "Ensamblaje",
       fill     = "Ensamblaje",
       shape    = "Ensamblaje") +
  scale_linetype_discrete(labels = c("Asint\u00f3tica", "Observada"))
print(fig_FD_q)

cat("\nCaso B.1 finalizado correctamente.\n")
