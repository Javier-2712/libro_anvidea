# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# Caso A3: Diversidad alfa mediante números de Hill
# =========================================================

cat("\n========================================\n")
cat("Caso A3 - Diversidad alfa (números de Hill)\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Librerías y lectura de la base de datos
# ---------------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(kableExtra)
library(vegan)

biol <- read_excel(file.path(data_dir, "datos.c7.xlsx"), sheet = "tax")

# ---------------------------------------------------------
# Paso 2) Construcción de la matriz zona × especie
# ---------------------------------------------------------

biol_sit <- biol %>%
  group_by(Sites1) %>%
  summarise(across(where(is.numeric), sum, na.rm = TRUE)) %>%
  pivot_longer(-Sites1, names_to = "sp", values_to = "ab") %>%
  pivot_wider(names_from = Sites1, values_from = ab, values_fill = 0)

biol_zona <- biol_sit %>%
  column_to_rownames("sp") %>%
  as.matrix() %>%
  t()

# ---------------------------------------------------------
# Paso 3) Cálculo de números de Hill (q = 0, 1, 2)
# ---------------------------------------------------------

q0 <- specnumber(biol_zona)
H  <- diversity(biol_zona)
q1 <- exp(H)
q2 <- 1 / diversity(biol_zona, "simpson")

tabla_hill <- data.frame(
  Zona = rownames(biol_zona),
  q0 = q0,
  q1 = round(q1, 2),
  q2 = round(q2, 2)
)

tabla_hill %>%
  kbl(booktabs = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE)

# ---------------------------------------------------------
# Paso 4) Perfil de diversidad (Hill)
# ---------------------------------------------------------

q_vals <- seq(0, 3, by = 0.1)

perfil <- sapply(1:nrow(biol_zona), function(i) {
  apply(as.matrix(q_vals), 1, function(q) {
    if (q == 0) {
      specnumber(biol_zona[i, ])
    } else if (q == 1) {
      exp(diversity(biol_zona[i, ]))
    } else {
      (sum((biol_zona[i, ] / sum(biol_zona[i, ]))^q))^(1/(1 - q))
    }
  })
})

perfil_df <- data.frame(
  q = rep(q_vals, times = nrow(biol_zona)),
  diversidad = as.vector(perfil),
  Zona = rep(rownames(biol_zona), each = length(q_vals))
)

ggplot(perfil_df, aes(q, diversidad, color = Zona)) +
  geom_line() +
  labs(x = "Orden de diversidad (q)",
       y = "Número efectivo de especies",
       title = "Perfil de diversidad (números de Hill)") +
  theme_bw()

cat("\nCaso A3 finalizado correctamente.\n")
