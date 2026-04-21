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
# Paso 3) Comparación de zonas con GLMs y PERMANOVAs
# ---------------------------------------------------------

# Nota: biol1 y biol1b provienen del casoA.1

library(MASS)
library(mvabund)
library(glmmTMB)
library(RVAideMemoire)
library(vegan)
library(kableExtra)
library(dplyr)
library(tidyverse)

# ---- a. GLM Poisson y Binomial Negativa para una especie ----

# Ajuste Poisson
poisson <- glm(Pclm ~ Sites1,
               family = "poisson",
               data = biol1b)
summary(poisson)

# Ajuste Binomial Negativa
mod_p  <- glm(Pclm ~ Sites1,
              data   = biol1b,
              family = poisson(link = "log"))

mod_nb <- glm.nb(Pclm ~ Sites1,
                 data    = biol1b,
                 start   = coef(mod_p),
                 control = glm.control(maxit = 200))
summary(mod_nb)

# Otra opción de diagnóstico binomial
bin_neg <-
  glmmTMB(Pclm ~ Sites1,
          family = nbinom2,
          data   = biol1b)
summary(bin_neg)


# ---- b. Evaluación conjunta con manyGLM ----

# Excluir la primera columna (Sites1)
Especies <- mvabund(biol1[, -1])

# GLM multivariado Poisson
poisson <-
  manyglm(Especies ~ Sites1,
          data   = biol1,
          family = "poisson")
summary(poisson)


# ---- c. Comparación de muestras con PERMANOVA ----

# Eliminar posibles NA o datos faltantes
biol1 <-
  biol1 %>%
  na.omit()

# Reemplazar los NA por 0
biol1 <-
  biol1 %>%
  mutate(across(-1, ~ replace_na(., 0)))

# Matriz de distancias de Bray-Curtis
bray.dis <- vegdist(biol1[, 2:ncol(biol1)])

# PERMANOVA por zona
biol.permanova <- adonis2(bray.dis ~ Sites1,
                          data         = biol1,
                          permutations = 999)
biol.permanova


# ---- d. Comparaciones múltiples del PERMANOVA ----

pairwise.perm.manova(bray.dis, biol1$Sites1, nperm = 1000)


# ---- e. Análisis SIMPER ----

# Matriz de abundancias sin el factor de sitio
biol3 <-
  biol1 %>%
  dplyr::select(-Sites1)

# Análisis SIMPER
simper <-
  simper(biol3,
         group        = biol1$Sites1,
         permutations = 999)

# Zonas comparadas: tres tablas
names(summary(simper))

# Tabla 1: M vs P
simper.M_P <-
  summary(simper)$"M_P" %>%
  as.data.frame() %>%
  rownames_to_column("Especies") %>%
  arrange(p) %>%
  slice_head(n = 10)

simper.M_P %>%
  kbl(align    = "lcccc",
      booktabs = TRUE,
      digits   = 3) %>%
  kable_classic(full_width = TRUE)

# Tabla 2: M vs RM
simper.M_RM <-
  summary(simper)$"M_RM" %>%
  as.data.frame() %>%
  rownames_to_column("Especies") %>%
  arrange(p) %>%
  slice_head(n = 10)

simper.M_RM %>%
  kbl(align    = "lcccc",
      booktabs = TRUE,
      digits   = 3) %>%
  kable_classic(full_width = TRUE)

# Tabla 3: P vs RM
simper.P_RM <-
  summary(simper)$"P_RM" %>%
  as.data.frame() %>%
  rownames_to_column("Especies") %>%
  arrange(p) %>%
  slice_head(n = 10)

simper.P_RM %>%
  kbl(align    = "lcccc",
      booktabs = TRUE,
      digits   = 3) %>%
  kable_classic(full_width = TRUE)

cat("\nCaso A.2 finalizado correctamente.\n")
