# =========================================================
# ANVIDEA - Capítulo 5
# Tablas de vida y modelos matriciales
# ---------------------------------------------------------
# Archivo : 04_casoC_modelo_lefkovitch.R
# Caso    : C. Modelos estructurados por estados (Lefkovitch)
# =========================================================

cat("\n========================================\n")
cat("Caso C - Modelo de Lefkovitch\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Cargar y explorar datos del censo
# ---------------------------------------------------------

library(tidyverse)
library(readxl)
library(kableExtra)
library(corrplot)
library(broom)
library(purrr)

datos <- readxl::read_excel(archivo_datos,
                            sheet = "caltropis") %>%
  mutate(
    across(c(Long.Tot, Ancho, Radio,
             Cobertura, Semillas), as.numeric))

# Valor mínimos y máximos de coberturas
Cmin  <- min(datos$Cobertura, na.rm = TRUE)
Cmax  <- max(datos$Cobertura, na.rm = TRUE)
ancho <- (Cmax - Cmin) / 5

# Cinco intervalos => seis clases de cobertura
cortes   <- seq(Cmin, Cmax, length.out = 6)
etq      <- paste0("C", 1:5)
interval <- paste0(sprintf("%.2f", cortes[-6]),
                   " - ", sprintf("%.2f", cortes[-1]))

# Mostrar la tabla inicial
head(datos) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 2) ¿Qué variable de estado explica mejor Bx?
# ---------------------------------------------------------

# Matriz de correlación
M <- cor(datos[, 2:6])

corrplot(M, method = "circle",
         type = "lower", insig = "blank",
         order = "AOE", diag = FALSE,
         addCoef.col = "black",
         number.cex = 0.8,
         col = COL2("RdYlBu", 200))

vars_estado <- c("Long.Tot", "Ancho", "Radio", "Cobertura")

cmp <- lapply(vars_estado,
              function(v) {
  modelo <- lm(reformulate(v, "Semillas"), data = datos)
  glance(modelo) %>%
    mutate(variable = v)
}) %>%
  bind_rows() %>%
  dplyr::select(Variable    = variable,
         R.cuadrado  = r.squared,
         Valor.p     = p.value,
         AIC, BIC,
         gl.residual = df.residual) %>%
  arrange(desc(R.cuadrado))

kbl(cmp,
    booktabs  = TRUE, digits = 2,
    longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Elección de la mejor variable de estado: cobertura
mejor_var <- dplyr::first(cmp$Variable)
message("Mejor variable por R\u00b2: ", mejor_var)

# 2.1) Visualización de la relación Semillas vs Cobertura
ggplot(datos, aes(x = Cobertura, y = Semillas)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE) +
  theme_bw() +
  labs(x     = "Cobertura (m\u00b2)",
       y     = "Semillas (Bx)",
       title = "Relaci\u00f3n N\u00famero Semillas (Bx) ~ Cobertura (C)")


# ---------------------------------------------------------
# Paso 3) Definir cinco clases de cobertura
# ---------------------------------------------------------

# 1. Valor mínimo de Cobertura en el censo
Cmin <- min(datos$Cobertura, na.rm = TRUE)

# 2. Valor máximo de Cobertura en el censo
Cmax <- max(datos$Cobertura, na.rm = TRUE)

# 3. Ancho de clase dividiendo el rango total en 5 partes
ancho <- round(((Cmax - Cmin) / 5), 4)

cat("\n- Ancho de clase\n\n")
cat("", ancho, "m\u00b2\n\n")

# 4. Construir los cortes o límites de los intervalos
cortes <- seq(Cmin, Cmax, length.out = 6)

# 5. Crear etiquetas (C1,...,C5) para las 5 clases
etqs <- paste0("C", 1:5)

# 6. Clasificar los individuos en las 5 clases de Cobertura
datos <-
  datos %>%
  mutate(Clase_C = cut(Cobertura,
                       breaks = cortes,
                       labels = etqs,
                       include.lowest = TRUE,
                       right = TRUE))

cat("\n- Clases de estado generadas\n\n")
cat("", paste(levels(datos$Clase_C), collapse = ", "), "\n\n")

# 3.1) Tabla con datos discriminados por cobertura
Cmin   <- min(datos$Cobertura, na.rm = TRUE)
Cmax   <- max(datos$Cobertura, na.rm = TRUE)
ancho  <- (Cmax - Cmin) / 5
cortes <- seq(Cmin, Cmax, length.out = 6)
etq    <- paste0("C", 1:5)

datos <-
  datos %>%
  mutate(Clase_C = cut(Cobertura,
                       breaks = cortes,
                       labels = etq,
                       include.lowest = TRUE,
                       right = TRUE))

kbl(head(datos, 4),
    booktabs  = TRUE, digits = 2,
    longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# 3.1) Histograma con cortes de clase
ggplot(datos, aes(x = Cobertura)) +
  geom_histogram(bins = 30, alpha = 0.6) +
  geom_vline(xintercept = cortes, linetype = 2) +
  labs(x     = "Cobertura (m\u00b2)",
       y     = "Frecuencia de indv. (nx)",
       title = "") +
  theme_bw() +
  annotate("text",
           x     = cortes[-6] + diff(cortes) / 2,
           y     = Inf, vjust = 1.5,
           label = etqs, size = 3)


# ---------------------------------------------------------
# Paso 4) Elaboración de la tabla de vida
# ---------------------------------------------------------

datos <-
  datos %>%
  mutate(Clase_C = cut(Cobertura,
                       breaks = cortes,
                       labels = etqs,
                       include.lowest = TRUE,
                       right = TRUE))

Cmin      <- min(datos$Cobertura, na.rm = TRUE)
Cmax      <- max(datos$Cobertura, na.rm = TRUE)
ancho     <- (Cmax - Cmin) / 5
cortes    <- seq(Cmin, Cmax, length.out = 6)
intervalos <- paste0(
  sprintf("%.2f", cortes[-length(cortes)]), " - ",
  sprintf("%.2f", cortes[-1])
)

# Supervivencia de las semillas, tomada de la bibliografía (0.123%)
s0 <- 0.00123

# 1) Totales de semillas por clase (visión poblacional)
tabla_v <-
  datos %>%
  group_by(Clase_C) %>%
  summarise(
    Clases       = intervalos[as.integer(first(Clase_C))],
    nx           = n(),
    Tot_semillas = sum(Semillas, na.rm = TRUE),
    .groups      = "drop"
  ) %>%
  arrange(Clase_C) %>%
  mutate(Bx = round(Tot_semillas * s0, 0))

kbl(tabla_v,
    booktabs  = TRUE, digits = 2,
    longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

tabla_v$nx
sum(tabla_v$nx)

# 4.1) Tabla de vida hasta la esperanza de vida (ex)
intervalo <- setNames(interval, etq)

tabla_v1 <-
  tabla_v %>%
  mutate(
    x        = as.integer(Clase_C),
    Nx       = rev(cumsum(rev(nx))),
    N0       = first(Nx),
    `Nx+1`   = lead(Nx, default = 0),
    mx       = Bx / Nx,
    `mx+1`   = lead(mx, default = 0),
    Sx       = `Nx+1` / Nx,
    lx       = Nx / N0,
    `lx+1`   = lead(lx, default = 0),
    dx       = lx - `lx+1`,
    qx       = if_else(lx > 0, dx / lx, NA_real_),
    px       = 1 - qx,
    `Nx+1`   = lead(Nx, default = 0),
    Lx       = (Nx + `Nx+1`) / 2,
    Tx       = rev(cumsum(rev(Lx))),
    ex       = Tx / Nx,
    `lx.mx`   = lx * mx,
    `x.lx.mx` = x  * `lx.mx`
  )

tabla_v1 %>%
  dplyr::select(x, Clase_C, Clases, nx, Nx, Bx, lx, dx, qx, px, Sx,
         `lx.mx`, `x.lx.mx`, Lx, Tx, ex) %>%
  kbl(booktabs  = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(
    full_width    = FALSE,
    font_size     = 10,
    latex_options = c("repeat_header")
  )

# 4.2) Estadísticos demográficos basados en la tabla de vida
Ro    <- sum(tabla_v1$`lx.mx`,   na.rm = TRUE)
Tg    <- sum(tabla_v1$`x.lx.mx`, na.rm = TRUE) / Ro
r_est <- log(Ro) / Tg

euler <-
  function(rr)
  sum(tabla_v1$lx * tabla_v1$mx *
      exp(-rr * tabla_v1$x), na.rm = TRUE) - 1

r      <- uniroot(euler, interval = c(-2, 2))$root
r      <- round(r, 3)
lambda <- exp(r)

estad <-
  tibble::tibble(
    `Tasa rep. neta (Ro)`   = Ro,
    `Tiempo g.racional (T)` = Tg,
    `r_est = ln(R0)/T`      = r_est,
    `r (Euler)`             = r,
    `lambda = exp(r)`       = lambda
  )

estad %>%
  mutate(across(everything(), ~ round(., 3))) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 5) Estimadores de estructura de estados
# Fpre, Fpost, cx, vx
# ---------------------------------------------------------

# Primer valor de S_x (primer intervalo x = 1)
S0 <- tabla_v1$Sx[1]

tabla2 <-
  tabla_v1 %>%
  mutate(
    # 1.) Cálculo de F pre y post
    Fpre  = S0 * `mx+1`,
    Fpost = Sx * `mx+1`,

    # 2.) Distribución estable c(x)
    `lx.e_rx` = lx * exp(-r * x),
    cx        = `lx.e_rx` / sum(`lx.e_rx`, na.rm = TRUE),

    # 3.) Valor reproductivo v(x)
    erx_lx      = exp(r * x) / lx,
    `e_ry_ly_my`  = exp(-r * x) * lx * mx,
    `Se_ry_ly_my` = rev(cumsum(rev(`e_ry_ly_my`))),
    vx            = erx_lx * `Se_ry_ly_my`,
    vx_norm       = vx / vx[1]
  ) %>%
  dplyr::select(
    x, Clase_C, Nx, mx, Sx,
    Fpre, Fpost,
    `lx.e_rx`, cx,
    vx, vx_norm
  ) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))

tabla2 %>%
  kbl(digits = 2,
      col.names = c(
        "x", "Clase_C", "Nx", "mx", "Sx",
        "F(pre)", "F(post)",
        "lx\u00b7e^{-rx}", "c(x)",
        "v(x)", "v(x).norm"
      ),
      booktabs = TRUE) %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(
    full_width    = FALSE,
    font_size     = 10,
    latex_options = c("repeat_header")
  )


# ---------------------------------------------------------
# Paso 6) Matrices de Lefkovitch — L (pre y post reproductivas)
# ---------------------------------------------------------

estados <- tabla2$x
Fpre    <- tabla2$Fpre
Fpost   <- tabla2$Fpost
Sx      <- tabla2$Sx
k       <- length(estados)

# Matriz PRE (k-1 x k-1)
k_pre <- k - 1

L_pre <- matrix(0, nrow = k_pre, ncol = k_pre)
L_pre[1, ] <- Fpre[1:k_pre]

if (k_pre > 1) {
  for (i in 2:k_pre) {
    L_pre[i, i - 1] <- Sx[i]
  }
}

dimnames(L_pre) <- list(paste0("Estado_", estados[1:k_pre]),
                        paste0("Estado_", estados[1:k_pre]))

# Matriz POST (k x k)
L_post <- matrix(0, nrow = k, ncol = k)
L_post[1, ] <- Fpost

if (k > 1) {
  for (i in 2:k) {
    L_post[i, i - 1] <- Sx[i - 1]
  }
}

dimnames(L_post) <- list(paste0("Estado_", estados),
                         paste0("Estado_", estados))

kable(L_pre,
      booktabs = TRUE, digits = 2, align = "c") %>%
  kable_styling(full_width = FALSE, position = "center",
                font_size = 10,
                latex_options = c("hold_position", "scale_down"))

kable(L_post,
      booktabs = TRUE, digits = 2, align = "c") %>%
  kable_styling(full_width = FALSE, position = "center",
                font_size = 10,
                latex_options = c("hold_position", "scale_down"))


# ---------------------------------------------------------
# Paso 7) Modelación matricial multiestado (pre y post reproductiva)
# ---------------------------------------------------------

# Función modelo_pob para automatizar N(t+1) = L · N(t)
modelo_pob <- function(L, Nt, t) {
  k   <- length(Nt)
  out <- matrix(NA_real_, nrow = t + 1, ncol = k)
  out[1, ] <- Nt
  for (i in 1:t) out[i + 1, ] <- L %*% out[i, ]
  as.data.frame(out) %>%
    purrr::set_names(paste0("Estado_", seq_len(k)))
}


# ---- 7.1) Proyección post-reproductiva ----

# Paso 1. Vector de estados (Nt) y periodos a proyectar (t)
Nt <- tabla_v1$Nx
Nt

t <- 12
t

# Paso 3. Simulación de la proyección N(t+1) = L · N(t)
simulacion <- modelo_pob(as.matrix(L_post), Nt, t)

simulacion <- simulacion %>%
  mutate(Tiempo = 0:(nrow(simulacion) - 1))

simulacion <- simulacion %>%
  dplyr::select(Tiempo, everything())

colnames(simulacion) <- c("Tiempo",
                          paste0("Estado_",
                                 seq_len(ncol(simulacion) - 1)))

head(round(simulacion)) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Formato largo
simulacion_l <- simulacion %>%
  pivot_longer(cols      = -Tiempo,
               names_to  = "Estado",
               values_to = "Abundancia") %>%
  mutate(Abundancia = round(Abundancia, 0))

head(simulacion_l) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 4. Figura de la proyección multi-Estado (post-reproductiva)
ggplot(simulacion_l, aes(x = Tiempo, y = Abundancia, color = Estado)) +
  geom_point(size = 3) +
  geom_line() +
  labs(x     = "Per\u00edodos",
       y     = expression(log[10]~(Densidad~-~Nx)),
       color = "Estados",
       title = "Proyecci\u00f3n Post-Reproductiva") +
  scale_y_log10() +
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

if (sum(cx) < 0) cx <- -cx

eigL <- eigen(t(A))
posL   <- which.max(Mod(eigL$values))
v      <- Re(eigL$vectors[, posL])
v_norm <- v / v[1]

if (v_norm[1] < 0) v_norm <- -v_norm

r <- log(lambda)

cat("a) Tasa instant\u00e1nea de aumento (r)\n\n")
print(round(r, 6))

cat("\n\nb) Tasa finita post-reproductiva (lambda)\n\n")
print(round(lambda, 6))

cat("\n\nc) Distribuci\u00f3n estable de estados (c_x)\n\n")
print(round(setNames(cx, rownames(A)), 5))

cat("\n\nd) Valor reproductivo normalizado (v_x^norm)\n\n")
print(round(setNames(v_norm, rownames(A)), 5))


# ---- 7.2) Proyección pre-reproductiva ----

# Paso 3. Simulación pre-reproductiva
Nt_pre <- Nt[1:4]
t_pre  <- 12

simulacion <- modelo_pob(as.matrix(L_pre), Nt_pre, t_pre)

simulacion <- simulacion %>%
  mutate(Tiempo = 0:(nrow(simulacion) - 1))

simulacion <- simulacion %>%
  dplyr::select(Tiempo, everything())

colnames(simulacion) <- c("Tiempo",
                          paste0("Estado_",
                                 seq_len(ncol(simulacion) - 1)))

head(round(simulacion)) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Formato largo
simulacion_l <- simulacion %>%
  pivot_longer(cols      = -Tiempo,
               names_to  = "Estado",
               values_to = "Abundancia") %>%
  mutate(Abundancia = round(Abundancia, 0))

head(simulacion_l) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Paso 4. Figura de la proyección multi-Estado (pre-reproductiva)
ggplot(simulacion_l, aes(x = Tiempo, y = Abundancia, color = Estado)) +
  geom_point(size = 3) +
  geom_line() +
  labs(x     = "Per\u00edodos",
       y     = expression(log[10]~(Densidad~-~Nx)),
       color = "Estados",
       title = "Proyecci\u00f3n Pre-Reproductiva") +
  scale_y_log10() +
  scale_x_continuous(breaks = seq(min(simulacion_l$Tiempo),
                                  max(simulacion_l$Tiempo), by = 2)) +
  theme_bw() +
  theme(axis.text    = element_text(size = 13),
        axis.title.x = element_text(size = 13),
        axis.title.y = element_text(size = 13),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

# Paso 5. Lambda, cx y vx del censo pre-reproductivo
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

r     <- log(lambda)
t_dup <- log(2) / r

cat("a) Tasa instant\u00e1nea de aumento (r)\n\n")
print(round(r, 6))

cat("\n\nb) Tasa finita pre-reproductiva (lambda)\n\n")
print(round(lambda, 6))

cat("\n\nc) Distribuci\u00f3n estable de estados (c_x)\n\n")
print(round(setNames(cx, rownames(A)), 5))

cat("\n\nd) Valor reproductivo normalizado (v_x^norm)\n\n")
print(round(setNames(v_norm, rownames(A)), 5))

cat("\n\ne) Tiempo de duplicaci\u00f3n (t_dup)\n\n")
print(round(t_dup, 3))


# ---------------------------------------------------------
# Paso 8) Sensibilidad, Elasticidad y Escenarios de manejo
# ---------------------------------------------------------

# Sensibilidad y Elasticidad (L_post)
L      <- as.matrix(L_post)
eigR   <- eigen(L)
posR   <- which.max(Mod(eigR$values))
lambda <- Re(eigR$values[posR])
w      <- Re(eigR$vectors[, posR])

eigL <- eigen(t(L))
posL <- which.max(Mod(eigL$values))
v    <- Re(eigL$vectors[, posL])

if (sum(w) < 0) w <- -w
if (sum(v) < 0) v <- -v

# Normalización biortogonal: v^T w = 1
v <- v / as.numeric(t(v) %*% w)

# Matriz de sensibilidad
S <- outer(v, w)

# Matriz de elasticidad
E <- (L / lambda) * S

cat("a) Lambda dominante (post)\n\n")
print(round(lambda, 6))

cat("\n\nb) Suma de elasticidades (debe ser 1)\n\n")
print(round(sum(E), 6))

cat("\n\nc) Matriz de Sensibilidad (S_ij)\n\n")
print(round(S, 4))

cat("\n\nd) Matriz de Elasticidad (E_ij)\n\n")
print(round(E, 4))

# 8.3) Escenarios de manejo: simulaciones prospectivas
L0 <- as.matrix(L_post)

# Función para lambda dominante
lambda_dom <- function(M) {
  eg <- eigen(M)
  Re(eg$values[which.max(Mod(eg$values))])
}

lambda_0 <- lambda_dom(L0)

# Escenario 1: Reducción del 30% en la fecundidad dominante
L1      <- L0
L1[1,1] <- 0.70 * L1[1,1]
lambda_1 <- lambda_dom(L1)

# Escenario 2: Reducción del 50% en todas las fecundidades
L2     <- L0
L2[1,] <- 0.50 * L2[1,]
lambda_2 <- lambda_dom(L2)

# Escenario 3: Reducción del 40% en transición temprana
L3      <- L0
L3[2,1] <- 0.60 * L3[2,1]
lambda_3 <- lambda_dom(L3)

c(lambda_base       = lambda_0,
  lambda_reduc_F1   = lambda_1,
  lambda_reduc_Ftotal = lambda_2,
  lambda_reduc_S1   = lambda_3) %>% round(4)

cat("\nCaso C finalizado correctamente.\n")
