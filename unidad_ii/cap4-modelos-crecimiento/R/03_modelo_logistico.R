# =========================================================
# ANVIDEA - Cap\u00edtulo 4
# Modelos de crecimiento poblacional
# ---------------------------------------------------------
# Archivo : 03_modelo_logistico.R
# Secci\u00f3n : B. Modelo log\u00edstico
# =========================================================

library(tidyverse)
library(kableExtra)

# ----------------------------------------------------------
# Funci\u00f3n auxiliar: soluci\u00f3n anal\u00edtica del modelo log\u00edstico
# ----------------------------------------------------------

logistico_N <- function(t, N0, r, K) {
  K / (1 + ((K - N0) / N0) * exp(-r * t))
}

# ----------------------------------------------------------
# Ejemplo 1 — Tasa inicial dN/dt
# dN/dt|t=0 = r·N0·(1 - N0/K) = 0.05×500×(1 - 500/10000) = 23.75
# ----------------------------------------------------------

r  <- 0.05; N0 <- 500; K <- 10000
dNdt_0 <- r * N0 * (1 - N0 / K)
dNdt_0

# Segundo escenario
r <- 0.04; N0 <- 200; K <- 5000
r * N0 * (1 - N0 / K)

# ----------------------------------------------------------
# Ejemplo 2 — Tama\u00f1o tras 6 meses (t = 180 d\u00edas)
# ----------------------------------------------------------

N0 <- 100; K <- 400; r <- 0.02; t <- 180
N_t <- K / (1 + ((K - N0) / N0) * exp(-r * t))
N_t

# Tiempo requerido para alcanzar 80% de K
N0 <- 50; K <- 500; r <- 0.1; Nstar <- 0.8 * K
t_req <- (1 / r) * log(((K - N0) / N0) * (Nstar / (K - Nstar)))
t_req

# ----------------------------------------------------------
# Ejemplo 3 — Curva log\u00edstica base (simulaci\u00f3n)
# ----------------------------------------------------------

N0 <- 20; r <- 0.35; K <- 500
t  <- seq(0, 35, by = 0.25)
tabla <- tibble(t, N = logistico_N(t, N0 = N0, r = r, K = K))

ggplot(tabla, aes(t, N)) +
  geom_line(linewidth = 1.1) +
  geom_hline(yintercept = K, linetype = 2) +
  labs(title    = "Modelo log\u00edstico de crecimiento poblacional",
       subtitle = paste0("N0 = ", N0, ", r = ", r, ", K = ", K),
       x = "Tiempo (t)", y = "Tama\u00f1o poblacional (N)") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 4 — b'(N) cuadr\u00e1tica y d'(N) lineal
# b'(N) = 0.12 + 0.01·N - 0.0001·N²
# d'(N) = 0.18 + 0.008·N
# ----------------------------------------------------------

b_p <- function(N) 0.12 + 0.01 * N - 0.0001 * N^2
d_p <- function(N) 0.18 + 0.008 * N

N_vals <- seq(0, 50, by = 5)
tab_bd <- tibble(N    = N_vals,
                 `b'` = round(b_p(N_vals), 4),
                 `d'` = round(d_p(N_vals), 4))

kbl(tab_bd, booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

tabla <- tibble(N = seq(0, 60, by = 1)) %>%
  mutate(b = b_p(N), d = d_p(N)) %>%
  pivot_longer(cols = c(b, d), names_to = "tasa", values_to = "valor")

ggplot(tabla, aes(N, valor, linetype = tasa)) +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = 50, linetype = 2) +
  labs(y     = "Tasa espec\u00edfica",
       title = "Tasas densodependientes") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 5 — Poblaci\u00f3n tras 12 meses
# ----------------------------------------------------------

N0 <- 150; K <- 3000; r <- 0.03; t <- 12
K / (1 + ((K - N0) / N0) * exp(-r * t))

# ----------------------------------------------------------
# Ejemplo 6 — Tiempo hasta 75% de K
# ----------------------------------------------------------

N0 <- 50; K <- 800; r <- 0.08; Nstar <- 0.75 * K
(1 / r) * log(((K - N0) / N0) * (Nstar / (K - Nstar)))

# ----------------------------------------------------------
# Ejemplo 7 — K reducida por degradaci\u00f3n (99% de K')
# ----------------------------------------------------------

N0 <- 200; Kp <- 840; r <- 0.06; f <- 0.99; Nstar <- f * Kp
t_99 <- (1 / r) * log(((Kp - N0) / N0) * (Nstar / (Kp - Nstar)))
t_99

# ----------------------------------------------------------
# Ejemplo 8 — Tama\u00f1o tras 24 h
# ----------------------------------------------------------

r <- 0.07; K <- 50000; N0 <- 1000; t <- 24
K / (1 + ((K - N0) / N0) * exp(-r * t))

# ----------------------------------------------------------
# Ejemplo 9 — Equilibrio con b'(N) y d'(N): detecci\u00f3n num\u00e9rica
# ----------------------------------------------------------

b2    <- function(N) 0.10 + 0.015 * N - 0.00015 * N^2
d2    <- function(N) 0.12 + 0.006  * N
f_eq  <- function(N) b2(N) - d2(N)

uniroot_all <- function(f, interval, n = 2000) {
  xs          <- seq(interval[1], interval[2], length.out = n)
  ys          <- f(xs)
  sign_change <- which(diff(sign(ys)) != 0)
  roots       <- purrr::map_dbl(sign_change,
                                ~ uniroot(f, c(xs[.x], xs[.x + 1]))$root)
  unique(round(roots, 6))
}

roots <- uniroot_all(f_eq, c(0, 1000))
roots

df <- tibble(N = seq(0, 300, by = 1), b = b2(N), d = d2(N))

ggplot(df, aes(N)) +
  geom_line(aes(y = b, linetype = "b'(N)"), linewidth = 1.1) +
  geom_line(aes(y = d, linetype = "d'(N)"), linewidth = 1.1) +
  geom_vline(xintercept = roots, linetype = 2) +
  labs(y        = "Tasa espec\u00edfica (b' y d')",
       x        = "Tama\u00f1o de la poblaci\u00f3n (N)",
       linetype = "",
       title    = "Equilibrios por intersecci\u00f3n de tasas") +
  theme_bw()

# ----------------------------------------------------------
# Ejemplo 10 — Tiempo para duplicar N0
# ----------------------------------------------------------

r <- 0.05; K <- 1000; N0 <- 200; Nstar <- 2 * N0
(1 / r) * log(((K - N0) / N0) * (Nstar / (K - Nstar)))

# ----------------------------------------------------------
# Ejemplo 11 — Tasa dN/dt en t = 10 d\u00edas
# ----------------------------------------------------------

r <- 0.09; K <- 10000; N0 <- 500; t <- 10
N10     <- K / (1 + ((K - N0) / N0) * exp(-r * t))
dNdt_10 <- r * N10 * (1 - N10 / K)
N10; dNdt_10

# ----------------------------------------------------------
# Simulaci\u00f3n — Efecto de la capacidad de carga (K)
# ----------------------------------------------------------

N0 <- 20; r <- 0.30; K_vals <- c(100, 300, 600)
t  <- seq(0, 35, by = 0.25)

tabla <- map_dfr(K_vals,
                 function(Ki) tibble(t, K = factor(Ki),
                                     N = logistico_N(t, N0 = N0, r = r, K = Ki)))

ggplot(tabla, aes(t, N, linetype = K)) +
  geom_line(linewidth = 1.05) +
  labs(title    = "Efecto de la capacidad de carga (K)",
       x = "Tiempo (t)", y = "Tama\u00f1o poblacional (N)",
       linetype = "K") +
  theme_bw()

# ----------------------------------------------------------
# Simulaci\u00f3n — Efecto de la tasa intr\u00ednseca de crecimiento (r)
# ----------------------------------------------------------

N0 <- 20; K <- 400; r_vals <- c(0.10, 0.25, 0.50)

tabla <- map_dfr(r_vals,
                 function(ri) tibble(t, r = factor(ri),
                                     N = logistico_N(t, N0 = N0, r = ri, K = K)))

ggplot(tabla, aes(t, N, linetype = r)) +
  geom_line(linewidth = 1.05) +
  geom_hline(yintercept = K, linetype = 2) +
  labs(title    = "Efecto de la tasa intr\u00ednseca de crecimiento (r)",
       x = "Tiempo (t)", y = "Tama\u00f1o poblacional (N)",
       linetype = "r") +
  theme_bw()

# ----------------------------------------------------------
# Simulaci\u00f3n — Velocidad de crecimiento dN/dt = rN(1 - N/K)
# ----------------------------------------------------------

r <- 0.50; K <- 400
N_vals <- seq(0, K, length.out = 300)
tabla  <- tibble(N = N_vals, dNdt = r * N_vals * (1 - N_vals / K))

ggplot(tabla, aes(N, dNdt)) +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = K / 2, linetype = 2) +
  labs(title    = "Velocidad de crecimiento en el modelo log\u00edstico",
       subtitle = "dN/dt = rN(1 - N/K)",
       x = "Tama\u00f1o poblacional (N)", y = "Velocidad de aumento (dN/dt)") +
  theme_bw()

# ----------------------------------------------------------
# Simulaci\u00f3n — Comparaci\u00f3n: exponencial vs. log\u00edstico
# ----------------------------------------------------------

N0 <- 20; r <- 0.28; K <- 300
t2 <- seq(0, 30, by = 0.25)

tabla <- tibble(t = t2,
                Exponencial = N0 * exp(r * t2),
                Logistico   = logistico_N(t2, N0 = N0, r = r, K = K)) %>%
  pivot_longer(cols = c(Exponencial, Logistico),
               names_to = "Modelo", values_to = "N")

ggplot(tabla, aes(t, N, linetype = Modelo)) +
  geom_line(linewidth = 1.05) +
  geom_hline(yintercept = K, linetype = 2) +
  labs(title    = "Comparaci\u00f3n entre crecimiento exponencial y log\u00edstico",
       x = "Tiempo (t)", y = "Tama\u00f1o poblacional (N)",
       linetype = "Modelo") +
  theme_bw()

# ----------------------------------------------------------
# Simulaci\u00f3n — Influencia del tama\u00f1o inicial (N0)
# ----------------------------------------------------------

r <- 0.30; K <- 300; N0_vals <- c(10, 50, 150, 280)

tabla <- map_dfr(N0_vals,
                 function(N0i) tibble(t = t2, N0 = factor(N0i),
                                      N  = logistico_N(t2, N0 = N0i, r = r, K = K)))

ggplot(tabla, aes(t, N, linetype = N0)) +
  geom_line(linewidth = 1.05) +
  geom_hline(yintercept = K, linetype = 2) +
  labs(title    = "Influencia del tama\u00f1o inicial en la trayectoria log\u00edstica",
       x = "Tiempo (t)", y = "Tama\u00f1o poblacional (N)",
       linetype = "N0") +
  theme_bw()

# ----------------------------------------------------------
# Tabla resumen — Exponencial vs. log\u00edstico
# ----------------------------------------------------------

tabla_resumen <- tribble(
  ~Aspecto,                ~`Modelo exponencial`,          ~`Modelo logístico`,
  "Supuesto central",      "No hay limitación ambiental",  "Existe limitación por recursos",
  "Parámetro clave",       "r o λ",                        "r y K",
  "Forma de la curva",     "J",                            "Sigmoide",
  "Regulación densidad",   "No",                           "Sí",
  "Aplicación conceptual", "Potencial biótico",            "Crecimiento regulado"
)

tabla_resumen %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

cat("\nModelo log\u00edstico finalizado correctamente.\n")
