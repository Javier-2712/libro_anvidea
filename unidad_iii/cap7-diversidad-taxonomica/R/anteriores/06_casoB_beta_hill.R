# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# Caso B3: Diversidad beta con números de Hill
# =========================================================

cat("\n========================================\n")
cat("Caso B3 - Diversidad beta (números de Hill)\n")
cat("========================================\n")

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(kableExtra)
library(vegan)

biol <- read_excel(file.path(data_dir, "datos.c7.xlsx"), sheet = "tax")

# ---------------------------------------------------------
# Paso 1) Matriz zona × especie
# ---------------------------------------------------------

biol_sit <- biol %>%
  group_by(Sites1) %>%
  summarise(across(where(is.numeric), sum, na.rm = TRUE))

mat <- biol_sit %>%
  select(-Sites1) %>%
  as.matrix()

rownames(mat) <- biol_sit$Sites1

# ---------------------------------------------------------
# Paso 2) Diversidad alfa y gamma
# ---------------------------------------------------------

q0_alpha <- mean(specnumber(mat))
q0_gamma <- specnumber(colSums(mat))

H_alpha <- mean(diversity(mat))
q1_alpha <- exp(H_alpha)
q1_gamma <- exp(diversity(colSums(mat)))

q2_alpha <- mean(1 / diversity(mat, "simpson"))
q2_gamma <- 1 / diversity(colSums(mat), "simpson")

beta <- data.frame(
  q = c(0,1,2),
  Alfa = c(q0_alpha, q1_alpha, q2_alpha),
  Gamma = c(q0_gamma, q1_gamma, q2_gamma),
  Beta = c(q0_gamma/q0_alpha,
           q1_gamma/q1_alpha,
           q2_gamma/q2_alpha)
)

beta %>%
  mutate(across(where(is.numeric), round, 2)) %>%
  kbl(booktabs = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE)

# ---------------------------------------------------------
# Paso 3) Visualización
# ---------------------------------------------------------

beta_long <- pivot_longer(beta,
                          cols = c(Alfa, Gamma, Beta),
                          names_to = "Componente",
                          values_to = "Valor")

ggplot(beta_long, aes(factor(q), Valor, fill = Componente)) +
  geom_col(position = "dodge") +
  labs(x = "Orden q",
       y = "Diversidad efectiva",
       title = "Diversidad alfa, beta y gamma con números de Hill") +
  theme_bw()

cat("\nCaso B3 finalizado correctamente.\n")
