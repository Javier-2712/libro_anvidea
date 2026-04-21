# =========================================================
# ANVIDEA - Unidad II
# Capítulo 6 - Patrones de distribución y estimación de la densidad
# ---------------------------------------------------------
# Archivo : 01_casoA_distribucion.R
# Caso    : A. Distribución espacial de Calotropis procera
# =========================================================

cat("\n========================================\n")
cat("Caso A - Distribución espacial\n")
cat("========================================\n")

# ---------------------------------------------------------
# Preparación de los datos
# ---------------------------------------------------------

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(kableExtra)
  library(stringr)
  library(MASS)
})

# Cargar la base de datos
datos <- read_xlsx(archivo_datos, sheet = "poisson")

# Se usa la columna de conteos por cuadrícula
conteos <-
  datos %>%
  dplyr::rename(x = Individuos) %>%
  dplyr::mutate(x = as.integer(x)) %>%
  dplyr::pull(x)

# Estimadores descriptivos
n  <- length(conteos)
N  <- sum(conteos)
mu <- mean(conteos)        # µ estimado
s2 <- stats::var(conteos)  # varianza muestral

# Elaboración de la tabla resumen
resumen <- tibble::tibble(
  `n (cuadrículas)` = n,
  `N (individuos)`  = N,
  `µ (media)`       = mu,
  `s^2 (varianza)`  = s2
)

resumen %>%
  kbl(booktabs  = TRUE,
      digits = c(0, 0, 2, 2),
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# A. Estimación estadística de la distribución espacial
# ---------------------------------------------------------

# ---- 1.1) Prueba de Poisson ----

# Paso 1. Frecuencias observadas, Poisson esperada y contribuciones a chi²
x_max <- max(conteos)

fx <- tibble::tibble(x = conteos) %>%
  count(x, name = "Fx") %>%
  complete(x = 0:x_max, fill = list(Fx = 0)) %>%
  arrange(x)

fx <-
  fx %>%
  mutate(
    Px = dpois(x, mu),
    Ex = n * Px,
    `chi^2 comp` = (Fx - Ex)^2 / Ex
  )

fx %>%
  kbl(booktabs  = TRUE,
      digits = c(0, 0, 2, 1, 2),
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 2. Agrupación automática (0, 1, >=2)
fx_agrup <-
  fx %>%
  mutate(clase = dplyr::case_when(
    x == 0 ~ "0",
    x == 1 ~ "1",
    x >= 2 ~ "\u22652"
  )) %>%
  group_by(clase) %>%
  summarise(
    Fx = sum(Fx),
    Ex = sum(Ex),
    .groups = "drop"
  ) %>%
  mutate(`chi^2 comp` = (Fx - Ex)^2 / Ex)

fx_agrup %>%
  kbl(digits = 2,
      col.names = c("clase", "Fx", "Ex", "chi^2 comp"),
      booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Prueba de hipótesis de aleatoriedad Poisson
chi2  <- sum(fx_agrup$`chi^2 comp`)
gl    <- nrow(fx_agrup) - 1 - 1
p_val <- if (gl > 0) pchisq(chi2, df = gl, lower.tail = FALSE) else NA_real_

tibble::tibble(
  `chi^2 (baj)` = chi2,
  gl            = gl,
  `p-valor`     = p_val
) %>%
  kbl(booktabs  = TRUE, digits = c(2, 0, 3),
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 3. Gráfico: Observado vs. Poisson esperado
obs_exp <-
  fx %>%
  dplyr::select(x, Fx, Ex) %>%
  
  tidyr::pivot_longer(cols = c(Fx, Ex),
                      names_to  = "tipo",
                      values_to = "frecuencia")

ggplot(obs_exp, aes(x = factor(x), y = frecuencia, fill = tipo)) +
  geom_col(position = "dodge") +
  labs(x     = "Individuos por cuadr\u00edcula (x)",
       y     = "Frecuencia",
       fill  = "",
       title = "") +
  theme_bw(base_size = 13)

# Índice de Morisita
IM <- (n * sum(conteos * (conteos - 1))) / (N * (N - 1))

tibble::tibble(
  `I_M (Morisita)` = IM,
  `Interpretacion` = dplyr::case_when(
    is.na(IM) ~ "No calculable (verificar N).",
    IM > 1    ~ "Agrupado",
    IM < 1    ~ "Uniforme",
    TRUE      ~ "Aleatorio"
  )
) %>%
  kbl(booktabs  = TRUE, digits = 3,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---- 1.2) Prueba Binomial Negativa ----

# Paso 1. Estimación del parámetro de agrupamiento k
k_hat <- if (s2 > mu) (mu^2) / (s2 - mu) else NA_real_

tibble::tibble(`k (momentos)` = k_hat) %>%
  kbl(booktabs  = TRUE, digits = 3,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 2. Frecuencias observadas, probabilidades BN y esperadas
fx_BN <- tibble::tibble(x = conteos) %>%
  count(x, name = "Fx") %>%
  complete(x = 0:x_max, fill = list(Fx = 0)) %>%
  arrange(x)

fx_BN <-
  fx_BN %>%
  mutate(
    Px = if (!is.na(k_hat) && k_hat > 0) dnbinom(x, size = k_hat, mu = mu) else NA_real_,
    Ex = n * Px,
    `chi^2 comp` = (Fx - Ex)^2 / Ex
  )

fx_BN %>%
  kbl(booktabs  = TRUE,
      digits = c(0, 0, 3, 3, 3),
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 3. Agrupación automática (0, 1, 2, >=3)
fx_BN_agrup <-
  fx_BN %>%
  mutate(clase = dplyr::case_when(
    x == 0 ~ "0",
    x == 1 ~ "1",
    x == 2 ~ "2",
    x >= 3 ~ "\u22653"
  )) %>%
  group_by(clase) %>%
  summarise(
    Fx = sum(Fx),
    Ex = sum(Ex),
    .groups = "drop"
  ) %>%
  mutate(`chi^2 comp` = (Fx - Ex)^2 / Ex)

fx_BN_agrup %>%
  kbl(digits = 3,
      col.names = c("clase", "Fx", "Ex", "chi^2 comp"),
      booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 4. Bondad de ajuste chi² para BN
k_clases <- sum(!is.na(fx_BN_agrup$Ex))
gl_BN    <- k_clases - 1

chi2_BN <- sum(fx_BN_agrup$`chi^2 comp`, na.rm = TRUE)
p_BN    <- if (gl_BN > 0) pchisq(chi2_BN, df = gl_BN, lower.tail = FALSE) else NA_real_

tibble::tibble(
  `chi^2 (baj BN)` = chi2_BN,
  `gl (BN)`        = gl_BN,
  `p-valor (BN)`   = p_BN
) %>%
  kbl(digits = 3,
      col.names = c("chi^2 (baj BN)", "gl (BN)", "p-valor (BN)"),
      booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 5. Gráfico: Observado vs. BN esperado
obs_exp_BN <-
  fx_BN %>%
  dplyr::select(x, Fx, Ex) %>%
  tidyr::pivot_longer(cols = c(Fx, Ex),
                      names_to  = "tipo",
                      values_to = "frecuencia")

ggplot(obs_exp_BN, aes(x = factor(x), y = frecuencia, fill = tipo)) +
  geom_col(position = "dodge") +
  labs(x     = "Individuos por cuadr\u00edcula (x)",
       y     = "Frecuencia",
       fill  = "",
       title = "") +
  theme_bw(base_size = 13)


# ---- 1.3) Comparación de modelos: Poisson vs. Binomial Negativa ----

df_counts <- data.frame(y = conteos)

mod_pois <- glm(y ~ 1, data = df_counts, family = poisson(link = "log"))
mod_nb   <- tryCatch(glm.nb(y ~ 1, data = df_counts), error = function(e) NULL)

get_row <- function(name, fit) {
  if (is.null(fit)) return(data.frame(Modelo = name, logLik = NA, k = NA, AIC = NA))
  ll <- as.numeric(logLik(fit))
  k  <- attr(logLik(fit), "df")
  data.frame(Modelo = name, logLik = ll, k = k, AIC = AIC(fit))
}

tab <- bind_rows(
  get_row("Poisson (glm)", mod_pois),
  get_row("Binomial Negativa (glm.nb)", mod_nb)
)

minAIC        <- min(tab$AIC, na.rm = TRUE)
tab$Delta_AIC <- tab$AIC - minAIC
tab$wAIC      <- exp(-0.5 * tab$Delta_AIC)
tab$wAIC      <- tab$wAIC / sum(tab$wAIC, na.rm = TRUE)

tab %>%
  mutate(across(where(is.numeric), ~ round(., 3))) %>%
  kbl(align    = c("l", "c", "c", "c", "c", "c"),
      booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---- 2) Índices de dispersión ----

n_quad    <- length(conteos)
ID        <- s2 / mu
chi2_disp <- (n_quad - 1) * ID
p_disp    <- pchisq(chi2_disp, df = n_quad - 1, lower.tail = FALSE)
IC        <- (s2 / mu) - 1
IH        <- NA_real_
m_crowd   <- mu + (s2 / mu) - 1
I_c       <- m_crowd / mu
IM2       <- if (N > 1) n * sum(conteos * (conteos - 1)) / (N * (N - 1)) else NA_real_

diag_tbl <- tibble::tibble(
  `ID = s^2/mu` = ID,
  `IC (D. & M.)` = IC,
  `IH (Holgate)` = IH,
  `Lloyd m*`     = m_crowd,
  `Ic (Lloyd)`   = I_c,
  `Morisita IM`  = IM2,
  `chi^2_disp`   = chi2_disp,
  gl             = n - 1,
  p              = p_disp
)

diag_tbl %>%
  kbl(digits = c(2, 2, 2, 2, 2, 2, 2, 0, 5),
      col.names = c(
        "ID = s^2/mu", "IC (D. & M.)", "IH (Holgate)", "Lloyd m*",
        "Ic (Lloyd)", "Morisita IM", "chi^2_disp", "gl", "p"
      ),
      booktabs = TRUE) %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(
    full_width    = FALSE,
    font_size     = 10,
    latex_options = c("repeat_header")
  )

cat("\nCaso A finalizado correctamente.\n")
