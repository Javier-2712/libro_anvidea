# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# ---------------------------------------------------------
# Archivo : 06_casoB_beta_hill.R
# Caso    : B.3 Diversidad beta con n\u00fameros de Hill
# =========================================================

cat("\n========================================\n")
cat("Caso B.3 - Diversidad beta (n\u00fameros de Hill)\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 4) Diversidad beta con estandarización de muestras
#         y números efectivos q = 0, 1 y 2
# ---------------------------------------------------------

library(tidyverse)
library(readxl)
library(kableExtra)
library(iNEXT)
library(iNEXT.beta3D)

# ---- a. Organización de los datos ----

# biol: matriz Especies x Sitio (columnas = sitios, filas = especies)
biol <-
  read_xlsx(archivo_datos, sheet = "tax")

biol <-
  biol %>%
  dplyr::select(-1) %>%
  rename_with(~ abbreviate(.x, minlength = 4), -Sites1) %>%
  pivot_longer(-Sites1,
               names_to  = "Especies",
               values_to = "Abundancia") %>%
  group_by(Sites1, Especies) %>%
  summarise(Abundance = sum(Abundancia, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from  = Sites1,
              values_from = Abundance,
              values_fill = 0)

biol %>%
  head() %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---- b. Componente de diversidad alfa ----

biol <- as.data.frame(biol)

result_b3 <- iNEXT(biol[, -1], q = 0, datatype = "abundance")

result_b3 <- result_b3$DataInfo[, c(1:3, 5, 6)]
colnames(result_b3) <- c("Sitio", "N", "Riqueza", "f1", "f2")

result_b3 %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---- c. Organización de los datos por parejas de zonas ----

biol1 <- as.data.frame(biol)
rownames(biol1) <- biol1$Especies
biol1$Especies  <- NULL

sitios <- colnames(biol1)
pares  <- combn(sitios, 2, simplify = FALSE)

biol.pares <- setNames(
  lapply(pares, function(p) biol1[, p, drop = FALSE]),
  sapply(pares, function(p) paste(p, collapse = "_vs_"))
)

head(biol.pares$M_vs_P) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Diversidad con abundancia basada en cobertura — R/E Analysis
diversidad_abun_cov <- iNEXTbeta3D(
  data      = biol.pares,
  diversity = "TD",
  datatype  = "abundance",
  base      = "coverage",
  nboot     = 10
)

head(diversidad_abun_cov$M_vs_P$beta, 4) %>%
  kbl(booktabs = TRUE, digits = 3) %>%
  kable_classic(full_width = FALSE)


# ---- d. Componentes gamma y alfa por parejas de zonas ----

diversidad_abun <- iNEXTbeta3D(
  data      = biol.pares,
  diversity = "TD",
  datatype  = "abundance",
  base      = "size",
  nboot     = 10
)

ggiNEXTbeta3D(diversidad_abun) +
  labs(
    x        = "N\u00famero de individuos",
    y        = "Diversidad taxon\u00f3mica",
    title    = "(a) Rarefacci\u00f3n basada en el tama\u00f1o de la muestra y extrapolaci\u00f3n 2n",
    subtitle = paste(
      "Comparaci\u00f3n de las parejas de zonas M_vs_P, M_vs_RM, P_vs_RM",
      "\u25b2 Gamma (tama\u00f1o 2n)  \u25cf Gamma (tama\u00f1o n)  \u25b3 Alfa (tama\u00f1o 2n)  \u25cb Alfa (tama\u00f1o n)",
      sep = "\n"
    )
  ) +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() +
  theme(
    axis.title       = element_text(size = 11, face = "bold"),
    strip.text       = element_text(face = "bold"),
    axis.text        = element_text(size = 10),
    plot.title       = element_text(size = 13, face = "bold", colour = "blue4"),
    panel.grid       = element_blank(),
    legend.position  = "bottom",
    legend.box       = "vertical",
    legend.title     = element_blank(),
    plot.margin      = margin(8, 10, 8, 8)
  )


# ---- e. Gamma, alfa y beta con estandarización por cobertura ----

ggiNEXTbeta3D(diversidad_abun_cov) +
  labs(
    x        = "Cobertura de las muestras",
    y        = "Diversidad taxon\u00f3mica",
    title    = "(b) Rarefacci\u00f3n y extrapolaci\u00f3n basada en cobertura",
    subtitle = paste(
      "Comparaci\u00f3n de las parejas de zonas M_vs_P, M_vs_RM, P_vs_RM",
      "\u25b2 Gamma (tama\u00f1o 2n)  \u25cf Gamma (tama\u00f1o n)  \u25b3 Alfa (tama\u00f1o 2n)  \u25cb Alfa (tama\u00f1o n)",
      sep = "\n"
    )
  ) +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() +
  theme(
    axis.title    = element_text(size = 11, face = "bold"),
    strip.text    = element_text(face = "bold"),
    axis.text     = element_text(size = 10),
    plot.title    = element_text(size = 13, face = "bold", colour = "blue4"),
    plot.subtitle = element_text(size = 10,
                                 margin = margin(b = 6), lineheight = 1.1),
    panel.grid    = element_blank(),
    legend.position = "bottom",
    legend.box    = "vertical",
    legend.title  = element_blank(),
    plot.margin   = margin(8, 10, 8, 8)
  )

cat("\nCaso B.3 finalizado correctamente.\n")
