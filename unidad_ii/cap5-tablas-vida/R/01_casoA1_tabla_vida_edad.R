# =========================================================
# ANVIDEA - Capítulo 5
# Tablas de vida y modelos matriciales
# ---------------------------------------------------------
# Archivo : 01_casoA1_tabla_vida_edad.R
# Caso    : A1. Tabla de vida por edades
# =========================================================

cat("\n========================================\n")
cat("Caso A1 - Tabla de vida por edades\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Librerías y lectura de la base de datos
# ---------------------------------------------------------

library(kableExtra)
library(readxl)
library(dplyr)
library(tidyverse)
library(patchwork)
library(ggplot2)

# Base de datos del censo - datos1
datos1 <- readxl::read_excel(archivo_datos, sheet = "cement1") %>%
  transmute(
    id   = as.integer(`INDIVIDUO`),
    nac  = as.integer(`NACIMIENTO`),
    mue  = as.integer(`MUERTE`),
    edad = as.integer(`EDAD INDIVIDUO`),
    sexo = as.character(`SEXO`)
  ) %>%
  mutate(edad = if_else(is.na(edad) & !is.na(mue) &
         !is.na(nac), mue - nac, edad)) %>%
    filter(!is.na(edad), edad >= 0L)    # Garantizar No = 600

nrow(datos1)  # verificación del número de datos1


# ---------------------------------------------------------
# Paso 2) Clases de edad y frecuencias nx
# ---------------------------------------------------------

# Ancho o tamaño de los intervalos de clase
ancho  <- 10

# Cortes o intervalos hasta cubrir la edad máxima observada
cortes <- seq(0, ceiling((max(datos1$edad) + 1) / ancho) *
              ancho, by = ancho)

# Inicio de la tabla de vida con las clases de edad y la frecuencia (nx)
tbl_ini <-
  datos1 %>%
  mutate(
    # índice del intervalo (1,2,3, …)
    bin = cut(edad, breaks = cortes, right = FALSE, include.lowest = TRUE, labels = FALSE),
    # límite inferior del intervalo
    edad_ini = cortes[bin],
    # ¿es el último intervalo?
    es_ultimo = edad_ini == max(cortes) - ancho,
    # etiquetar "a-b" para clases internas y "a+" para la última
    clase = if_else(es_ultimo,
                    paste0(edad_ini, "+"),
                    paste0(edad_ini, "-", edad_ini + ancho - 1))) %>%
  count(clase, edad_ini, name = "nx") %>%
  arrange(edad_ini)

# Mostrar la tabla inicial
tbl_ini %>%
  dplyr::select(-edad_ini) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 3) Cálculo del resto de estimadores de la tabla de vida
# ---------------------------------------------------------

# Organización de la tabla de vida
tabla_vida_sm <-
  tbl_ini %>%
  mutate(
    N0       = sum(nx),
    N_x      = rev(cumsum(rev(nx))),
    Sx       = lead(N_x) / N_x,
    lx       = N_x / N0,
    Lx       = (N_x + lead(N_x)) / 2 * ancho,
    Lx       = if_else(is.na(Lx), (ancho / 2) * last(N_x), Lx),
    Tx       = rev(cumsum(rev(Lx))),
    ex       = Tx / N_x,
    edad_med = edad_ini + ancho / 2
  )

# Mostrar la tabla de vida
tabla_vida_sm %>%
  dplyr::select(-edad_ini, -edad_med) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 4) Gráficos: supervivencia lx y de esperanza de vida ex
# ---------------------------------------------------------

# Figura de supervivencia (lx)
g_lx <- ggplot(tabla_vida_sm, aes(edad_med, lx)) +
  geom_line() + geom_point() +
  labs(x = "Edad (años)", y = expression("Supervivencia"~(l[x])),
       title = "Supervivencia (l\u2093= Nx/No)") +
  theme_bw()

# Figura de esperanza de vida (ex)
g_ex <- ggplot(tabla_vida_sm, aes(edad_med, ex)) +
  geom_line() + geom_point() +
  labs(x = "Edad (años)", y = expression(e[x]~"(años)"),
       title = "Esperanza_vida (e\u2093= Tx/Nx)") +
  theme_bw()

# ---- Unión en panel ----
g_lx + g_ex


# ---------------------------------------------------------
# Paso 5) Comparativo entre sexos — ex y lx
# ---------------------------------------------------------

# Insumos requeridos para la figura (Insumos del Paso 1)
datos1 <- datos1  # Datos del censo al cementerio
ancho  <- 10      # Amplitud de los intervalos de edad en la tv
cortes <- cortes  # Intervalos hasta cubrir la edad máxima observada

# etiquetas para los intervalos (última como "a+")
starts <- head(cortes, -1)
labs   <- paste0(starts, "-", starts + ancho - 1)
labs[length(labs)] <- paste0(starts[length(starts)], "+")

tbl_sex <-
  datos1 %>%
  mutate(
    clase = cut(edad,
                breaks = cortes,
                right = FALSE,
                include.lowest = TRUE,
                labels = labs),
    edad_ini = as.integer(sub("-.*", "", as.character(clase)))
  ) %>%
  count(sexo, clase, edad_ini, name = "nx") %>%
  arrange(sexo, edad_ini)

# Tabla de vida por cada sexo
tv_sex <-
  tbl_sex %>%
  group_by(sexo) %>%
  arrange(edad_ini, .by_group = TRUE) %>%
  mutate(
    N0  = sum(nx),                          # radix por sexo
    N_x = rev(cumsum(rev(nx))),             # supervivientes al inicio del intervalo
    Lx  = (N_x + lead(N_x)) / 2 * ancho,   # años-persona en el intervalo
    Lx  = if_else(is.na(Lx), (ancho / 2) *
                    last(N_x), Lx),         # último intervalo abierto
    Tx  = rev(cumsum(rev(Lx))),
    ex  = Tx / N_x,
    lx  = N_x / N0,
    edad_med = edad_ini + ancho / 2
  ) %>%
  ungroup()

# --- Figuras ---
# 1) Esperanza de vida (e_x) por sexo
g_ex_sex <-
  ggplot(tv_sex, aes(x = edad_med,
                     y = ex,
                     color = sexo)) +
  geom_line() +
  geom_point() +
  labs(x = "Edad (años)",
       y = expression(e[x]~"(años)"),
       color = "Sexo",
       title = "Esperanza_vida (e\u2093)") +
  theme_bw()

# 2) Supervivencia (lx) por sexo
g_lx_sex <-
  ggplot(tv_sex, aes(x = edad_med,
                     y = lx,
                     color = sexo)) +
  geom_line() + geom_point() +
  labs(x = "Edad (años)",
       y = expression(l[x]),
       color = "Sexo",
       title = "Supervivencia (l\u2093 = N\u2093 / N\u2092)") +
  theme_bw()

(g_lx_sex | g_ex_sex) + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Tabla base por sexo
resumen_e0 <-
  tv_sex %>%
  group_by(sexo) %>%
  slice_min(edad_ini, n = 1, with_ties = FALSE) %>%
  transmute(sexo, N0 = N0, e0 = round(ex, 2)) %>%
  ungroup()

# Tabla de la esperanza de vida
resumen_e0 %>%
  kbl(booktabs  = TRUE, digits = 2, align = "c",
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 6) Comparación estadística entre sexos (Bootstrap)
# ---------------------------------------------------------

# Función: calcula e0 desde un vector de edades (misma lógica de la tabla de vida)
e0_from_edades <- function(edades, ancho = 10) {
  edades <- edades[is.finite(edades) & edades >= 0]
  if (length(edades) == 0) return(NA_real_)

  cortes <- seq(0, ceiling((max(edades) + 1) / ancho) * ancho, by = ancho)
  bin <- cut(edades, breaks = cortes, right = FALSE,
             include.lowest = TRUE, labels = FALSE)

  nx <- tabulate(bin, nbins = length(cortes) - 1)
  if (sum(nx) == 0) return(NA_real_)

  N_x <- rev(cumsum(rev(nx)))
  Lx  <- (N_x + dplyr::lead(N_x)) / 2 * ancho
  Lx[is.na(Lx)] <- (ancho / 2) * tail(N_x, 1)
  Tx  <- rev(cumsum(rev(Lx)))

  e0 <- Tx[1] / N_x[1]
  e0
}

edades_M <- datos1$edad[trimws(tolower(datos1$sexo)) == "m"]
edades_F <- datos1$edad[trimws(tolower(datos1$sexo)) == "f"]
nM <- length(edades_M)
nF <- length(edades_F)

e0_M      <- e0_from_edades(edades_M, ancho = ancho)
e0_F      <- e0_from_edades(edades_F, ancho = ancho)
delta_obs <- e0_F - e0_M   # Δe0 = e0(F) - e0(M)

# Bootstrap estratificado
set.seed(123)
B <- 2000

delta_boot <- replicate(B, {
  samp_M <- sample(edades_M, size = nM, replace = TRUE)
  samp_F <- sample(edades_F, size = nF, replace = TRUE)
  e0_from_edades(samp_F, ancho = ancho) - e0_from_edades(samp_M, ancho = ancho)
})

# IC percentil 95%
ci <- quantile(delta_boot, probs = c(0.025, 0.975), na.rm = TRUE)

# p-valor bootstrap aproximado (dos colas) para H0: Δ = 0
pval <- 2 * min(
  mean(delta_boot <= 0, na.rm = TRUE),
  mean(delta_boot >= 0, na.rm = TRUE)
)

ggplot(data.frame(delta = delta_boot), aes(x = delta)) +
  geom_histogram(bins = 40) +
  geom_vline(xintercept = delta_obs, linetype = 2) +
  geom_vline(xintercept = ci, linetype = 3) +
  labs(x = "\u0394 e0 = e0(F) - e0(M)",
       y = "Frecuencia",
       title = "Bootstrap estratificado de la diferencia de e0 entre sexos") +
  theme_bw()

# Resumen numérico
res_boot <- tibble::tibble(
  e0_M              = round(e0_M, 1),
  e0_F              = round(e0_F, 1),
  diff_F_M          = round(delta_obs, 1),
  CI2.5             = round(unname(ci[1]), 1),
  CI97.5            = round(unname(ci[2]), 1),
  valor_p_bootstrap = round(pval, 3),
  B                 = B
)

res_boot %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 7) Comparación entre cementerios
# ---------------------------------------------------------

# Lectura del cementerio 2 (Jardines de Paz)
datos2 <- readxl::read_excel(archivo_datos, sheet = "cement2") %>%
  transmute(
    id   = as.integer(`INDIVIDUO`),
    nac  = as.integer(`NACIMIENTO`),
    mue  = as.integer(`MUERTE`),
    edad = as.integer(`EDAD INDIVIDUO`),
    sexo = as.character(`SEXO`)
  ) %>%
  mutate(edad = if_else(is.na(edad) & !is.na(mue) & !is.na(nac),
                        mue - nac, edad)) %>%
  filter(!is.na(edad), edad >= 0L)

nrow(datos2)

# Clases de edad cementerio 2
cortes <- seq(0, ceiling((max(datos2$edad) + 1) / ancho) * ancho, by = ancho)

tbl_ini2 <-
  datos2 %>%
  mutate(
    bin = cut(edad, breaks = cortes, right = FALSE, include.lowest = TRUE, labels = FALSE),
    edad_ini = cortes[bin],
    es_ultimo = edad_ini == max(cortes) - ancho,
    clase = if_else(es_ultimo,
                    paste0(edad_ini, "+"),
                    paste0(edad_ini, "-", edad_ini + ancho - 1))
  ) %>%
  count(clase, edad_ini, name = "nx") %>%
  arrange(edad_ini)

# Estimadores de tabla de vida cementerio 2
N0  <- sum(tbl_ini2$nx)
N_x <- rev(cumsum(rev(tbl_ini2$nx)))
Sx  <- (dplyr::lead(N_x) / N_x) %>% tidyr::replace_na(0) %>% round(2)
lx  <- round(N_x / N0, 2)
Lx  <- (N_x + dplyr::lead(N_x)) / 2 * ancho
Lx[is.na(Lx)] <- (ancho / 2) * tail(N_x, 1)
Tx  <- rev(cumsum(rev(Lx)))
ex  <- round(Tx / N_x, 1)

tabla_vida_jp <-
  tbl_ini2 %>%
  mutate(
    Nx = N_x, Sx = Sx, lx = lx, Lx = Lx, Tx = Tx, ex = ex,
    edad_med = edad_ini + ancho / 2
  )

tabla_vida_jp %>%
  dplyr::select(-edad_ini, -edad_med) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Combinar y etiquetar
comp <-
  dplyr::bind_rows(
  tabla_vida_sm %>% mutate(cementerio = "San Miguel"),
  tabla_vida_jp %>% mutate(cementerio = "Jardines de Paz")
)

# g_lx: Supervivencia proporcional (l_x)
g_lx <- ggplot(comp, aes(edad_med, lx, color = cementerio)) +
  geom_line() +
  geom_point() +
  labs(x = "Edad (años)", y = expression("Supervivencia"~(l[x])),
       title = "Supervivencia") +
  theme_bw()

# g_ex: Esperanza de vida (e_x)
g_ex <- ggplot(comp, aes(edad_med, ex, color = cementerio)) +
  geom_line() +
  geom_point() +
  labs(x = "Edad (años)", y = expression(e[x]~"(años)"),
       title = "Esperanza_vida") +
  theme_bw()

(g_lx | g_ex) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")


# ---------------------------------------------------------
# Paso 8) Tamaño mínimo de muestra
# ---------------------------------------------------------

# a.) Analítica rápida (media edad al morir como proxy de e0)

alpha  <- 0.05   # 95% de confianza
h_mean <- 1      # margen objetivo (años) para la media
z      <- qnorm(1 - alpha / 2)
s_edad <- stats::sd(datos1$edad, na.rm = TRUE)
n_obs  <- nrow(datos1)

n_req_mean <- ceiling((z * s_edad / h_mean)^2)
h_obs_mean <- z * s_edad / sqrt(n_obs)

tabla <-
  dplyr::tibble(
    Metodo              = "Anal\u00edtico (edad prom.- proxy de e0)",
    `n requerido`       = n_req_mean,
    `n observado`       = n_obs,
    `h objetivo (anos)` = h_mean,
    `h  con n_obs`      = round(h_obs_mean, 2)
  )

# Resultados de la prueba analítica rápida
tabla %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# b.) Bootstrap de e0 con el mismo esquema de tabla de vida

# Función: e0 a partir de edades (mismo esquema de tabla de vida)
e0_edades <- function(edades, ancho = 10) {
  edades <- edades[is.finite(edades) & edades >= 0]
  if (length(edades) == 0) return(NA_real_)

  cortes <- seq(0, ceiling((max(edades) + 1) / ancho) * ancho, by = ancho)

  bin <- cut(edades, breaks = cortes, right = FALSE,
             include.lowest = TRUE, labels = FALSE)

  nx <- tabulate(bin, nbins = length(cortes) - 1)
  if (sum(nx) == 0) return(NA_real_)

  N_x <- rev(cumsum(rev(nx)))
  Lx  <- (N_x + dplyr::lead(N_x)) / 2 * ancho
  Lx[is.na(Lx)] <- (ancho / 2) * tail(N_x, 1)

  Tx <- rev(cumsum(rev(Lx)))
  Tx[1] / N_x[1]
}

set.seed(123)
n_obs  <- nrow(datos1)
grid_n <- seq(min(100, n_obs), n_obs, by = 50)
B      <- 400
h_e0   <- 1

res <- lapply(grid_n, function(ni) {
  e0_vals <- replicate(B, {
    edades_i <- sample(datos1$edad, size = ni, replace = TRUE)
    e0_edades(edades_i, ancho = ancho)
  })
  e0_vals <- e0_vals[is.finite(e0_vals)]
  q <- quantile(e0_vals, probs = c(0.025, 0.5, 0.975), na.rm = TRUE)

  dplyr::tibble(
    n           = ni,
    e0_mediana  = round(unname(q[2]), 2),
    e0_menor    = round(unname(q[1]), 2),
    e0_mayor    = round(unname(q[3]), 2),
    semianchura = round((q[3] - q[1]) / 2, 2)
  )
})

res_boot <- dplyr::bind_rows(res)

# Resultados de la prueba Bootstrap
res_boot %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

ggplot(res_boot, aes(x = n, y = semianchura)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = h_e0, linetype = 2) +
  labs(x     = "Tama\u00f1o de muestra (n tumbas)",
       y     = "Semianchura del IC 95% de e0 (a\u00f1os)",
       title = "") +
  theme_bw()

cat("\nCaso A1 finalizado correctamente.\n")
