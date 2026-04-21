# =========================================================
# ANVIDEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 05_funciones_auxiliares.R
# Propósito: funciones auxiliares para los casos A1, A2, B y C
# =========================================================

# ---------------------------------------------------------
# Utilidades de guardado
# ---------------------------------------------------------

guardar_tabla_excel <- function(lista_tablas, archivo) {
  ruta <- file.path("outputs", "tablas", archivo)
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  
  if (file.exists(ruta)) {
    file.remove(ruta)
  }
  
  writexl::write_xlsx(lista_tablas, path = ruta)
  invisible(ruta)
}

guardar_tablas_excel <- guardar_tabla_excel

guardar_figura <- function(plot, archivo, width = 8, height = 5, dpi = 300) {
  ruta <- file.path("outputs", "figuras", archivo)
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  
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
  nombres_limpios <- tolower(trimws(nombres))
  
  idx_edad <- which(nombres_limpios %in% c(
    "edad", "age", "x",
    "edad individuo", "edad_individuo",
    "edad.individuo", "edad  individuo"
  ))
  
  idx_sexo <- which(nombres_limpios %in% c(
    "sexo", "sex", "genero", "género"
  ))
  
  idx_id <- which(nombres_limpios %in% c(
    "individuo", "id"
  ))
  
  idx_nac <- which(nombres_limpios %in% c(
    "nacimiento", "nac"
  ))
  
  idx_mue <- which(nombres_limpios %in% c(
    "muerte", "mue", "fallecimiento"
  ))
  
  # Caso fiel al libro: cementerios con columnas INDIVIDUO, NACIMIENTO,
  # MUERTE, EDAD INDIVIDUO, SEXO
  if (length(idx_id) > 0 || length(idx_nac) > 0 || length(idx_mue) > 0) {
    
    out <- tibble::tibble(
      id = if (length(idx_id) > 0) suppressWarnings(as.integer(datos[[idx_id[1]]])) else rep(NA_integer_, nrow(datos)),
      nac = if (length(idx_nac) > 0) suppressWarnings(as.integer(datos[[idx_nac[1]]])) else rep(NA_integer_, nrow(datos)),
      mue = if (length(idx_mue) > 0) suppressWarnings(as.integer(datos[[idx_mue[1]]])) else rep(NA_integer_, nrow(datos)),
      edad = if (length(idx_edad) > 0) suppressWarnings(as.integer(datos[[idx_edad[1]]])) else rep(NA_integer_, nrow(datos)),
      sexo = if (length(idx_sexo) > 0) as.character(datos[[idx_sexo[1]]]) else rep(NA_character_, nrow(datos))
    )
    
    # Reconstrucción de edad cuando el dato falta pero existen nacimiento y muerte
    out <- out |>
      dplyr::mutate(
        edad = dplyr::if_else(
          is.na(edad) & !is.na(mue) & !is.na(nac),
          mue - nac,
          edad
        )
      )
    
    return(
      out |>
        dplyr::filter(!is.na(edad), is.finite(edad), edad >= 0)
    )
  }
  
  # Caso genérico
  if (length(idx_edad) == 0) {
    stop(
      "No se encontró columna de edad. ",
      "Se esperaba alguna de estas variantes: 'edad', 'age', 'x', 'EDAD INDIVIDUO'."
    )
  }
  
  out <- datos |>
    dplyr::rename(edad = !!names(datos)[idx_edad[1]]) |>
    dplyr::mutate(edad = as.numeric(edad))
  
  if (length(idx_sexo) > 0) {
    out <- out |>
      dplyr::rename(sexo = !!names(datos)[idx_sexo[1]]) |>
      dplyr::mutate(sexo = as.character(sexo))
  } else {
    out <- out |>
      dplyr::mutate(sexo = NA_character_)
  }
  
  out |>
    dplyr::filter(!is.na(edad), is.finite(edad), edad >= 0)
}

clasificar_cobertura <- function(x, n_clases = 5) {
  x <- as.numeric(x)
  
  if (all(is.na(x))) {
    stop("Cobertura sin valores válidos.")
  }
  
  cortes <- unique(stats::quantile(
    x,
    probs = seq(0, 1, length.out = n_clases + 1),
    na.rm = TRUE
  ))
  
  if (length(cortes) < 2) {
    return(factor(rep("estado_1", length(x)), levels = "estado_1"))
  }
  
  factor(
    cut(
      x,
      breaks = cortes,
      include.lowest = TRUE,
      labels = paste0("estado_", seq_len(length(cortes) - 1))
    ),
    levels = paste0("estado_", seq_len(length(cortes) - 1))
  )
}

# ---------------------------------------------------------
# Tablas de vida
# ---------------------------------------------------------

construir_tabla_vida <- function(edad, ancho = 10) {
  edad <- as.numeric(edad)
  edad <- edad[is.finite(edad) & !is.na(edad) & edad >= 0]
  
  if (length(edad) == 0) {
    stop("No hay edades válidas.")
  }
  
  max_edad <- max(edad)
  limites <- seq(0, ceiling(max_edad / ancho) * ancho + ancho, by = ancho)
  
  clases <- cut(
    edad,
    breaks = limites,
    right = FALSE,
    include.lowest = TRUE
  )
  
  tibble::tibble(clase = clases, edad = edad) |>
    dplyr::count(clase, name = "dx") |>
    tidyr::complete(clase, fill = list(dx = 0)) |>
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
    )
}

parametros_demograficos <- function(df) {
  if (!("x" %in% names(df))) {
    df$x <- seq_len(nrow(df)) - 1
  }
  
  df$lxmx <- df$lx * df$mx
  
  R0 <- sum(df$lxmx, na.rm = TRUE)
  T <- sum(df$x * df$lxmx, na.rm = TRUE) / R0
  
  if (is.na(R0) || R0 <= 0 || is.na(T) || T <= 0) {
    r <- NA_real_
    lambda <- NA_real_
  } else {
    r <- log(R0) / T
    lambda <- exp(r)
  }
  
  tibble::tibble(R0 = R0, T = T, r = r, lambda = lambda)
}

bootstrap_diferencia_e0 <- function(datos, grupo = "sexo", reps = 500, ancho = 10) {
  grupos <- unique(stats::na.omit(datos[[grupo]]))
  
  if (length(grupos) != 2) {
    stop("Se requieren exactamente dos grupos.")
  }
  
  calc_e0 <- function(edades) {
    construir_tabla_vida(edades, ancho)$ex[1]
  }
  
  out <- replicate(reps, {
    g1 <- datos |>
      dplyr::filter(.data[[grupo]] == grupos[1]) |>
      dplyr::pull(edad)
    
    g2 <- datos |>
      dplyr::filter(.data[[grupo]] == grupos[2]) |>
      dplyr::pull(edad)
    
    m1 <- sample(g1, length(g1), replace = TRUE)
    m2 <- sample(g2, length(g2), replace = TRUE)
    
    e1 <- calc_e0(m1)
    e2 <- calc_e0(m2)
    
    c(e0_g1 = e1, e0_g2 = e2, diff = e1 - e2)
  })
  
  tibble::as_tibble(t(out)) |>
    dplyr::mutate(
      grupo_1 = grupos[1],
      grupo_2 = grupos[2],
      replicacion = dplyr::row_number()
    ) |>
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
    stop("S debe tener longitud n - 1.")
  }
  
  M <- matrix(0, n, n)
  M[1, ] <- F
  
  if (n > 1) {
    M[cbind(2:n, 1:(n - 1))] <- S
  }
  
  M
}

`%^%` <- function(M, potencia) {
  M <- as.matrix(M)
  
  if (potencia == 0) {
    return(diag(nrow(M)))
  }
  
  if (potencia == 1) {
    return(M)
  }
  
  out <- M
  for (i in 2:potencia) {
    out <- out %*% M
  }
  
  out
}

proyectar_matriz <- function(M, N0, t_max = 20, prefijo = "c") {
  M <- as.matrix(M)
  N0 <- as.numeric(N0)
  
  if (ncol(M) != length(N0)) {
    stop("Dimensiones incompatibles.")
  }
  
  out <- lapply(0:t_max, function(tt) {
    Nt <- (M %^% tt) %*% matrix(N0, ncol = 1)
    tibble::tibble(
      t = tt,
      !!!stats::setNames(
        as.list(as.numeric(Nt)),
        paste0(prefijo, seq_along(N0))
      )
    )
  })
  
  dplyr::bind_rows(out)
}

analisis_matricial <- function(M) {
  M <- as.matrix(M)
  
  er <- eigen(M)
  i <- which.max(Re(er$values))
  lambda <- Re(er$values[i])
  w <- Re(er$vectors[, i])
  w <- w / sum(w)
  
  el <- eigen(t(M))
  j <- which.max(Re(el$values))
  v <- Re(el$vectors[, j])
  v <- v / v[1]
  
  sens <- outer(v, w) / sum(v * w)
  elas <- (M / lambda) * sens
  
  list(
    lambda = as.numeric(lambda),
    w = matrix(as.numeric(w), ncol = 1),
    v = matrix(as.numeric(v), ncol = 1),
    sensibilidad = sens,
    elasticidad = elas
  )
}
