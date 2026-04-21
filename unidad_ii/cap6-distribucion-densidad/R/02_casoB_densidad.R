# =========================================================
# ANVIDEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# ---------------------------------------------------------
# Archivo : 02_casoB_densidad.R
# Caso    : B. Estimación ecológica de la densidad
# =========================================================

cat("\n========================================\n")
cat("Caso B - Estimación de la densidad\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Librerías
# ---------------------------------------------------------

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(kableExtra)
  library(ggplot2)
})


# ---------------------------------------------------------
# 1.) Método de Holgate (con puntos de intersección al azar)
# ---------------------------------------------------------

# Paso 2. Lectura de la base de datos para calcular IH
datos1 <- read_xlsx(archivo_datos, sheet = "densidad1")

head(datos1, 4) %>%
  kbl(booktabs  = TRUE, digits = 3,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 3. Cálculo de IH en metros cuadrados (m2) y en hectáreas (ha)
res_ih <-
  datos1 %>%
  rename_with(tolower) %>%
  transmute(x2_m = as.numeric(x2_m)) %>%
  filter(!is.na(x2_m), x2_m > 0) %>%
  summarise(
    n_puntos  = n(),
    sum_x2_m2 = sum(x2_m),
    D_Ht_m2   = n_puntos / (pi * sum_x2_m2),
    D_Ht_ha   = D_Ht_m2 * 10000
  )

res_ih %>%
  kbl(booktabs  = TRUE,
      digits = c(0, 3, 6, 0),
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 4. Visualización de las frecuencias observadas
ggplot(datos1, aes(x = sqrt(x2_m))) +
  geom_histogram(bins = 20, fill = "skyblue", color = "white") +
  geom_vline(aes(xintercept = mean(sqrt(x2_m), na.rm = TRUE)),
             linetype = 2, color = "red") +
  labs(x     = "Distancia al 1er individuo, x\u1d62 (m)",
       y     = "Frecuencia",
       title = "") +
  theme_bw()


# ---------------------------------------------------------
# 2.) Índices de King y de Hayne (con transecto diagonal)
# ---------------------------------------------------------

# Paso 1. Leer la base de datos
datos2 <- read_xlsx(archivo_datos, sheet = "densidad2")

head(datos2, 4) %>%
  kbl(booktabs  = TRUE, digits = 3,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 2. Cálculos de los índices King y Hayne
d2 <-
  datos2 %>%
  dplyr::rename_with(tolower)

L <- 28.284271  # Hipotenusa (L) tomada de la hoja de resultados

d <- d2 %>%
  transmute(
    di    = as.numeric(di_m),
    invdi = as.numeric(`1/di`)
  ) %>%
  filter(is.finite(di), di > 0, is.finite(invdi))

n       <- nrow(d)
sum_di  <- sum(d$di)
sum_inv <- sum(d$invdi)

res <- tibble::tibble(
  `L (m)`          = L,
  `n (puntos)`     = n,
  `sum di (m)`     = sum_di,
  `sum 1/di`       = sum_inv,
  `King (ind/m2)`  = (n^2) / (2 * L * sum_di),
  `King (ind/ha)`  = ((n^2) / (2 * L * sum_di)) * 10000,
  `Hayne (ind/m2)` = sum_inv / (2 * L),
  `Hayne (ind/ha)` = (sum_inv / (2 * L)) * 10000
)

res %>%
  kbl(booktabs = TRUE,
      digits = c(2, 0, 3, 3, 3, 0, 2, 0)) %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(
    full_width    = FALSE,
    font_size     = 10,
    latex_options = c("repeat_header")
  )

# Paso 3. Visualización — distribución de di (King)
ggplot(d, aes(x = di)) +
  geom_histogram(bins = 20, fill = "skyblue", color = "white") +
  geom_vline(aes(xintercept = mean(di, na.rm = TRUE)),
             linetype = 2, color = "red") +
  labs(x     = "Distancia perpendicular, d\u1d62 (m)",
       y     = "Frecuencia",
       title = "") +
  theme_bw()

# Visualización — distribución de 1/di (Hayne)
ggplot(d, aes(x = invdi)) +
  geom_histogram(bins = 20, fill = "skyblue", color = "white") +
  geom_vline(xintercept = mean(d$invdi, na.rm = TRUE),
             linetype = 2, color = "red") +
  labs(x     = "Distancia perpendicular, 1/d\u1d62 (m\u207b\u00b9)",
       y     = "Frecuencia",
       title = "") +
  theme_bw()

cat("\nCaso B finalizado correctamente.\n")
