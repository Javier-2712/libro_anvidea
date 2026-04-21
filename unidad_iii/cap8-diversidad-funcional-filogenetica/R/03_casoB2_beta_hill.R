# =========================================================
# ANVIDEA - Cap\u00edtulo 8
# Diversidad funcional y filogen\u00e9tica
# ---------------------------------------------------------
# Archivo : 03_casoB2_beta_hill.R
# Caso    : B.2 iNEXTbeta.3D Diversidad beta: TD, PD y FD
# =========================================================

cat("\n========================================\n")
cat("Caso B.2 - N\u00fameros de Hill (beta)\n")
cat("========================================\n")

# ---------------------------------------------------------
# Librer\u00edas
# ---------------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(purrr)
library(tibble)
library(stringr)
library(ape)
library(FD)
library(kableExtra)
library(ggplot2)
library(iNEXT.3D)
library(iNEXT.beta3D)

# ---------------------------------------------------------
# B.2.1 Diversidad beta taxon\u00f3mica (TD)
# ---------------------------------------------------------

# El an\u00e1lisis TD beta usa los mismos pares de abundancias
# construidos en la secci\u00f3n B.2.2 (PD).


# ---------------------------------------------------------
# B.2.2 Diversidad beta filogen\u00e9tica (PD)
# ---------------------------------------------------------

# 1) Construir la matriz de abundancias (Especies x Sitios)

arbol_filo_beta <- readRDS(file.path(data_dir, "arbol_filo_beta.rds"))
stopifnot(inherits(arbol_filo_beta, "phylo"))
arbol_beta <- arbol_filo_beta

biol <- read_xlsx(archivo_datos, sheet = "tax") %>%
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
  as.data.frame()

biol <- biol[rownames(biol) != "Notropis aguirrepequenoi", , drop = FALSE]

# Tres pares (M_vs_P, M_vs_RM, P_vs_RM)
stopifnot(all(c("M", "P", "RM") %in% colnames(biol)))

biol_PD_beta <- list(
  M_vs_P  = biol[, c("M", "P"),  drop = FALSE],
  M_vs_RM = biol[, c("M", "RM"), drop = FALSE],
  P_vs_RM = biol[, c("P", "RM"), drop = FALSE]
)

tax1 <- read_xlsx(archivo_datos, sheet = "tax1") %>%
  dplyr::select(Abbrev = 1, LatinName = 2)

# 1.2 Alineaci\u00f3n autom\u00e1tica con alineador.R
source(file.path("R", "05_alineador.R"))

ali <- alinear_beta(biol_PD_beta, arbol_beta, tax1 = tax1)

biol_PD <- ali$pairs_aligned
arbol_PD <- ali$tree_aligned
ali$report


# 1.3 Diversidad beta filogen\u00e9tica (PD) basada en coberturas

salida.abun21 <- iNEXTbeta3D(
  biol_PD,
  diversity = "PD",
  PDtree    = arbol_PD,
  datatype  = "abundance",
  base      = "coverage",
  nboot     = 10,
  PDreftime = NULL,
  PDtype    = "meanPD"
)

# Tabla: gamma M_vs_P por cobertura
salida.abun21$M_vs_P$gamma %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: curvas R/E por cobertura
fig_PD_beta_cov <- ggiNEXTbeta3D(salida.abun21, type = "B") +
  labs(title    = "",
       x        = "Cobertura de la muestra",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Comparaci\u00f3n",
       shape    = "Comparaci\u00f3n",
       fill     = "Comparaci\u00f3n",
       linetype = "Tipo de curva") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_PD_beta_cov)


# 1.5 Diversidad beta filogen\u00e9tica (PD) por tama\u00f1o de las muestras

salida.abun22 <- iNEXTbeta3D(
  biol_PD,
  diversity = "PD",
  PDtree    = arbol_PD,
  datatype  = "abundance",
  base      = "size",
  nboot     = 10,
  PDreftime = NULL,
  PDtype    = "meanPD"
)

# Tabla: gamma M_vs_P por tama\u00f1o
salida.abun22$M_vs_P$gamma %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: curvas R/E por tama\u00f1o de muestra
fig_PD_beta_size <- ggiNEXTbeta3D(salida.abun22) +
  labs(x        = "N\u00famero de individuos",
       y        = "Diversidad filogen\u00e9tica media",
       color    = "Comparaci\u00f3n",
       shape    = "Comparaci\u00f3n",
       linetype = "Tipo de curva") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  scale_color_discrete(labels = c("M vs. P", "M vs. RM", "P vs. RM")) +
  scale_shape_discrete(labels  = c("M vs. P", "M vs. RM", "P vs. RM"))
print(fig_PD_beta_size)


# 2) Informaci\u00f3n general de la diversidad beta filogen\u00e9tica (PD)

informacion_gral_PD <- DataInfobeta3D(
  data      = biol_PD,
  diversity = "PD",
  datatype  = "abundance",
  PDtree    = arbol_PD,
  PDreftime = NULL
)

informacion_gral_PD %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# B.2.3 Diversidad beta funcional (FD)
# ---------------------------------------------------------

# 1) Construir la matriz de abundancias (Especies x Sitios)

biol_raw <- read_xlsx(archivo_datos, sheet = "tax")
names(biol_raw) <- str_replace(names(biol_raw), "\\s+$", "")

site_col <- intersect(c("Sites1", "Sites", "Sitio", "Station", "Site"),
                      names(biol_raw)) %>% dplyr::first()
stopifnot(!is.null(site_col))

biol <- biol_raw %>%
  dplyr::rename(Site = !!site_col) %>%
  pivot_longer(cols      = where(is.numeric),
               names_to  = "Especies",
               values_to = "Abundancia") %>%
  mutate(Abundancia = as.numeric(Abundancia)) %>%
  group_by(Especies, Site) %>%
  summarise(Abundancia = sum(Abundancia, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from  = Site,
              values_from = Abundancia,
              values_fill = 0) %>%
  tibble::column_to_rownames("Especies") %>%
  as.data.frame()

biol %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 2) Armar los pares de sitios para beta-FD

sitios <- c("M", "P", "RM")
stopifnot(all(sitios %in% colnames(biol)))

nombres_pares <- combn(sitios, 2, FUN = \(p) paste(p, collapse = "_vs_"))
biol_FD_beta <- combn(sitios, 2, simplify = FALSE) %>%
  set_names(nombres_pares) %>%
  map(\(p) biol[, p, drop = FALSE])


# 3) Preparar rasgos funcionales

rasgos <- read_xlsx(archivo_datos, sheet = "rasgos") %>%
  mutate(
    across(c(TrophicLevel, BodyLength, BodyLengthMax, ShapeFactor), as.numeric),
    across(c(omnivory, detritivory, herbivory, invertivory, piscivory, carnivory),
           ~ dplyr::case_when(
             .x %in% c("S\u00ed", "Si", "yes", "TRUE", "True", "true", "1") ~ 1,
             .x %in% c("No", "no", "FALSE", "False", "false", "0", "")      ~ 0,
             TRUE ~ as.numeric(.x)
           ))
  ) %>%
  drop_na(TrophicLevel:carnivory) %>%
  tibble::column_to_rownames("LatinName")


# 4) Distancias funcionales (Gower)

biol.dist.beta <- gowdis(rasgos) %>% as.matrix()


# 5) Alinear abundancias con rasgos

pares_sp   <- unique(unlist(lapply(biol_FD_beta, rownames)))
alinear_sp <- intersect(pares_sp, rownames(biol.dist.beta))
stopifnot(length(alinear_sp) > 0)

biol.dist.beta <- biol.dist.beta[alinear_sp, alinear_sp, drop = FALSE]

relleno_sp <- function(X, ref_sp) {
  X       <- as.data.frame(X)
  missing <- setdiff(ref_sp, rownames(X))
  if (length(missing)) {
    X <- rbind(
      X,
      matrix(0, nrow = length(missing), ncol = ncol(X),
             dimnames = list(missing, colnames(X)))
    )
  }
  X     <- X[ref_sp, , drop = FALSE]
  X[]   <- lapply(X, \(v) suppressWarnings(as.numeric(v)))
  as.matrix(X)
}

biol_FD_beta <- map(biol_FD_beta, relleno_sp, ref_sp = alinear_sp)


# 6) Chequeos de consistencia

stopifnot(is.matrix(biol.dist.beta), isSymmetric(biol.dist.beta))
stopifnot(identical(rownames(biol.dist.beta), colnames(biol.dist.beta)))
stopifnot(all(map_lgl(biol_FD_beta, \(m) identical(rownames(m), alinear_sp))))


# 7) Diversidad beta funcional FD mediante R/E basada en cobertura

salida_abun31 <- iNEXTbeta3D(
  data         = biol_FD_beta,
  diversity    = "FD",
  datatype     = "abundance",
  base         = "coverage",
  nboot        = 5,
  FDdistM      = biol.dist.beta,
  FDtype       = "AUC",
  FDcut_number = 30
)

# Tabla: gamma M_vs_P por cobertura
salida_abun31$M_vs_P$gamma %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: curvas R/E FD basadas en cobertura
fig_FD_beta_cov <- ggiNEXTbeta3D(salida_abun31, type = "B") +
  labs(title    = "",
       x        = "Cobertura de la muestra",
       y        = "Diversidad funcional (AUC)",
       color    = "Comparaci\u00f3n",
       fill     = "Comparaci\u00f3n",
       shape    = "Comparaci\u00f3n",
       linetype = "Tipo de curva") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n"))
print(fig_FD_beta_cov)


# 8) Curvas R/E basadas en tama\u00f1o de muestra (FD gamma y alfa)

salida_abun32 <- iNEXTbeta3D(
  data         = biol_FD_beta,
  diversity    = "FD",
  datatype     = "abundance",
  base         = "size",
  nboot        = 2,
  FDdistM      = biol.dist.beta,
  FDtype       = "AUC",
  FDcut_number = 10
)

# Tabla: gamma M_vs_P por tama\u00f1o
salida_abun32$M_vs_P$gamma %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura: curvas R/E FD basadas en tama\u00f1o
fig_FD_beta_size <- ggiNEXTbeta3D(salida_abun32) +
  labs(x        = "N\u00famero de individuos",
       y        = "Diversidad funcional (AUC)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_linetype_discrete(name   = "",
                          labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  scale_shape_discrete(name     = "",
                       labels   = c("M_vs_P", "M_vs_RM", "P_vs_RM")) +
  scale_color_discrete(name     = "",
                       labels   = c("M_vs_P", "M_vs_RM", "P_vs_RM"))
print(fig_FD_beta_size)


# 9) Informaci\u00f3n general de la diversidad beta funcional FD

# tau_value
informacion_gral_FD <- DataInfobeta3D(
  data      = biol_FD_beta,
  diversity = "FD",
  datatype  = "abundance",
  FDdistM   = biol.dist.beta,
  FDtype    = "tau_value",
  FDtau     = NULL
)

informacion_gral_FD %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# AUC
informacion_gral_FD1 <- DataInfobeta3D(
  data      = biol_FD_beta,
  diversity = "FD",
  datatype  = "abundance",
  FDdistM   = biol.dist.beta,
  FDtype    = "AUC",
  FDtau     = NULL
)

informacion_gral_FD1 %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

cat("\nCaso B.2 finalizado correctamente.\n")
