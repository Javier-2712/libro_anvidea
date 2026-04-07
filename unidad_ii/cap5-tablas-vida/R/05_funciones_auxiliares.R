# =========================================================
# ANDIVEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 05_funciones_auxiliares.R
# Propósito: reunir funciones auxiliares para los casos
#             A1, A2, B y C del capítulo 5
# =========================================================

# ---------------------------------------------------------
# Utilidades de guardado
# ---------------------------------------------------------

guardar_tabla_excel <- function(lista_tablas, archivo) {
  ruta <- file.path("outputs", "tablas", archivo)

  if (!dir.exists(dirname(ruta))) {
    dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  }

  if (file.exists(ruta)) {
    file.remove(ruta)
  }

  writexl::write_xlsx(lista_tablas, path = ruta)
  invisible(ruta)
}

# Alias por compatibilidad con scripts previos
guardar_tablas_excel <- guardar_tabla_excel

guardar_figura <- function(plot, archivo, width = 8, height = 5, dpi = 300) {
  ruta <- file.path("outputs", "figuras", archivo)

  if (!dir.exists(dirname(ruta))) {
    dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  }

  ggplot2::ggsave(
    filename = ruta,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )

  invisible(ruta)
}

# ---------------------------------------------------------
# Lectura y clasificación de datos
# ---------------------------------------------------------

leer_cementerio <- function(archivo, hoja) {
  datos <- readxl::read_excel(archivo, sheet = hoja)

  nombres <- names(datos)
  idx_edad <- which(tolower(nombres) %in% c("edad", "age", "x"))
  idx_sexo <- which(tolower(nombres) %in% c("sexo", "sex", "genero", "género"))

  if (length(idx_edad) == 0) {
    stop("La hoja seleccionada debe incluir una columna de edad ('edad', 'age' o 'x').")
  }

  out <- datos %>%
    dplyr::rename(edad = !!names(datos)[idx_edad[1]]) %>%
    dplyr::mutate(edad = as.numeric(edad))

  if (length(idx_sexo) > 0) {
    out <- out %>%
      dplyr::rename(sexo = !!names(datos)[idx_sexo[1]]) %>%
      dplyr::mutate(sexo = as.character(sexo))
  } else {
    out <- out %>%
      dplyr::mutate(sexo = NA_character_)
  }

  out %>%
    dplyr::filter(!is.na(edad), is.finite(edad), edad >= 0)
}

clasificar_cobertura <- function(x, n_clases = 5) {
  x <- as.numeric(x)

  if (all(is.na(x))) {
    stop("La variable de cobertura no contiene valores válidos.")
  }

  cortes <- unique(stats::quantile(x, probs = seq(0, 1, length.out = n_clases + 1), na.rm = TRUE))

  if (length(cortes) < 2) {
    return(factor(rep("estado_1", length(x)), levels = "estado_1"))
  }

  estados <- cut(
    x,
    breaks = cortes,
    include.lowest = TRUE,
    labels = paste0("estado_", seq_len(length(cortes) - 1))
  )

  factor(estados, levels = paste0("estado_", seq_len(length(cortes) - 1)))
}

# ---------------------------------------------------------
# Tablas de vida
# ---------------------------------------------------------

construir_tabla_vida <- function(edad, ancho = 10) {
  edad <- as.numeric(edad)
  edad <- edad[is.finite(edad) & !is.na(edad) & edad >= 0]

  if (length(edad) == 0) {
    stop("No hay edades válidas para construir la tabla de vida.")
  }

  max_edad <- max(edad, na.rm = TRUE)
  limites <- seq(0, ceiling(max_edad / ancho) * ancho + ancho, by = ancho)

  clases <- cut(
    edad,
    breaks = limites,
    right = FALSE,
    include.lowest = TRUE
  )

  tabla <- tibble::tibble(
    clase = clases,
    edad = edad
  ) %>%
    dplyr::count(clase, name = "dx") %>%
    tidyr::complete(clase, fill = list(dx = 0)) %>%
    dplyr::mutate(
      x = seq(0, by = ancho, length.out = dplyr::n()),
      Nx = rev(cumsum(rev(dx))),
      lx = Nx / dplyr::first(Nx),
      dx_lx = lx - dplyr::lead(lx, default = 0),
      qx = dplyr::if_else(lx > 0, dx_lx / lx, NA_real_),
      px = 1 - qx,
      Lx = (Nx + dplyr::lead(Nx, default = 0)) / 2 * ancho,
      Tx = rev(cumsum(rev(Lx))),
      ex = dplyr::if_else(Nx > 0, Tx / Nx, NA_real_)
    ) %>%
    dplyr::select(x, clase, dx, Nx, lx, dx_lx, qx, px, Lx, Tx, ex)

  tabla
}

tabla_vida_basica <- function(df) {
  if (!all(c("Nx", "mx") %in% names(df))) {
    stop("El objeto debe contener al menos las columnas 'Nx' y 'mx'.")
  }

  if (!("x" %in% names(df))) {
    df <- df %>% dplyr::mutate(x = seq_len(dplyr::n()) - 1)
  }

  paso_edad <- if (nrow(df) > 1) unique(diff(df$x))[1] else 1

  df %>%
    dplyr::mutate(
      lx = Nx / dplyr::first(Nx),
      dx = lx - dplyr::lead(lx, default = 0),
      qx = dplyr::if_else(lx > 0, dx / lx, NA_real_),
      px = 1 - qx,
      Sx = dplyr::lead(Nx, default = 0) / Nx,
      Lx = (Nx + dplyr::lead(Nx, default = 0)) / 2 * paso_edad,
      Tx = rev(cumsum(rev(Lx))),
      ex = Tx / Nx,
      lxmx = lx * mx
    )
}

parametros_demograficos <- function(df) {
  if (!all(c("lx", "mx") %in% names(df))) {
    stop("El objeto debe contener las columnas 'lx' y 'mx'.")
  }

  if (!("x" %in% names(df)) && ("edad" %in% names(df))) {
    df <- dplyr::rename(df, x = edad)
  } else if (!("x" %in% names(df))) {
    df <- df %>% dplyr::mutate(x = seq_len(dplyr::n()) - 1)
  }

  df <- df %>% dplyr::mutate(lxmx = lx * mx)

  R0 <- sum(df$lxmx, na.rm = TRUE)
  T  <- sum(df$x * df$lxmx, na.rm = TRUE) / R0
  r  <- log(R0) / T
  lambda <- exp(r)

  tibble::tibble(R0 = R0, T = T, r = r, lambda = lambda)
}

bootstrap_diferencia_e0 <- function(datos, grupo = "sexo", reps = 500, ancho = 10) {
  if (!(grupo %in% names(datos))) {
    stop("La variable de agrupación no existe en los datos.")
  }

  datos <- datos %>%
    dplyr::filter(!is.na(.data[[grupo]]), !is.na(edad), is.finite(edad), edad >= 0)

  grupos <- unique(datos[[grupo]])

  if (length(grupos) != 2) {
    stop("El bootstrap de diferencia en e0 requiere exactamente dos grupos.")
  }

  calcular_e0 <- function(edades) {
    tv <- construir_tabla_vida(edades, ancho = ancho)
    tv$ex[1]
  }

  out <- replicate(reps, {
    g1 <- datos %>% dplyr::filter(.data[[grupo]] == grupos[1]) %>% dplyr::pull(edad)
    g2 <- datos %>% dplyr::filter(.data[[grupo]] == grupos[2]) %>% dplyr::pull(edad)

    m1 <- sample(g1, size = length(g1), replace = TRUE)
    m2 <- sample(g2, size = length(g2), replace = TRUE)

    e0_1 <- calcular_e0(m1)
    e0_2 <- calcular_e0(m2)

    c(e0_g1 = e0_1, e0_g2 = e0_2, diff = e0_1 - e0_2)
  })

  out <- as.data.frame(t(out))
  out[[grupo]][1] <- NA_character_

  tibble::as_tibble(out) %>%
    dplyr::mutate(
      grupo_1 = grupos[1],
      grupo_2 = grupos[2],
      replicacion = dplyr::row_number()
    ) %>%
    dplyr::relocate(replicacion, grupo_1, grupo_2)
}

# ---------------------------------------------------------
# Matrices demográficas
# ---------------------------------------------------------

construir_matriz_leslie <- function(F, S) {
  F <- as.numeric(F)
  S <- as.numeric(S)

  n <- length(F)

  if (length(S) != n - 1) {
    stop("En una matriz de Leslie, la longitud de S debe ser igual a longitud(F) - 1.")
  }

  M <- matrix(0, nrow = n, ncol = n)
  M[1, ] <- F

  if (n > 1) {
    M[cbind(2:n, 1:(n - 1))] <- S
  }

  M
}

`%^%` <- function(M, potencia) {
  if (!is.matrix(M)) {
    M <- as.matrix(M)
  }

  if (potencia == 0) {
    return(diag(nrow(M)))
  }

  if (potencia == 1) {
    return(M)
  }

  resultado <- M
  for (i in 2:potencia) {
    resultado <- resultado %*% M
  }

  resultado
}

proyectar_matriz <- function(M, N0, t_max = 20) {
  M <- as.matrix(M)
  N0 <- as.numeric(N0)

  if (ncol(M) != length(N0)) {
    stop("La longitud del vector inicial N0 debe coincidir con el número de columnas de la matriz.")
  }

  out <- lapply(0:t_max, function(tt) {
    Nt <- (M %^% tt) %*% matrix(N0, ncol = 1)
    tibble::tibble(
      t = tt,
      !!!stats::setNames(as.list(as.numeric(Nt)), paste0("c", seq_along(N0)))
    )
  })

  dplyr::bind_rows(out)
}

analisis_matricial <- function(M) {
  M <- as.matrix(M)

  eig_right <- eigen(M)
  idx <- which.max(Re(eig_right$values))

  lambda <- Re(eig_right$values[idx])
  w <- Re(eig_right$vectors[, idx])
  w <- w / sum(w)

  eig_left <- eigen(t(M))
  idx_left <- which.max(Re(eig_left$values))
  v <- Re(eig_left$vectors[, idx_left])
  v <- v / v[1]

  sens <- outer(v, w) / as.numeric(sum(v * w))
  elas <- (M / lambda) * sens

  list(
    lambda = as.numeric(lambda),
    w = matrix(as.numeric(w), ncol = 1),
    v = matrix(as.numeric(v), ncol = 1),
    sensibilidad = sens,
    elasticidad = elas
  )
}
