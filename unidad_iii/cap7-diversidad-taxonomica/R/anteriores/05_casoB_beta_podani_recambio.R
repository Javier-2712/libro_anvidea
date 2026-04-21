# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# Caso B2: Partición beta de Podani y recambio
# =========================================================

cat("\n========================================\n")
cat("Caso B2 - Beta de Podani y recambio\n")
cat("========================================\n")

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(kableExtra)
library(vegan)

biol <- read_excel(file.path(data_dir, "datos.c7.xlsx"), sheet = "tax")

# ---------------------------------------------------------
# Paso 1) Matriz presencia-ausencia por sitio
# ---------------------------------------------------------

biol_sit <- biol %>%
  group_by(Sites1) %>%
  summarise(across(where(is.numeric), sum, na.rm = TRUE))

mat <- biol_sit %>%
  select(-Sites1) %>%
  as.matrix()

rownames(mat) <- biol_sit$Sites1
pa <- ifelse(mat > 0, 1, 0)

# ---------------------------------------------------------
# Paso 2) Disimilitud total (Jaccard)
# ---------------------------------------------------------

beta_total <- as.matrix(vegdist(pa, method = "jaccard"))

# ---------------------------------------------------------
# Paso 3) Recambio y diferencia de riqueza (aproximación)
# ---------------------------------------------------------

sitios <- rownames(pa)
res <- data.frame()

for(i in 1:(nrow(pa)-1)){
  for(j in (i+1):nrow(pa)){
    a <- sum(pa[i,] == 1 & pa[j,] == 1)
    b <- sum(pa[i,] == 1 & pa[j,] == 0)
    c <- sum(pa[i,] == 0 & pa[j,] == 1)
    recambio <- (2 * min(b,c)) / (a + 2 * min(b,c))
    riqueza  <- abs(b-c) / (a + b + c)
    res <- rbind(res,
                 data.frame(
                   Sitio1 = sitios[i],
                   Sitio2 = sitios[j],
                   Recambio = round(recambio,3),
                   Dif_Riqueza = round(riqueza,3)
                 )
    )
  }
}

res %>%
  kbl(booktabs = TRUE, digits = 3) %>%
  kable_classic(full_width = FALSE)

# ---------------------------------------------------------
# Paso 4) Visualización
# ---------------------------------------------------------

res_long <- pivot_longer(res,
                         cols = c(Recambio, Dif_Riqueza),
                         names_to = "Componente",
                         values_to = "Valor")

ggplot(res_long, aes(Componente, Valor, fill = Componente)) +
  geom_boxplot() +
  labs(title = "Componentes de la diversidad beta") +
  theme_bw()

cat("\nCaso B2 finalizado correctamente.\n")
