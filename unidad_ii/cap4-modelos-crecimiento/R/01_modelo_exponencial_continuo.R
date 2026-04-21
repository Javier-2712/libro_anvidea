# =========================================================
# ANVIDEA - Capítulo 4
# Modelos de crecimiento poblacional
# ---------------------------------------------------------
# Archivo : 01_modelo_exponencial_continuo.R
# Sección : A. Modelo exponencial — A.1 Tiempo continuo
# =========================================================

library(tidyverse)

# ----------------------------------------------------------
# Ejemplo 1 — Curva con r positivo (fitoplancton)
# Td = ln(2)/0.4 ≈ 1.73 horas; N(20) ≈ 2.98e4 individuos
# ----------------------------------------------------------

N0 <- 10
r  <- 0.4
t  <- seq(0, 20, by = 0.5)
tabla <- tibble(t, N = N0 * exp(r * t))

ggplot(tabla, aes(t, N)) +
  geom_line(linewidth = 1.1) +
  labs(title    = "Crecimiento exponencial continuo",
       subtitle = "N(t) = N0. e^(r.t)  con r = 0.4",
       x = "Tiempo (t)", y = "Tamaño poblacional (N)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 2 — r negativo: decrecimiento (peces)
# T½ = ln(0.5)/(-0.2) ≈ 3.47 días; N(30) ≈ 0.30 individuos
# ----------------------------------------------------------

N0 <- 120
r  <- -0.2
t  <- seq(0, 30, by = 1)
tabla <- tibble(t, N = N0 * exp(r * t))

ggplot(tabla, aes(t, N)) +
  geom_line(linewidth = 1.1) +
  labs(title    = "Decrecimiento (continuo)",
       subtitle = "r = -0.2",
       x = "Tiempo", y = "Tamaño poblacional") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 3 — Comparación de múltiples r (insectos)
# N(20): r=0.1 → ~370; r=0.3 → ~20200; r=0.5 → ~1.1e6
# ----------------------------------------------------------

N0 <- 50
t  <- seq(0, 20, by = 0.25)
r  <- c(0.1, 0.3, 0.5)

tabla <- purrr::map_dfr(
  r,
  function(r) tibble(t, r = r, N = N0 * exp(r * t))
)

ggplot(tabla, aes(t, N, group = factor(r), linetype = factor(r))) +
  geom_line(linewidth = 1.05) +
  labs(title    = "Patrón de aumento de la población",
       linetype = "Valores de r",
       x = "Tiempo (t)", y = "Tamaño poblacional (N)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 4 — Tiempo de duplicación (Td) y semirreducción (T½)
# ----------------------------------------------------------

r_val <- c(-0.50, -0.25, -0.10, 0.10, 0.25, 0.50)

tab <- tibble(
  r   = r_val,
  Td  = if_else(r > 0, log(2) / r,   NA_real_),
  Tsr = if_else(r < 0, log(0.5) / r, NA_real_)
)

tab_largo <-
  tab %>%
  pivot_longer(cols      = c(Td, Tsr),
               names_to  = "Metrica",
               values_to = "Tiempo") %>%
  filter(!is.na(Tiempo))

ggplot(tab_largo, aes(x = r, y = Tiempo,
                      shape = Metrica, linetype = Metrica)) +
  geom_point(size = 2.6) +
  geom_line() +
  labs(title = "Escenarios de crecimiento exponencial continuo",
       x     = "r (tasa crec. instantáneo)",
       y     = "Tiempo") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 5 — Velocidad instantánea dN/dt = rN (invertebrados)
# dN/dt en t=0: 0.2×30 = 6 ind/día
# N(25) ≈ 4.45e3; dN/dt(25) ≈ 891 ind/día
# ----------------------------------------------------------

N0   <- 30
r    <- 0.2
t    <- seq(0, 25, by = 0.5)
N    <- N0 * exp(r * t)
dNdt <- r * N
tabla <- tibble(t, N, dNdt)

ggplot(tabla, aes(t, dNdt)) +
  geom_line(linewidth = 1.1) +
  labs(title = "Velocidad de cambio o de aumento (dN/dt = r.N)",
       x     = "Tiempo (t)",
       y     = "Velocidad de aumento (dN/dt)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 6 — Estimar r con dos observaciones (4 escenarios)
# ----------------------------------------------------------

resultados <-
  tribble(
    ~N0, ~Nt, ~t,
     40, 120, 10,
     80,  20,  8,
     50,  50, 12,
     30, 200, 15
  ) %>%
  mutate(r = log(Nt / N0) / t)

tabla1 <-
  resultados %>%
  rowwise() %>%
  mutate(
    curva = list(tibble(
      tiempo = 0:t,
      N      = N0 * exp(r * (0:t))
    ))
  ) %>%
  unnest(curva)

ggplot(tabla1, aes(x = tiempo, y = N,
                   color = factor(Nt),
                   group = interaction(N0, Nt, t))) +
  geom_line(linewidth = 1.1) +
  geom_point(data = resultados,
             aes(x = t, y = Nt),
             size = 3, shape = 21, fill = "white") +
  labs(title = "Estimación de r con las observaciones",
       x     = "Tiempo (t)",
       y     = "Tamaño poblacional (N)",
       color = "Nt observado") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 7 — Estimar r en población bacteriana
# r = ln(800/100)/10 ≈ 0.2089 bacterias/bacterias·hora
# ----------------------------------------------------------

N0    <- 100
Nt    <- 800
t_max <- 10
r     <- log(Nt / N0) / t_max
t     <- seq(0, t_max, by = 0.1)
tabla <- tibble(t, N = N0 * exp(r * t))

ggplot(tabla, aes(t, N)) +
  geom_line(linewidth = 1.1) +
  geom_point(data  = tibble(t = t_max, N = Nt),
             size  = 3, shape = 21, fill = "white") +
  labs(title    = "Crecimiento exponencial continuo",
       subtitle = paste0("N0=", N0, ", Nt=", Nt, ", t=", t_max,
                         ", r\u2248", round(r, 3), " ind/ind\u00b7hora"),
       x = "Tiempo (horas)",
       y = "Número de individuos") +
  theme_bw()

cat("\nModelo exponencial continuo finalizado correctamente.\n")
