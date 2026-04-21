# =========================================================
# ANVIDEA - Capítulo 5
# Tablas de vida y modelos matriciales
# ---------------------------------------------------------
# Archivo : 03_casoB_modelo_leslie.R
# Caso    : B. Modelo de Leslie
# =========================================================

cat("\n========================================\n")
cat("Caso B - Modelo de Leslie\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1. Estimadores de estructura de edad
# Fpre, Fpost, Sx, cx, vx  (tabla2 del casoA2)
# ---------------------------------------------------------

library(tidyverse)
library(readxl)
library(kableExtra)
library(purrr)

# Impresión de la tabla (tabla2 proviene del casoA2)
tabla2 %>%
  kbl(digits = 2,
      col.names = c(
        "x", "Nx", "lx", "mx", "Sx",
        "F(pre)", "F(post)",
        "lx\u00b7e^{-rx}", "c(x)",
        "v(x)", "v(x) norm"
      ),
      booktabs = TRUE) %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(
    full_width    = FALSE,
    font_size     = 10,
    latex_options = c("repeat_header")
  )


# ---------------------------------------------------------
# Paso 2. Matrices de Leslie: L (pre y post reproductivas)
# ---------------------------------------------------------

# Cargar la base de datos "tabla2"
tabla2 <- read_xlsx(archivo_datos, sheet = "t.vida")

# Vectores necesarios
edades <- tabla2$x        # edades: 0,1,2,3,4
Fpre   <- tabla2$Fpre     # fecundidades pre-reproductivas
Fpost  <- tabla2$Fpost    # fecundidades post-reproductivas
Sx     <- tabla2$Sx       # supervivencia de x -> x+1
k      <- length(edades)  # aquí: 5

# Chequeos mínimos
stopifnot(k >= 2, length(Fpre) >= k, length(Fpost) >= k, length(Sx) >= k - 1)

# =============================
# Matriz de Leslie PRE (4x4)
#  - Trunca la última edad (no aporta fecundidad/continuación)
#  - Subdiagonal inicia en S1 (transición 1->2, 2->3, 3->4)
# =============================
k_pre      <- k - 1                  # 4
edades_pre <- edades[1:k_pre]        # 0..3
Fpre_pre   <- Fpre[1:k_pre]          # Fpre para 0..3

# Subdiagonal PRE: S1, S2, S3 (longitud = k_pre-1)
stopifnot(length(Sx) >= k_pre)
Sx_pre <- Sx[2:k_pre]

L_pre <- matrix(0, nrow = k_pre, ncol = k_pre)
L_pre[1, ] <- Fpre_pre
if (k_pre > 1) {
  L_pre[cbind(2:k_pre, 1:(k_pre - 1))] <- Sx_pre
}

dimnames(L_pre) <- list(paste0("Edad_", edades_pre),
                        paste0("Edad_", edades_pre))

# =============================
# Matriz de Leslie POST (5x5)
#  - Completa (todas las edades)
#  - Subdiagonal inicia en S0 (transición 0->1)
# =============================
L_post <- matrix(0, nrow = k, ncol = k)
L_post[1, ] <- Fpost
if (k > 1) {
  L_post[cbind(2:k, 1:(k - 1))] <- Sx[1:(k - 1)]
}

dimnames(L_post) <- list(paste0("Edad_", edades),
                         paste0("Edad_", edades))

# Impresión
kable(L_pre,
      booktabs = TRUE, digits = 2, align = "c") %>%
  kable_styling(full_width = FALSE, position = "center",
                font_size = 9,
                latex_options = c("hold_position", "scale_down"))

kable(L_post,
      booktabs = TRUE, digits = 2, align = "c") %>%
  kable_styling(full_width = FALSE, position = "center",
                font_size = 9,
                latex_options = c("hold_position", "scale_down"))


# ---------------------------------------------------------
# Paso 3. Modelación matricial multi-edad (pre y post reproductiva)
# ---------------------------------------------------------

# Función modelo_pob para automatizar N(t+1) = L · N(t)
modelo_pob <- function(L, Nt, t) {
  k   <- length(Nt)
  out <- matrix(NA_real_, nrow = t + 1, ncol = k)
  out[1, ] <- Nt
  for (i in 1:t) out[i + 1, ] <- L %*% out[i, ]
  as.data.frame(out) %>%
    purrr::set_names(paste0("Edad_", seq_len(k)))
}


# ---- a.) Proyección post-reproductiva ----

# Paso 1. Vector de edades (Nt) y periodos a proyectar (t)
Nt <- tabla_v$Nx
Nt

t <- 12
t

# Paso 3. Simulación de la proyección N(t+1) = L · N(t)
simulacion <- modelo_pob(as.matrix(L_post), Nt, t)

simulacion <- simulacion %>%
  mutate(Tiempo = 0:(nrow(simulacion) - 1))

simulacion <- simulacion %>%
  dplyr::select(Tiempo, everything())

colnames(simulacion) <- c("Tiempo", "Edad_0", "Edad_1",
                          "Edad_2", "Edad_3", "Edad_4")

head(round(simulacion)) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Formato largo
simulacion_l <- simulacion %>%
  pivot_longer(cols      = -Tiempo,
               names_to  = "Edad",
               values_to = "Abundancia") %>%
  mutate(Abundancia = round(Abundancia, 0))

head(simulacion_l) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 4. Figura de la proyección multi-Edad (post-reproductiva)
ggplot(simulacion_l, aes(x = Tiempo, y = Abundancia, color = Edad)) +
  geom_point(size = 3) +
  geom_line() +
  labs(x     = "Per\u00edodos de tiempo (a\u00f1os)",
       y     = "Densidad (Nx)",
       color = "Edades",
       title = "Proyecci\u00f3n Post-Reproductiva") +
  scale_x_continuous(breaks = seq(min(simulacion_l$Tiempo),
                                  max(simulacion_l$Tiempo), by = 2)) +
  theme_bw() +
  theme(axis.text    = element_text(size = 13),
        axis.title.x = element_text(size = 13),
        axis.title.y = element_text(size = 13),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# Paso 5. Lambda, cx y vx del censo post-reproductivo
A    <- as.matrix(L_post)
eigR <- eigen(A)
posR   <- which.max(Mod(eigR$values))
lambda <- Re(eigR$values[posR])
w      <- Re(eigR$vectors[, posR])
cx     <- w / sum(w)

eigL <- eigen(t(A))
posL   <- which.max(Mod(eigL$values))
v      <- Re(eigL$vectors[, posL])
v_norm <- v / v[1]

if (sum(cx) < 0)     cx     <- -cx
if (v_norm[1] < 0)   v_norm <- -v_norm

r <- log(lambda)

cat("a) Tasa instant\u00e1nea de aumento (r)\n\n")
print(round(r, 6))

cat("\n\nb) Tasa finita post-reproductiva (lambda)\n\n")
print(round(lambda, 6))

cat("\n\nc) Distribuci\u00f3n estable de edades (c_x)\n\n")
print(round(setNames(cx, rownames(A)), 5))

cat("\n\nd) Valor reproductivo normalizado (v_x^norm)\n\n")
print(round(setNames(v_norm, rownames(A)), 5))


# ---- b.) Proyección pre-reproductiva ----

# Paso 3. Simulación pre-reproductiva
Nt_pre <- Nt[1:4]
t_pre  <- 12

simulacion <- modelo_pob(as.matrix(L_pre), Nt_pre, t_pre)

simulacion <- simulacion %>%
  mutate(Tiempo = 0:(nrow(simulacion) - 1))

simulacion <- simulacion %>%
  dplyr::select(Tiempo, everything())

colnames(simulacion) <- c("Tiempo", "Edad_0", "Edad_1",
                          "Edad_2", "Edad_3")

head(round(simulacion)) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Formato largo
simulacion_l <- simulacion %>%
  pivot_longer(cols      = -Tiempo,
               names_to  = "Edad",
               values_to = "Abundancia") %>%
  mutate(Abundancia = round(Abundancia, 0))

head(simulacion_l) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 4. Figura de la proyección multi-Edad (pre-reproductiva)
ggplot(simulacion_l, aes(x = Tiempo, y = Abundancia, color = Edad)) +
  geom_point(size = 3) +
  geom_line() +
  labs(x     = "Per\u00edodos de tiempo (a\u00f1os)",
       y     = "Densidad (Nx)",
       color = "Edades",
       title = "Proyecci\u00f3n Pre-Reproductiva") +
  scale_x_continuous(breaks = seq(min(simulacion_l$Tiempo),
                                  max(simulacion_l$Tiempo), by = 2)) +
  theme_bw() +
  theme(axis.text    = element_text(size = 13),
        axis.title.x = element_text(size = 13),
        axis.title.y = element_text(size = 13),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# Paso 6. Lambda, cx y vx del censo pre-reproductivo
A    <- as.matrix(L_pre)
eigR <- eigen(A)
posR   <- which.max(Mod(eigR$values))
lambda <- Re(eigR$values[posR])
w      <- Re(eigR$vectors[, posR])
cx     <- w / sum(w)

eigL <- eigen(t(A))
posL   <- which.max(Mod(eigL$values))
v      <- Re(eigL$vectors[, posL])
v_norm <- v / v[1]

if (sum(cx) < 0)   cx     <- -cx
if (v_norm[1] < 0) v_norm <- -v_norm

r <- log(lambda)

cat("a) Tasa instant\u00e1nea de aumento (r)\n\n")
print(round(r, 6))

cat("\n\nb) Tasa finita pre-reproductiva (lambda)\n\n")
print(round(lambda, 6))

cat("\n\nc) Distribuci\u00f3n estable de edades (c_x)\n\n")
print(round(setNames(cx, rownames(A)), 4))

cat("\n\nd) Valor reproductivo normalizado (v_x^norm)\n\n")
print(round(setNames(v_norm, rownames(A)), 4))


# ---------------------------------------------------------
# Paso 4. Cálculos especiales: Sensibilidad y Elasticidad
# ---------------------------------------------------------

# ---- a.) Análisis de Sensibilidad ----

L <- as.matrix(L_post)
round(L, 2)

# Matriz de proyección (Leslie post-reproductiva)
L <- as.matrix(L_post)

# 1) Autovalor dominante (λ) y autovector derecho (w)
eigR  <- eigen(L)
posR  <- which.max(Mod(eigR$values))
lambda <- Re(eigR$values[posR])
w     <- Re(eigR$vectors[, posR])

# 2) Autovector izquierdo (v)
eigL <- eigen(t(L))
posL <- which.max(Mod(eigL$values))
v    <- Re(eigL$vectors[, posL])

# 3) Ajuste de signo
if (sum(w) < 0) w <- -w
if (sum(v) < 0) v <- -v

# 4) Normalización biortogonal: v^T w = 1
v <- v / as.numeric(t(v) %*% w)

# 5) Matriz de sensibilidad S_ij
S <- outer(v, w)
round(S, 3)


# ---- b.) Análisis de Elasticidad ----

L <- as.matrix(L_post)
round(L, 2)

E <- (L / lambda) * S
round(E, 3)

sum(E)

cat("\nCaso B finalizado correctamente.\n")
