# =========================================================
# ANDIVEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 02_casoA2_tabla_vida_gotelli.R
# Propósito: construir una tabla de vida clásica y derivar
#             estimadores demográficos y matriciales
#             a partir de datos modificados de Gotelli
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

archivo_datos <- file.path(data_dir, "datos.c5.xlsx")

message("→ Leyendo datos clásicos modificados de Gotelli...")

# ---------------------------------------------------------
# Paso 1. Lectura y validación de la base
# ---------------------------------------------------------
tabla <- readxl::read_excel(archivo_datos, sheet = "gotelli") %>%
  dplyr::mutate(
    x  = as.numeric(x),
    Nx = as.numeric(Nx),
    mx = as.numeric(mx)
  ) %>%
  dplyr::filter(
    !is.na(x), !is.na(Nx), !is.na(mx),
    is.finite(x), is.finite(Nx), is.finite(mx),
    x >= 0, Nx > 0, mx >= 0
  ) %>%
  dplyr::arrange(x)

if (nrow(tabla) < 2) {
  stop("La hoja 'gotelli' debe contener al menos dos clases de edad.")
}

if (!all(diff(tabla$x) >= 0)) {
  stop("La variable 'x' debe estar ordenada de menor a mayor.")
}

# Ancho temporal del intervalo
dx <- unique(diff(tabla$x))
paso_edad <- if (length(dx) == 1) dx else 1

# ---------------------------------------------------------
# Paso 2. Construcción de la tabla de vida
# ---------------------------------------------------------
message("→ Construyendo tabla de vida y estimadores demográficos básicos...")

tabla_vida <- tabla %>%
  dplyr::mutate(
    Bx        = Nx * mx,
    N0        = dplyr::first(Nx),
    Nx_next   = dplyr::lead(Nx, default = 0),
    mx_next   = dplyr::lead(mx, default = 0),
    lx        = Nx / N0,
    lx_next   = dplyr::lead(lx, default = 0),
    dx_lx     = lx - lx_next,
    qx        = dplyr::if_else(lx > 0, dx_lx / lx, NA_real_),
    px        = 1 - qx,
    Sx        = dplyr::if_else(Nx > 0, Nx_next / Nx, NA_real_),
    Lx        = (Nx + Nx_next) / 2 * paso_edad,
    Tx        = rev(cumsum(rev(Lx))),
    ex        = Tx / Nx,
    lx_mx     = lx * mx,
    x_lx_mx   = x * lx_mx
  )

# ---------------------------------------------------------
# Paso 3. Estadísticos demográficos generales
# ---------------------------------------------------------
message("→ Calculando R0, T, r y lambda...")

R0 <- sum(tabla_vida$lx_mx, na.rm = TRUE)
Tg <- sum(tabla_vida$x_lx_mx, na.rm = TRUE) / R0
r_est <- log(R0) / Tg

euler_lotka <- function(rr) {
  sum(tabla_vida$lx * tabla_vida$mx * exp(-rr * tabla_vida$x), na.rm = TRUE) - 1
}

# Búsqueda robusta del intervalo para uniroot
intervalos <- list(
  c(-5, 5), c(-3, 3), c(-2, 2), c(-1, 1), c(0, 2), c(-2, 0)
)

r <- NA_real_
for (int in intervalos) {
  f1 <- euler_lotka(int[1])
  f2 <- euler_lotka(int[2])
  if (is.finite(f1) && is.finite(f2) && f1 * f2 < 0) {
    r <- uniroot(euler_lotka, interval = int)$root
    break
  }
}

if (is.na(r)) {
  warning("No se encontró raíz para la ecuación de Euler-Lotka; se usará r_est.")
  r <- r_est
}

lambda <- exp(r)

estadisticos <- tibble::tibble(
  R0 = R0,
  T = Tg,
  r_est = r_est,
  r = r,
  lambda = lambda
)

# ---------------------------------------------------------
# Paso 4. Estimadores de estructura de edades
# ---------------------------------------------------------
message("→ Calculando fecundidades, distribución estable y valor reproductivo...")

S0 <- tabla_vida$Sx[1]

estructura_edad <- tabla_vida %>%
  dplyr::mutate(
    Fpre      = dplyr::if_else(dplyr::row_number() < dplyr::n(), S0 * mx_next, 0),
    Fpost     = dplyr::if_else(dplyr::row_number() < dplyr::n(), Sx * mx_next, 0),
    lx_e_rx   = lx * exp(-r * x),
    cx        = lx_e_rx / sum(lx_e_rx, na.rm = TRUE),
    erx_lx    = exp(r * x) / lx,
    e_ry_ly_my  = exp(-r * x) * lx * mx,
    Se_ry_ly_my = rev(cumsum(rev(e_ry_ly_my))),
    vx        = erx_lx * Se_ry_ly_my,
    vx_norm   = vx / vx[1]
  ) %>%
  dplyr::select(
    x, Nx, mx, lx, Sx,
    Fpre, Fpost,
    lx_e_rx, cx,
    vx, vx_norm
  )

# ---------------------------------------------------------
# Paso 5. Matriz de Leslie
# ---------------------------------------------------------
message("→ Construyendo matriz de Leslie y proyección poblacional...")

n_clases <- nrow(tabla_vida)

L_pre <- matrix(0, nrow = n_clases, ncol = n_clases)
L_post <- matrix(0, nrow = n_clases, ncol = n_clases)

L_pre[1, ] <- estructura_edad$Fpre
L_post[1, ] <- estructura_edad$Fpost

if (n_clases > 1) {
  for (i in 2:n_clases) {
    L_pre[i, i - 1] <- tabla_vida$Sx[i - 1]
    L_post[i, i - 1] <- tabla_vida$Sx[i - 1]
  }
}

# Análisis propio de la matriz pre-reproductiva
eig_right <- eigen(L_pre)
idx_dom <- which.max(Re(eig_right$values))

lambda_mat <- Re(eig_right$values[idx_dom])
w <- Re(eig_right$vectors[, idx_dom])
w <- w / sum(w)

eig_left <- eigen(t(L_pre))
idx_left <- which.max(Re(eig_left$values))
v <- Re(eig_left$vectors[, idx_left])
v <- v / v[1]

dist_estable_matriz <- tibble::tibble(
  x = tabla_vida$x,
  cx_matriz = as.numeric(w)
)

valor_reproductivo_matriz <- tibble::tibble(
  x = tabla_vida$x,
  vx_matriz = as.numeric(v)
)

comparacion_vectores <- estructura_edad %>%
  dplyr::select(x, cx, vx_norm) %>%
  dplyr::left_join(dist_estable_matriz, by = "x") %>%
  dplyr::left_join(valor_reproductivo_matriz, by = "x") %>%
  dplyr::rename(vx_matriz_norm = vx_matriz)

# ---------------------------------------------------------
# Paso 6. Proyección poblacional
# ---------------------------------------------------------
n0 <- as.matrix(tabla_vida$Nx, ncol = 1)
tiempos <- 0:10

proyeccion_lista <- lapply(tiempos, function(tt) {
  Nt <- (L_pre %^% tt) %*% n0
  tibble::tibble(
    tiempo = tt,
    x = tabla_vida$x,
    N = as.numeric(Nt)
  )
})

proyeccion <- dplyr::bind_rows(proyeccion_lista)

# ---------------------------------------------------------
# Paso 7. Figuras
# ---------------------------------------------------------
message("→ Guardando figuras del caso A2...")

g_super <- ggplot2::ggplot(tabla_vida, ggplot2::aes(x, lx)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::geom_point(size = 2) +
  ggplot2::labs(
    title = "Supervivencia proporcional por edad",
    x = "Edad (x)",
    y = "l[x]"
  ) +
  ggplot2::theme_bw()

g_vida <- ggplot2::ggplot(tabla_vida, ggplot2::aes(x, ex)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::geom_point(size = 2) +
  ggplot2::labs(
    title = "Esperanza de vida por edad",
    x = "Edad (x)",
    y = "e[x]"
  ) +
  ggplot2::theme_bw()

g_proj <- ggplot2::ggplot(proyeccion, ggplot2::aes(tiempo, N, color = factor(x))) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::labs(
    title = "Proyección matricial por clases de edad",
    x = "Tiempo",
    y = "Número de individuos",
    color = "Edad"
  ) +
  ggplot2::theme_bw()

g_vect <- comparacion_vectores %>%
  tidyr::pivot_longer(
    cols = c(cx, cx_matriz, vx_norm, vx_matriz_norm),
    names_to = "estimador",
    values_to = "valor"
  ) %>%
  ggplot2::ggplot(ggplot2::aes(x, valor, color = estimador)) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::geom_point(size = 2) +
  ggplot2::labs(
    title = "Comparación de vectores demográficos",
    x = "Edad (x)",
    y = "Valor"
  ) +
  ggplot2::theme_bw()

guardar_figura(g_super, "cap5_gotelli_supervivencia.png", width = 7, height = 5)
guardar_figura(g_vida, "cap5_gotelli_esperanza_vida.png", width = 7, height = 5)
guardar_figura(g_proj, "cap5_gotelli_proyeccion_leslie.png", width = 8, height = 5)
guardar_figura(g_vect, "cap5_gotelli_vectores_demograficos.png", width = 8, height = 5)

# ---------------------------------------------------------
# Paso 8. Exportación de tablas
# ---------------------------------------------------------
message("→ Exportando tablas del caso A2...")

matriz_pre_df <- as.data.frame(L_pre)
colnames(matriz_pre_df) <- paste0("edad_", tabla_vida$x)
matriz_pre_df <- tibble::add_column(matriz_pre_df, clase = paste0("edad_", tabla_vida$x), .before = 1)

matriz_post_df <- as.data.frame(L_post)
colnames(matriz_post_df) <- paste0("edad_", tabla_vida$x)
matriz_post_df <- tibble::add_column(matriz_post_df, clase = paste0("edad_", tabla_vida$x), .before = 1)

guardar_tabla_excel(
  list(
    base_gotelli = tabla,
    tabla_vida_gotelli = tabla_vida,
    estadisticos_demograficos = estadisticos,
    estructura_edad = estructura_edad,
    matriz_leslie_pre = matriz_pre_df,
    matriz_leslie_post = matriz_post_df,
    comparacion_vectores = comparacion_vectores,
    proyeccion_poblacional = proyeccion
  ),
  archivo = "cap5_gotelli_tablas.xlsx"
)

message("✔ Capítulo 5 - Caso A2 ejecutado correctamente")
