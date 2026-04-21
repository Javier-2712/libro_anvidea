# =========================================================
# ANVIDEA - Capítulo 4
# Modelos de crecimiento poblacional
# ---------------------------------------------------------
# Archivo : 02_modelo_exponencial_discreto.R
# Sección : A. Modelo exponencial — A.2 Tiempo discreto
# =========================================================

library(tidyverse)
library(kableExtra)

# ----------------------------------------------------------
# Ejemplo 1 — lambda > 1: crecimiento (plantas)
# N(15) = 50 · 1.2^15 ≈ 818 plantas
# ----------------------------------------------------------

N0     <- 50
lambda <- 1.2
t      <- 0:15
tabla  <- tibble(t, N = N0 * lambda^t)

ggplot(tabla, aes(t, N)) +
  geom_step(linewidth = 1, direction = "hv") +
  geom_point(size = 2) +
  labs(title = "Crecimiento discreto (lambda = 1.2)",
       x = "Generaciones (t)", y = "Densidad poblacional (N)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 2 — lambda = 1: población estable
# N(t) = 100 · 1^t = 100 para cualquier t
# ----------------------------------------------------------

N0     <- 100
lambda <- 1
t      <- 0:10

tibble(t, N = N0 * lambda^t) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# ----------------------------------------------------------
# Ejemplo 3 — lambda < 1: decrecimiento (aves migratorias)
# N(12) = 80 · 0.7^12 ≈ 3.6 individuos
# ----------------------------------------------------------

N0     <- 80
lambda <- 0.7
t      <- 0:12
tabla  <- tibble(t, N = N0 * lambda^t)

ggplot(tabla, aes(t, N)) +
  geom_step(linewidth = 1, direction = "hv") +
  geom_point(size = 2) +
  labs(title = "Decrecimiento discreto (lambda = 0.7)",
       x = "Generaciones (t)", y = "Densidad poblacional (N)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 4 — Comparación: continuo vs. discreto
# lambda = exp(r)  <=>  r = ln(lambda)
# ----------------------------------------------------------

N0     <- 30
r      <- 0.2
t      <- seq(0, 10, by = 1)
lambda <- exp(r)

datos_cont <- tibble(t, Modelo = "Continuo", N = N0 * exp(r * t))
datos_disc <- tibble(t, Modelo = "Discreto", N = N0 * lambda^t)
datos_comp <- bind_rows(datos_cont, datos_disc)

ggplot(datos_comp, aes(t, N, shape = Modelo, linetype = Modelo)) +
  geom_step(linewidth = 0.8, direction = "hv") +
  geom_point(size = 2) +
  labs(title = "Comparación de las trayectorias",
       x = "Tiempo (t)", y = "Densidad de la población (N)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 5 — Estimar lambda a partir de escenarios
# lambda = (Nt/N0)^(1/t)
# ----------------------------------------------------------

escenarios <-
  tribble(
    ~No, ~Nt, ~t,
     60, 240,  6,
    100, 100, 10,
     80,  20,  8,
     30, 300, 10
  )

tab_lambda <-
  escenarios %>%
  mutate(
    Lambda = (Nt / No)^(1 / t),
    Interpretacion = case_when(
      Lambda > 1  ~ "Crecimiento (\u03bb>1)",
      Lambda == 1 ~ "Estable (\u03bb=1)",
      Lambda < 1  ~ "Decrecimiento (\u03bb<1)"
    )
  )

tab_lambda %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

trayec_lambda <-
  tab_lambda %>%
  rowwise() %>%
  mutate(curva = list(tibble(
    tiempo = 0:t,
    N      = No * Lambda^(0:t)
  ))) %>%
  unnest(curva)

ggplot(trayec_lambda, aes(x = tiempo, y = N,
                          group = interaction(No, Nt, t),
                          shape = Interpretacion,
                          linetype = Interpretacion)) +
  geom_step(linewidth = 1, direction = "hv") +
  geom_point(size = 2) +
  labs(title    = "Estimaci\u00f3n de \u03bb y trayectorias discreta N(t) = N0 \u00b7 \u03bb^t",
       x = "Tiempo (t)", y = "Tama\u00f1o poblacional (N)",
       shape    = "Interpretaci\u00f3n",
       linetype = "Interpretaci\u00f3n") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 6 — Reconstruir r a partir de lambda
# r = ln(lambda)
# ----------------------------------------------------------

lambda_val <- c(0.6, 0.8, 1.0, 1.2, 1.5)

tab_r <-
  tibble(lambda = lambda_val,
         r      = log(lambda_val)) %>%
  mutate(
    clasificacion = case_when(
      lambda > 1  ~ "Crecimiento",
      lambda == 1 ~ "Estable",
      TRUE        ~ "Decrecimiento"
    ),
    T_dup  = if_else(r > 0, log(2)   / r, as.numeric(NA)),
    T_half = if_else(r < 0, log(0.5) / r, as.numeric(NA))
  )

tab_r %>%
  head() %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

N0           <- 40
t_max        <- 12
tiempos_cont <- seq(0, t_max, by = 0.25)
tiempos_disc <- 0:t_max

curvas <- map_dfr(lambda_val, function(lmb) {
  r_val <- log(lmb)
  bind_rows(
    tibble(Modelo = "Continuo", lambda = lmb, r = r_val,
           t = tiempos_cont, N = N0 * exp(r_val * tiempos_cont)),
    tibble(Modelo = "Discreto", lambda = lmb, r = r_val,
           t = tiempos_disc, N = N0 * (lmb^tiempos_disc))
  )
})

ggplot(curvas, aes(x = t, y = N)) +
  geom_step(linewidth = 1, direction = "hv") +
  geom_point(data = filter(curvas, Modelo == "Discreto"), size = 1.5) +
  facet_wrap(~ lambda, scales = "free_y") +
  labs(title    = "Trayectorias equivalentes: modelo continuo vs. discreto",
       subtitle = "Relaci\u00f3n: lambda = e^r  \u21d4  r = ln(lambda)",
       x = "Tiempo (t)", y = "Tama\u00f1o de la poblaci\u00f3n (N)") +
  theme_bw()

cat("\nModelo exponencial discreto finalizado correctamente.\n")
