# =========================================================
# ANVIDEA - Capítulo 5
# Tablas de vida y modelos matriciales
# ---------------------------------------------------------
# Archivo : 02_casoA2_tabla_vida_gotelli.R
# Caso    : A2. Tabla de vida clásica (Gotelli)
# =========================================================

cat("\n========================================\n")
cat("Caso A2 - Tabla de vida clásica (Gotelli)\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 1) Librerías y lectura de la base de datos
# ---------------------------------------------------------

library(tidyverse)
library(readxl)
library(kableExtra)

# Cargar la base de datos con los tres estimadores iniciales (x, Nx, mx)
tabla <- read_excel(archivo_datos, sheet = "gotelli")

# Organización de la tabla inicial
tabla <-
  tabla %>%
  mutate(
    x  = as.numeric(x),
    Nx = as.numeric(Nx),
    mx = as.numeric(mx)
  ) %>%
  arrange(x)

# Mostrar la tabla base requerida
tabla %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 2) Construcción de la tabla de vida hasta la esperanza de vida
# ---------------------------------------------------------

tabla_v <-
  tabla %>%
  mutate(
    Bx      = Nx * mx,
    N0      = first(Nx),
    `mx+1`  = lead(mx, default = 0),   # Requerido para Fx post
    lx      = Nx / N0,
    `lx+1`  = lead(lx, default = 0),
    dx      = lx - `lx+1`,
    qx      = if_else(lx > 0, dx / lx, NA_real_),
    px      = 1 - qx,
    `Nx+1`  = lead(Nx, default = 0),
    Sx      = `Nx+1` / Nx,
    Lx      = (Nx + `Nx+1`) / 2,
    Tx      = rev(cumsum(rev(Lx))),
    ex      = Tx / Nx,
    `lx.mx`   = lx * mx,
    `x.lx.mx` = x  * `lx.mx`
  )

tabla_v %>%
  dplyr::select(x, Nx, mx, Bx, lx, dx, qx, px, Sx,
                `lx.mx`, `x.lx.mx`, Lx, Tx, ex) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 3) Cálculo de estadísticos demográficos
# ---------------------------------------------------------

# 1. Estadísticos generales
Ro    <- sum(tabla_v$`lx.mx`,   na.rm = TRUE)       # Tasa reproductiva neta
Tg    <- sum(tabla_v$`x.lx.mx`, na.rm = TRUE) / Ro  # Tiempo generacional
r_est <- log(Ro) / Tg                               # r estimado

# 2. Función de Euler
euler <-
  function(rr)
  sum(tabla_v$lx * tabla_v$mx *
      exp(-rr * tabla_v$x), na.rm = TRUE) - 1

# 3. Cálculo de r exacto
r      <- uniroot(euler, interval = c(-2, 2))$root
r      <- round(r, 3)

# 4. Cálculo de lambda
lambda <- exp(r)

# 5. Organización de los estadísticos generales
estad <-
  tibble::tibble(
    `Tasa reprod. neta (Ro)` = Ro,
    `Tiempo gen. (T)`        = Tg,
    `r_est = ln(R0)/T`       = r_est,
    `r (Euler)`              = r,
    `Lambda = exp(r)`        = lambda
  )

# 6. Tabulación
estad %>%
  mutate(across(everything(), ~ round(., 3))) %>%
  kbl(booktabs  = TRUE, digits = 2,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# Paso 4) Estimadores de estructura de edad — Fpre, Fpost, cx, vx
# ---------------------------------------------------------

# Extraer S0 (supervivencia inicial)
S0 <- tabla_v %>%
  filter(x == 0) %>%
  pull(Sx) %>%
  .[1]

tabla2 <- tabla_v %>%
  arrange(x) %>%
  mutate(
    # ---------------------------------------------------
    # 1) Fecundidades "listas para matriz"
    # ---------------------------------------------------

    # F(pre): inicia en m1 * S0
    Fpre  = ifelse(x == max(x), 0, S0 * lead(mx)),

    # F(post): alineado como en Excel → Sx * m_{x+1}
    Fpost = ifelse(x == max(x), 0, Sx * lead(mx)),

    # ---------------------------------------------------
    # 2) Distribución estable c(x)
    # ---------------------------------------------------

    lx_e_rx = lx * exp(-r * x),
    cx      = lx_e_rx / sum(lx_e_rx, na.rm = TRUE),

    # ---------------------------------------------------
    # 3) Valor reproductivo v(x)
    # ---------------------------------------------------

    erx_lx      = exp(r * x) / lx,
    e_ry_ly_my  = exp(-r * x) * lx * mx,
    Se_ry_ly_my = rev(cumsum(rev(e_ry_ly_my))),
    vx          = erx_lx * Se_ry_ly_my,
    vx_norm     = vx / vx[1]
  ) %>%
  dplyr::select(
    x, Nx, lx, mx, Sx,
    Fpre, Fpost,
    lx_e_rx, cx,
    vx, vx_norm
  ) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))

# Impresión tabla final
tabla2 %>%
  kbl(digits = 2,
      col.names = c(
        "x", "Nx", "lx", "mx", "Sx",
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

cat("\nCaso A2 finalizado correctamente.\n")
