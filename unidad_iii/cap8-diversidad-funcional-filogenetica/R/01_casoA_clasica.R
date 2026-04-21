# =========================================================
# ANVIDEA - Capítulo 8
# Diversidad funcional y filogenética
# ---------------------------------------------------------
# Archivo : 01_casoA_clasica.R
# Caso    : A. Propuestas clásicas de diversidad funcional
#           y filogenética
# =========================================================

cat("\n========================================\n")
cat("Caso A - Diversidad funcional y filogenética clásica\n")
cat("========================================\n")

# ---------------------------------------------------------
# Librerías requeridas
# ---------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(writexl)
  library(kableExtra)
  library(FD)
  library(factoextra)
  library(ggplot2)
  library(RColorBrewer)
  library(ggrepel)
  library(ape)
  library(taxize)
  library(vegan)
})

# ---------------------------------------------------------
# 2. Organización de los datos
# ---------------------------------------------------------

# 2.1 Datos taxonómicos (biol1)
taxas <- read_xlsx(archivo_datos, sheet = "tax")

biol1 <-
  taxas %>%
  dplyr::select(-1, -2) %>%
  rename_with(~ abbreviate(.x, minlength = 4))

biol1 %>%
  head(4) %>%
  dplyr::select(1:10) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 2.2 Datos funcionales (rasgos1)
rasgos <- read_xlsx(archivo_datos, sheet = "rasgos") %>%
  as.data.frame()

rownames(rasgos) <- make.names(rasgos[[1]], unique = TRUE)
rasgos <- rasgos[, -1, drop = FALSE]
rasgos1 <- rasgos[, 5:14, drop = FALSE]

head(rasgos1, 4) %>%
  dplyr::select(1:7) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 2.3 Coordenadas de las localidades (coord)
coord <- read_xlsx(archivo_datos, sheet = "coord") %>%
  dplyr::select(6, 7) %>%
  dplyr::rename(x = Longitude, y = Latitude)

head(coord, 4) %>%
  kbl(booktabs = TRUE, digits = 3, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# A.1 Diversidad alfa funcional - enfoque de marco flexible
# ---------------------------------------------------------

# CWM por sitio
d.func1 <- functcomp(rasgos1, as.matrix(biol1), CWM.type = "all")

head(d.func1, 4) %>%
  dplyr::select(1:6) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 1) Diversidad funcional alfa con la función dbFD()
res <- dbFD(
  rasgos1,
  as.matrix(biol1),
  asym.bin   = 5:10,
  stand.FRic = TRUE,
  corr       = "cailliez",
  CWM.type   = "all",
  calc.FDiv  = TRUE,
  calc.FGR   = FALSE,
  messages   = FALSE
)

df_FD <- tibble(
  Sitio = rownames(biol1),
  FRic  = as.numeric(res$FRic),
  FEve  = as.numeric(res$FEve),
  FDiv  = as.numeric(res$FDiv),
  FDis  = as.numeric(res$FDis),
  RaoQ  = as.numeric(res$RaoQ)
)

df_FD %>%
  head(8) %>%
  kbl(digits = 2, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 2) Clasificación de especies por sus estrategias funcionales

d_trait <- gowdis(rasgos1, asym.bin = 5:10)
hc      <- hclust(d_trait, method = "ward.D2")
grp     <- cutree(hc, k = 3)

hc$labels <- hc$labels %>%
  stringr::str_replace_all("_", " ") %>%
  stringr::str_squish()

p_dend <- factoextra::fviz_dend(
  hc,
  k        = 3,
  cex      = 0.55,
  lwd      = 0.7,
  k_colors = brewer.pal(3, "Dark2"),
  rect     = FALSE,
  horiz    = FALSE,
  main     = "Dendrograma funcional de especies",
  ylab     = "Distancia funcional (Ward.D2)",
  xlab     = ""
) +
  theme_classic(base_size = 14) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    panel.grid       = element_blank(),
    axis.text.x = element_text(size = 10, angle = 90, vjust = 0.5, hjust = 1),
    axis.text.y = element_text(size = 10),
    plot.title  = element_text(face = "bold", size = 15, hjust = 0.5)
  )
print(p_dend)
guardar_figura(p_dend, "casoA_fig_dendrograma_funcional.png", width = 10, height = 5)

# Clasificación no jerárquica en espacio funcional (k-medias)

d_gow <- gowdis(rasgos1)
pc    <- ape::pcoa(as.matrix(d_gow), correction = "cailliez")

var1 <- round(100 * pc$values$Rel_corr_eig[1], 1)
var2 <- round(100 * pc$values$Rel_corr_eig[2], 1)

X <- as.data.frame(pc$vectors[, 1:2, drop = FALSE])
colnames(X) <- c("PCoA1", "PCoA2")
X$Especie   <- rownames(X)
X$Abrev     <- abbreviate(
  stringr::str_squish(stringr::str_replace_all(X$Especie, "_", " ")),
  minlength = 6,
  strict    = TRUE
)

set.seed(123)
km3       <- kmeans(scale(X[, c("PCoA1", "PCoA2")]), centers = 3, nstart = 50)
X$cluster <- factor(km3$cluster)

p_kmeans <- ggplot(X, aes(PCoA1, PCoA2, color = cluster, label = Abrev)) +
  stat_ellipse(type = "norm", level = 0.68,
               linewidth = 0.7, alpha = 0.12, show.legend = FALSE) +
  geom_point(size = 2.1, show.legend = TRUE) +
  ggrepel::geom_text_repel(size = 3.2, max.overlaps = 100, show.legend = FALSE) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Clúster k-medias en el espacio funcional (PCoA)",
    x     = paste0("PCoA1 (", var1, "%)"),
    y     = paste0("PCoA2 (", var2, "%)"),
    color = "cluster"
  ) +
  theme_classic(base_size = 13) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    legend.position  = "bottom",
    plot.title       = element_text(face = "bold", hjust = 0.5)
  )
print(p_kmeans)
guardar_figura(p_kmeans, "casoA_fig_kmeans_pcoa.png", width = 9, height = 7)

grupos_k3 <- X %>%
  dplyr::select(Especie, Abrev, cluster) %>%
  arrange(cluster, Especie)


# 3) Clasificación de sitios por su diversidad funcional
# Se guardan dos figuras PNG para el reporte: FRic y FDis por sitio

png(file.path(fig_dir, "fig_01_FRic_por_sitio.png"),
    width = 900, height = 700, res = 120)
par(mar = c(4.5, 4.5, 3, 1), cex.axis = 0.9, cex.lab = 1.2, cex.main = 1.1)
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FRic * 5, main = "Riqueza funcional (FRic) por sitio",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
dev.off()

png(file.path(fig_dir, "fig_02_FDis_por_sitio.png"),
    width = 900, height = 700, res = 120)
par(mar = c(4.5, 4.5, 3, 1), cex.axis = 0.9, cex.lab = 1.2, cex.main = 1.1)
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FDis * 1.5, main = "Dispersión funcional (FDis) por sitio",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
dev.off()

# Panel completo — guardado como PNG para el reporte
png(file.path(fig_dir, "casoA_fig_panel_FD_sitios.png"),
    width = 1200, height = 1600, res = 120)
par(
  mfrow    = c(3, 2),
  mar      = c(4.5, 4.5, 3, 1),
  oma      = c(0, 0, 0, 0),
  cex.axis = 0.9,
  cex.lab  = 1.2,
  cex.main = 1.1
)
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FRic * 5, main = "3a) Riqueza funcional (FRic)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FEve * 6, main = "3a) Equidad funcional (FEve)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FDiv * 5, main = "3b) Divergencia funcional (FDiv)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FDis * 1.5, main = "3b) Dispersión funcional (FDis)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$RaoQ / 2, main = "3c) Entropía cuadrática de Rao (RaoQ)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FGR / 2, main = "3c) Riqueza de grupos funcionales (FGR)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
dev.off()

# Panel para visualización interactiva
dev.new(width = 10, height = 13)
par(
  mfrow    = c(3, 2),
  mar      = c(4.5, 4.5, 3, 1),
  oma      = c(0, 0, 0, 0),
  cex.axis = 0.9,
  cex.lab  = 1.2,
  cex.main = 1.1
)

plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FRic * 5, main = "3a) Riqueza funcional (FRic)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FEve * 6, main = "3a) Equidad funcional (FEve)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FDiv * 5, main = "3b) Divergencia funcional (FDiv)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FDis * 1.5, main = "3b) Dispersión funcional (FDis)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$RaoQ / 2, main = "3c) Entropía cuadrática de Rao (RaoQ)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, cex.axis = 0.8, col = "white", bg = "brown",
     cex = res$FGR / 2, main = "3c) Riqueza de grupos funcionales (FGR)",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

dev.off()


# 4) Relación entre la diversidad alfa taxonómica y funcional

N0   <- specnumber(biol1)
H    <- diversity(biol1)
Hb2  <- diversity(biol1, base = 2)
N1   <- exp(H)
N1b2 <- 2^Hb2
N2   <- diversity(biol1, "inv")
J    <- H / log(N0)
E10  <- N1 / N0
E20  <- N2 / N0

div <- data.frame(N0, H, Hb2, N1, N1b2, N2, E10, E20, J)
div$FRic <- res$FRic
div$FEve <- res$FEve
div$FDiv <- res$FDiv
div$FDis <- res$FDis
div$RaoQ <- res$RaoQ
div$FGR  <- res$FGR
div <- data.frame(Sitios = taxas$Sites, div)

head(div, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# A.2 Diversidad taxonómica, funcional y filogenética
#     enfoque de entropía cuadrática de Rao
# ---------------------------------------------------------

# Lógica idéntica al libro (script 01_sript_casoA_clasica.qmd).
# Se usa Rao.R original (no 06_Rao.R) y se pasa t(biol2).

# 1) Organización de la matriz de rasgos (rasgos2)
rasgos_raw <- read_xlsx(archivo_datos, sheet = "rasgos") %>%
  as.data.frame()
rownames(rasgos_raw) <- make.names(rasgos_raw[[1]], unique = TRUE)
rasgos2 <- rasgos_raw[, 5:14, drop = FALSE]

rasgos2 %>%
  head(4) %>%
  dplyr::select(1:6) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 2) Identificación de especies problemáticas mediante NCBI
splist <- as.character(rasgos_raw$LatinName)
quiet  <- function(x) suppressWarnings(suppressMessages(x))
spcla  <- quiet(classification(splist, db = "ncbi"))

no_encontradas       <- names(spcla)[
  vapply(spcla, function(x) is.null(x) || all(is.na(x)), logical(1))
]
no_encontradas_abrev <- abbreviate(no_encontradas, minlength = 4)
if (length(no_encontradas_abrev) > 0) print(no_encontradas_abrev)


# 4) Filtrar biol2 y rasgos2 con exclusión de no encontradas
biol2 <-
  biol1 %>%
  dplyr::select(-any_of(no_encontradas_abrev)) %>%
  mutate(across(everything(), ~ suppressWarnings(as.numeric(.)))) %>%
  mutate(across(everything(), ~ tidyr::replace_na(., 0))) %>%
  as.matrix()

rasgos2 <- rasgos2[
  !(rownames(rasgos2) %in% no_encontradas_abrev),
  , drop = FALSE
]

rasgos2 %>%
  head(4) %>%
  dplyr::select(1:6) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 5) Matriz de distancia filogenética (phylo.d) — idéntico al libro
tr      <- class2tree(spcla)
phylo.d <- cophenetic(tr$phylo) / 100
rownames(phylo.d) <- colnames(biol2)
colnames(phylo.d) <- colnames(biol2)

phylo.d[1:10, 1:10] %>%
  kbl(digits = 3, booktabs = TRUE) %>%
  kable_classic(full_width = FALSE)


# 6) Matriz de distancia funcional de Gower (rasgos.d)
vars_bin  <- c("omnivory", "detritivory", "herbivory", "invertivory", "piscivory")
asym_idx  <- match(vars_bin, colnames(rasgos2))
rasgos.d  <- gowdis(rasgos2, asym.bin = asym_idx)
rasgos.gw <- hclust(rasgos.d, method = "ward.D2")

as.data.frame(as.matrix(rasgos.d)) %>%
  head(8) %>%
  dplyr::select(1:8) %>%
  kbl(digits = 3, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 7) Partición aditiva de la diversidad (TD, PD, FD)
# Usa Rao.R del libro: espera especies × sitios → se pasa t(biol2)
source(file.path(data_dir, "Rao.R"))

biol1.rao <- Rao(
  sample = t(biol2),
  dfunc  = rasgos.d,
  dphyl  = phylo.d,
  weight = FALSE,
  Jost   = TRUE
)

div_resumen <- tibble(
  Sitio  = rownames(biol1),
  alfaTD = biol1.rao$TD$Alpha,
  alfaPD = biol1.rao$PD$Alpha,
  alfaFD = biol1.rao$FD$Alpha
)

div_resumen %>%
  head() %>%
  kbl(digits = 3, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# 7) Tabulación y visualización con partición aditiva

biol1.rao$TD$Mean_Alpha
biol1.rao$TD$Gamma
biol1.rao$TD$Beta_add
biol1.rao$TD$Gamma - biol1.rao$TD$Mean_Alpha
biol1.rao$TD$Beta_prop
biol1.rao$TD$Beta_add / biol1.rao$TD$Gamma
biol1.rao$TD$Gamma   / biol1.rao$TD$Mean_Alpha

biol1.rao$PD$Mean_Alpha
biol1.rao$PD$Gamma
biol1.rao$PD$Beta_add
biol1.rao$PD$Gamma - biol1.rao$PD$Mean_Alpha
biol1.rao$PD$Beta_prop
biol1.rao$PD$Beta_add / biol1.rao$PD$Gamma
biol1.rao$PD$Gamma   / biol1.rao$PD$Mean_Alpha

biol1.rao$FD$Mean_Alpha
biol1.rao$FD$Gamma
biol1.rao$FD$Beta_add
biol1.rao$FD$Gamma - biol1.rao$FD$Mean_Alpha
biol1.rao$FD$Beta_prop
biol1.rao$FD$Beta_add / biol1.rao$FD$Gamma
biol1.rao$FD$Gamma   / biol1.rao$FD$Mean_Alpha

div$alfaTD <- biol1.rao$TD$Alpha
div$alfaPD <- biol1.rao$PD$Alpha
div$alfaFD <- biol1.rao$FD$Alpha

head(div, 4) %>%
  dplyr::select(1:14) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Panel TD/PD/FD — guardado como PNG para el reporte
png(file.path(fig_dir, "casoA_fig_panel_TD_PD_FD.png"),
    width = 1100, height = 900, res = 120)
par(
  mfrow    = c(2, 2),
  mar      = c(4.5, 4.5, 3, 1),
  oma      = c(0, 0, 0, 0),
  cex.axis = 0.9,
  cex.lab  = 1.0,
  cex.main = 1.1
)
plot(coord, asp = 1, pch = 21, col = "white", bg = "brown",
     cex  = biol1.rao$TD$Alpha / 4,
     main = "Diversidad Taxonómica",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, col = "white", bg = "brown",
     cex  = biol1.rao$PD$Alpha * 1.5,
     main = "Diversidad Filogenética",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
plot(coord, asp = 1, pch = 21, col = "white", bg = "brown",
     cex  = biol1.rao$FD$Alpha * 2.5,
     main = "Diversidad Funcional",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")
dev.off()

# Figura: diversidad alfa TD, PD y FD por coordenadas
dev.new(width = 10, height = 10)
par(
  mfrow    = c(2, 2),
  mar      = c(4.5, 4.5, 3, 1),
  oma      = c(0, 0, 0, 0),
  cex.axis = 0.9,
  cex.lab  = 1.0,
  cex.main = 1.1
)

plot(coord, asp = 1, pch = 21, col = "white", bg = "brown",
     cex  = biol1.rao$TD$Alpha / 4,
     main = "Diversidad Taxonómica",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, col = "white", bg = "brown",
     cex  = biol1.rao$PD$Alpha * 1.5,
     main = "Diversidad Filogenética",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

plot(coord, asp = 1, pch = 21, col = "white", bg = "brown",
     cex  = biol1.rao$FD$Alpha * 2.5,
     main = "Diversidad Funcional",
     xlab = "Coordenadas x (km)", ylab = "Coordenadas y (km)")
lines(coord, col = "light blue")

dev.off()

# ---------------------------------------------------------
# Objetos nombrados para 07_guardar_salidas_cap8.R
# ---------------------------------------------------------

tabla_fd_indices <- df_FD
cwm              <- d.func1
abund_site       <- biol1
fd_alpha         <- res
biol_zona        <- biol1
fd_dist          <- as.matrix(gowdis(rasgos1))
pd_dist          <- phylo.d
rao_out          <- biol1.rao
coord_sitios     <- coord
div_completo     <- div
div_rao_resumen  <- div_resumen
grupos_funcionales <- grupos_k3

tabla_rao_fd <- tibble(
  Componente = c("Mean_Alpha", "Gamma", "Beta_add", "Beta_prop"),
  Valor      = c(biol1.rao$FD$Mean_Alpha,
                 biol1.rao$FD$Gamma,
                 biol1.rao$FD$Beta_add,
                 biol1.rao$FD$Beta_prop)
)

tabla_rao_pd <- tibble(
  Componente = c("Mean_Alpha", "Gamma", "Beta_add", "Beta_prop"),
  Valor      = c(biol1.rao$PD$Mean_Alpha,
                 biol1.rao$PD$Gamma,
                 biol1.rao$PD$Beta_add,
                 biol1.rao$PD$Beta_prop)
)

cat("\nCaso A finalizado correctamente.\n")
