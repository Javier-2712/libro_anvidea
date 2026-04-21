# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# ---------------------------------------------------------
# Archivo : 04_casoB_beta_clasica_varianza.R
# Caso    : B.1 Diversidad beta clásica y varianza
# =========================================================

cat("\n========================================\n")
cat("Caso B.1 - Diversidad beta cl\u00e1sica y varianza\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Librerías y preparación de datos
# ---------------------------------------------------------

library(knitr)
library(purrr)
library(tibble)
library(tidyverse)
library(readxl)
library(corrplot)
library(vegan)
library(ggrepel)
library(kableExtra)
library(betapart)
library(adespatial)
library(ggplot2)
library(caret)
library(factoextra)
library(gridExtra)
library(iNEXT.beta3D)
library(iNEXT)

# Cargar datos desde Excel
biol <- read_xlsx(archivo_datos, sheet = "tax")

# Nombres abreviados de los taxones
biol1 <-
  biol %>%
  dplyr::select(-1) %>%
  rename_with(~ abbreviate(.x, minlength = 4), -1)

# Agrupar por zona y sumar la abundancia de cada taxón
biol2 <-
  biol1 %>%
  group_by(Sites1) %>%
  summarise(across(everything(), \(x) sum(x, na.rm = TRUE)))

# Subconjunto ilustrativo: 3 filas x 11 columnas
biol1_head <-
  biol2 %>%
  dplyr::select(1:11) %>%
  head(4)

knitr::kable(biol1_head,
             booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 1. Diversidad beta y gamma con la propuesta de Whittaker
# ---------------------------------------------------------

# c. Diversidad gamma
(gamma.obs <- ncol(biol2[, -1]))

# Gamma estimada
gamma.est <- specpool(biol2[, -1])

gamma.est <- data.frame(
  n        = gamma.est$n,
  Riqueza  = round(gamma.est$Species, 2),
  Chao     = round(gamma.est$chao, 1),
  ee.Chao  = round(gamma.est$chao.se, 2),
  jack1    = round(gamma.est$jack1, 1),
  ee.Jack1 = round(gamma.est$jack1.se, 2),
  Boot     = round(gamma.est$boot, 1),
  de.Boot  = round(gamma.est$boot.se, 2)
)

gamma.est %>%
  kbl(digits = 0, booktabs = FALSE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# d. Diversidad alfa promedio por cada zona
alfa.est <-
  estimateR(biol2[, -1]) %>%
  as.data.frame() %>%
  setNames(c("M", "P", "RM")) %>%
  mutate(Alfa_est = rowMeans(across(c(M, P, RM))))

alfa.est %>%
  kbl(booktabs = FALSE, digits = 0) %>%
  kable_classic(full_width = FALSE)

# e. Diversidad beta
# Beta observada
beta_ob <- gamma.est$Riqueza / alfa.est$Alfa_est[1]
beta_ob

# Beta estimada con Chao y Chao1
beta_est <- gamma.est$Chao / alfa.est$Alfa_est[2]
beta_est

# f. Diversidad beta entre parejas de zonas
# 24 opciones de índices beta: betadiver(help=TRUE)

beta.j <- betadiver(biol2[, -1], "j")    # Jaccard
beta.s <- betadiver(biol2[, -1], "sor")  # S\u00f8rensen
beta.w <- betadiver(biol2[, -1], "w")    # Whittaker

mat.j <- as.matrix(beta.j)
mat.s <- as.matrix(beta.s)
mat.w <- as.matrix(beta.w)

comparaciones <- c("M_vs_P", "M_vs_RM", "P_vs_RM")

beta.est <- data.frame(
  Comparacion = comparaciones,
  Jaccard   = c(mat.j[1, 2], mat.j[1, 3], mat.j[2, 3]),
  Sorensen  = c(mat.s[1, 2], mat.s[1, 3], mat.s[2, 3]),
  Whittaker = c(mat.w[1, 2], mat.w[1, 3], mat.w[2, 3])
)

beta.est %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 2. Diversidad beta con varianza en la composición
# ---------------------------------------------------------

# a. Diversidad beta general (SCBD y LCBD)
d.beta <- beta.div(biol2[, -1],
                   method = "hellinger",
                   nperm  = 9999)
round(d.beta$beta, 2)  # SSTotal y BDTotal

# b. Contribución de las especies a la diversidad beta (SCBD)
p <- round(
  d.beta$SCBD[d.beta$SCBD >= mean(d.beta$SCBD)],
  2
)

p <-
  p %>%
  as.data.frame() %>%
  tibble::rownames_to_column(var = "Especie") %>%
  dplyr::rename(p = 2) %>%
  dplyr::arrange(p)

p <-
  p %>%
  dplyr::filter(p < 0.05)

p %>%
  kbl(booktabs  = TRUE,
      digits    = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# c. Contribución de las localidades a la diversidad beta (LCBD)
p.adjust(d.beta$p.LCBD, "holm")

# d. Visualización de las localidades y su contribución a beta

# Base de datos con todas las localidades (sin agrupar por zona)
tax <- read_xlsx(archivo_datos, "tax")

tax2 <-
  tax %>%
  dplyr::select(-1, -2) %>%
  mutate_all(~ replace_na(., 0)) %>%
  dplyr::select_if(~ sum(.) > 0) %>%
  dplyr::filter(rowSums(.) > 0)

d.beta1 <- beta.div(tax2, method = "hellinger", nperm = 999)

# Figura LCBD por coordenadas geográficas
coord <- read_xlsx(archivo_datos, "coord")
coord <- coord[, c(1, 6, 7)]
coord <- cbind(coord, LCBD = d.beta1$LCBD)

# Figura LCBD por coordenadas geográficas
fig_lcbd <- ggplot(coord,
       aes(x = Longitude, y = Latitude, label = Code)) +
  geom_point(shape = 21, fill = "brown",
             color = "#7E2D2D", aes(size = LCBD)) +
  geom_text(color = "#377eb8", size = 4, vjust = -1) +
  annotate("text", x = -99.7, y = 24.7,
           label = "Monta\u00f1as", color = "darkgreen",
           size = 4, fontface = "italic") +
  annotate("text", x = -98.4, y = 24.24,
           label = "planicies", color = "darkgreen",
           size = 4, fontface = "italic") +
  annotate("text", x = -97.8, y = 23.95,
           label = "Desembocadura", color = "darkgreen",
           size = 4, fontface = "italic") +
  annotate("text", x = -97.909, y = 23.735,
           label = "***", color = "darkred",
           size = 4, fontface = "italic") +
  annotate("text", x = -97.737, y = 23.717,
           label = "***", color = "darkred",
           size = 4, fontface = "italic") +
  labs(title = "Valores LCBD",
       x     = "Coordenadas x",
       y     = "Coordenadas y") +
  xlim(-99.8, -97.5) +
  ylim(23.7, 24.7) +
  scale_size_continuous(range = c(3, 8)) +
  geom_path(data  = coord,
            aes(x = Longitude, y = Latitude),
            color = "light blue") +
  theme_bw() +
  theme(plot.title  = element_text(hjust = 0.5),
        panel.grid  = element_blank(),
        axis.title  = element_text(size = 14))
print(fig_lcbd)

cat("\nCaso B.1 finalizado correctamente.\n")
