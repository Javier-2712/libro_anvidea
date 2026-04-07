#' Balance hídrico mensual tipo Thornthwaite–Mather (simplificado)
#'
#' @param df   Data frame con columnas:
#'             estacion, mes (ENE..DIC), temp (°C), pp (mm),
#'             horas_luz (h/día), dias_mes (días/mes).
#' @param S_max Capacidad de almacenamiento de agua en el suelo (mm). Default 100.
#' @param corr_horas_dias  Si TRUE aplica corrección por días del mes y horas de luz. Default TRUE.
#' @return tibble con columnas originales + etp_base, etp_cor, ETR, Déficit, Excedentes, Reserva.
#' @details
#'   1) Calcula el índice de calor anual I = sum( (T_i/5)^1.514, T_i>0 ).
#'   2) a = 6.75e-7 I^3 - 7.71e-5 I^2 + 1.792e-2 I + 0.49239
#'   3) ETP_base = 16 * (10*T/I)^a   (base 30 días y 12 h)
#'   4) ETP_cor = ETP_base * (dias_mes/30) * (horas_luz/12) si corr_horas_dias=TRUE
#'   5) Bucket de suelo (S_max) para ETR, Déficit, Excedentes, Reserva.
bal_hid <- function(df, S_max = 100, corr_horas_dias = TRUE) {
  stopifnot(all(c("estacion","mes","temp","pp","horas_luz","dias_mes") %in% names(df)))
  
  # ordenar meses y limpiar NA de mes
  meses_orden <- c("ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC")
  df <- df |>
    dplyr::mutate(
      mes = toupper(as.character(mes)),
      mes = factor(mes, levels = meses_orden, ordered = TRUE),
      temp_pos = pmax(temp, 0)
    ) |>
    dplyr::filter(!is.na(mes)) |>
    dplyr::arrange(estacion, mes)
  
  # 1) Índice de calor anual I por estación
  I_tab <- df |>
    dplyr::group_by(estacion) |>
    dplyr::summarise(I = sum( (temp_pos/5)^1.514, na.rm = TRUE), .groups = "drop")
  
  # 2) Coeficiente a(I)
  thornthwaite_a <- function(I) 6.75e-7*I^3 - 7.71e-5*I^2 + 1.792e-2*I + 0.49239
  
  df2 <- df |>
    dplyr::left_join(I_tab, by = "estacion") |>
    dplyr::mutate(
      a_tw     = thornthwaite_a(I),
      etp_base = dplyr::if_else(I > 0, 16 * ( (10 * temp_pos / I)^a_tw ), 0),
      etp_cor  = if (corr_horas_dias) etp_base * (dias_mes/30) * (horas_luz/12) else etp_base
    )
  
  # 3) Balance hídrico mensual por estación
  bal_one <- function(d) {
    d <- d[order(d$mes), ]
    n <- nrow(d)
    S       <- numeric(n)
    ETR     <- numeric(n)
    Deficit <- numeric(n)
    Exced   <- numeric(n)
    
    # condición inicial: suelo a capacidad
    S[1] <- S_max
    P1 <- d$pp[1]; PET1 <- d$etp_cor[1]
    
    if (is.na(P1)) P1 <- 0
    if (is.na(PET1)) PET1 <- 0
    
    if (P1 >= PET1) {
      recarga  <- min(S_max - S[1], P1 - PET1)
      S[1]     <- S[1] + max(recarga, 0)
      ETR[1]   <- PET1
      Deficit[1] <- 0
      Exced[1] <- max(0, (P1 - PET1) - recarga)
    } else {
      uso <- min(S[1], PET1 - P1)
      ETR[1] <- P1 + uso
      S[1]   <- S[1] - uso
      Deficit[1] <- PET1 - ETR[1]
      Exced[1]   <- 0
    }
    
    if (n >= 2) {
      for (t in 2:n) {
        P <- d$pp[t]; PET <- d$etp_cor[t]
        if (is.na(P)) P <- 0
        if (is.na(PET)) PET <- 0
        S[t] <- S[t-1]
        if (P >= PET) {
          rec <- min(S_max - S[t], P - PET)
          S[t] <- S[t] + max(rec, 0)
          ETR[t] <- PET
          Deficit[t] <- 0
          Exced[t] <- max(0, (P - PET) - rec)
        } else {
          uso <- min(S[t], PET - P)
          ETR[t] <- P + uso
          S[t]   <- S[t] - uso
          Deficit[t] <- PET - ETR[t]
          Exced[t]   <- 0
        }
      }
    }
    
    dplyr::mutate(d,
                  Reserva = S,
                  ETR = ETR,
                  `Déficit` = Deficit,
                  Excedentes = Exced
    )
  }
  
  out <- df2 |>
    dplyr::group_by(estacion) |>
    dplyr::group_modify(~ bal_one(.x)) |>
    dplyr::ungroup()
  
  return(out)
}
