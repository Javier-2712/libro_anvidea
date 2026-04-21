# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# ---------------------------------------------------------
# Archivo : 02_casoA_alfa_glm_permanovas.R
# Caso    : A.2 Comparación de zonas con GLMs y PERMANOVAs
# =========================================================

cat("\n========================================\n")
cat("Caso A.2 - GLMs y PERMANOVAs\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Librerías y lectura de la base de datos
# ---------------------------------------------------------

library(kableExtra)
library(readxl)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(vegan)
library(MASS)
library(mvabund)

# Paquetes opcionales del capítulo
usa_glmmTMB <- requireNamespace("glmmTMB", quietly = TRUE)
usa_RVAideMemoire <- requireNamespace("RVAideMemoire", quietly = TRUE)

# Base de abundancias por sitio
biol <- readxl::read_excel(archivo_datos, sheet = "tax")

# Tabla de abreviaturas de especies
abrev_tax <- readxl::read_excel(archivo_datos, sheet = "tax1") %>%
  transmute(
    Abrev = as.character(Abrev),
    LatinName = as.character(LatinName)
  )

# ---------------------------------------------------------
# Paso 2) Preparación de la base para los análisis
# ---------------------------------------------------------

# Selección de especies (todas las columnas después de Sites y Sites1)
especies_originales <- names(biol)[-(1:2)]

# Vector de renombramiento: nombre latino -> abreviatura
mapa_abrev <- abrev_tax$Abrev
names(mapa_abrev) <- abrev_tax$LatinName

# Renombrar especies con abreviaturas cuando estén disponibles
nuevos_nombres <- ifelse(
  especies_originales %in% names(mapa_abrev),
  mapa_abrev[especies_originales],
  especies_originales
)

# Base de trabajo: zona + abundancias por especie
biol1 <- biol %>%
  select(Sites1, all_of(especies_originales)) %>%
  rename_with(
    ~ nuevos_nombres,
    .cols = all_of(especies_originales)
  ) %>%
  mutate(Sites1 = factor(Sites1, levels = c("M", "P", "RM")))

# Tabla general de la base utilizada
head(biol1[, 1:min(10, ncol(biol1))], 6) %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE)

# ---------------------------------------------------------
# Paso 3) Prueba con distribución Poisson y Binomial Negativa
#         para una especie (GLM)
# ---------------------------------------------------------

# Para este ejemplo se utiliza Poecilia mexicana (Pclm)
if (!("Pclm" %in% names(biol1))) {
  stop("No se encontró la especie abreviada 'Pclm' en la base de datos.")
}

biol1b <- biol1 %>%
  select(Sites1, Pclm) %>%
  mutate(Sites1 = droplevels(Sites1))

# Tabla descriptiva de la especie por zona
resumen_pclm <- biol1b %>%
  group_by(Sites1) %>%
  summarise(
    n = n(),
    media = mean(Pclm, na.rm = TRUE),
    de = sd(Pclm, na.rm = TRUE),
    varianza = var(Pclm, na.rm = TRUE),
    maximo = max(Pclm, na.rm = TRUE),
    .groups = "drop"
  )

resumen_pclm %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 2,
      caption = "Resumen descriptivo de Poecilia mexicana (Pclm) por zona") %>%
  kable_classic(full_width = FALSE)

# Figura exploratoria de la especie por zona
ggplot(biol1b, aes(x = Sites1, y = Pclm, fill = Sites1)) +
  geom_boxplot() +
  labs(x = "Zona", y = "Abundancia de Pclm",
       title = "Variación de Poecilia mexicana entre zonas") +
  theme_bw() +
  theme(legend.position = "none")

# Ajuste Poisson
mod_p <- glm(Pclm ~ Sites1,
             data = biol1b,
             family = poisson(link = "log"))

summary(mod_p)

# Ajuste Binomial Negativa
mod_nb <- glm.nb(Pclm ~ Sites1,
                 data = biol1b,
                 start = coef(mod_p),
                 control = glm.control(maxit = 200))

summary(mod_nb)

# Tabla comparativa de los modelos
comparacion_glm <- tibble(
  Modelo = c("Poisson", "Binomial negativa"),
  AIC = c(AIC(mod_p), AIC(mod_nb)),
  Desvianza_residual = c(deviance(mod_p), deviance(mod_nb)),
  GL_residuales = c(df.residual(mod_p), df.residual(mod_nb))
)

comparacion_glm %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 2,
      caption = "Comparación entre el GLM Poisson y el GLM Binomial Negativa") %>%
  kable_classic(full_width = FALSE)

# Valores ajustados por zona
pred_glm <- biol1b %>%
  mutate(
    ajuste_poisson = fitted(mod_p),
    ajuste_bn = fitted(mod_nb)
  ) %>%
  group_by(Sites1) %>%
  summarise(
    observada = mean(Pclm, na.rm = TRUE),
    poisson = mean(ajuste_poisson, na.rm = TRUE),
    binomial_negativa = mean(ajuste_bn, na.rm = TRUE),
    .groups = "drop"
  )

pred_glm %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 2,
      caption = "Promedios observados y ajustados de Pclm por zona") %>%
  kable_classic(full_width = FALSE)

# Modelo opcional con glmmTMB
if (usa_glmmTMB) {
  cat("\nAjuste opcional con glmmTMB (binomial negativa)\n")
  bin_neg <- glmmTMB::glmmTMB(
    Pclm ~ Sites1,
    family = glmmTMB::nbinom2,
    data = biol1b
  )
  print(summary(bin_neg))
}

# ---------------------------------------------------------
# Paso 4) Evaluación conjunta del efecto de la zona sobre
#         todas las especies (manyGLM)
# ---------------------------------------------------------

# Matriz multivariada de especies
especies_mv <- mvabund::mvabund(biol1[, -1])

# GLM multivariado Poisson
many_poisson <- mvabund::manyglm(
  especies_mv ~ Sites1,
  data = biol1,
  family = "poisson"
)

summary(many_poisson)

# Prueba anova del modelo multivariado
anova_many_poisson <- anova(many_poisson, p.uni = "adjusted")
anova_many_poisson

# ---------------------------------------------------------
# Paso 5) Comparación de muestras con PERMANOVA
# ---------------------------------------------------------

biol_perma <- biol1 %>%
  mutate(across(-Sites1, ~ replace_na(.x, 0))) %>%
  na.omit()

# Matriz de Bray-Curtis
bray.dis <- vegdist(biol_perma[, -1], method = "bray")

# PERMANOVA por zona
biol_permanova <- adonis2(bray.dis ~ Sites1,
                          data = biol_perma,
                          permutations = 999)
biol_permanova

# Tabla resumida de la PERMANOVA
as.data.frame(biol_permanova) %>%
  rownames_to_column("Fuente") %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 4,
      caption = "Resultados de la PERMANOVA para la composición taxonómica entre zonas") %>%
  kable_classic(full_width = FALSE)

# ---------------------------------------------------------
# Paso 6) Comparaciones múltiples de la PERMANOVA
# ---------------------------------------------------------

if (usa_RVAideMemoire) {
  pair_permanova <- RVAideMemoire::pairwise.perm.manova(
    bray.dis,
    biol_perma$Sites1,
    nperm = 1000
  )
  pair_permanova
} else {
  cat("\nNota: no se ejecutó la prueba post hoc del PERMANOVA porque el paquete RVAideMemoire no está instalado.\n")
}

# ---------------------------------------------------------
# Paso 7) Análisis SIMPER
# ---------------------------------------------------------

# Matriz de abundancias sin el factor de zona
biol3 <- biol_perma %>%
  select(-Sites1)

simper_td <- simper(biol3,
                    group = biol_perma$Sites1,
                    permutations = 999)

names(summary(simper_td))

# Tabla 1: M vs P
simper.M_P <- summary(simper_td)$"M_P" %>%
  as.data.frame() %>%
  rownames_to_column("Especies") %>%
  arrange(p) %>%
  slice_head(n = 10)

simper.M_P %>%
  kbl(align = "lcccccc", booktabs = TRUE, digits = 3,
      caption = "Diez primeras especies ordenadas por valor-p en el SIMPER de zonas M vs P") %>%
  kable_classic(full_width = FALSE)

# Tabla 2: M vs RM
simper.M_RM <- summary(simper_td)$"M_RM" %>%
  as.data.frame() %>%
  rownames_to_column("Especies") %>%
  arrange(p) %>%
  slice_head(n = 10)

simper.M_RM %>%
  kbl(align = "lcccccc", booktabs = TRUE, digits = 3,
      caption = "Diez primeras especies ordenadas por valor-p en el SIMPER de zonas M vs RM") %>%
  kable_classic(full_width = FALSE)

# Tabla 3: P vs RM
simper.P_RM <- summary(simper_td)$"P_RM" %>%
  as.data.frame() %>%
  rownames_to_column("Especies") %>%
  arrange(p) %>%
  slice_head(n = 10)

simper.P_RM %>%
  kbl(align = "lcccccc", booktabs = TRUE, digits = 3,
      caption = "Diez primeras especies ordenadas por valor-p en el SIMPER de zonas P vs RM") %>%
  kable_classic(full_width = FALSE)

cat("\nCaso A.2 finalizado correctamente.\n")
