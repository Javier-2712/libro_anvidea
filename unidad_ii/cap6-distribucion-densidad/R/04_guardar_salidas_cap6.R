# =========================================================
# ANVIDEA - Capítulo 6
# Patrones de distribución y estimación de la densidad
# ---------------------------------------------------------
# Archivo : 04_guardar_salidas_cap6.R
# Propósito: exportar tablas y objetos finales del capítulo 6
#            Solo contiene guardar_xlsx / guardar_rds
#            Sin lógica pedagógica ni análisis
# =========================================================

cat("\nGuardando tablas y objetos del cap\u00edtulo 6...\n")

# =========================================================
# CASO A — Patrones de distribución espacial
# =========================================================

# --- Tablas ---
guardar_xlsx(resumen,      file.path(tab_dir, "casoA_estimadores_descriptivos.xlsx"))
guardar_xlsx(fx,           file.path(tab_dir, "casoA_frecuencias_poisson.xlsx"))
guardar_xlsx(fx_agrup,     file.path(tab_dir, "casoA_poisson_agrupada.xlsx"))
guardar_xlsx(fx_BN,        file.path(tab_dir, "casoA_frecuencias_bn.xlsx"))
guardar_xlsx(fx_BN_agrup,  file.path(tab_dir, "casoA_bn_agrupada.xlsx"))
guardar_xlsx(tab,          file.path(tab_dir, "casoA_comparacion_modelos_aic.xlsx"))
guardar_xlsx(diag_tbl,     file.path(tab_dir, "casoA_indices_dispersion.xlsx"))

# Nota: las figuras del casoA no se asignan a objetos (patrón del libro).
# Se renderizan directamente en el reporte HTML.

# --- Objeto consolidado casoA (.rds) ---
resultado_casoA <- list(
  estimadores_descriptivos = resumen,
  frecuencias_poisson      = fx,
  poisson_agrupada         = fx_agrup,
  frecuencias_bn           = fx_BN,
  bn_agrupada              = fx_BN_agrup,
  comparacion_modelos      = tab,
  indices_dispersion       = diag_tbl
)

guardar_rds(resultado_casoA, "resultado_casoA.rds")
cat("  [casoA] Objetos guardados.\n")

# =========================================================
# CASO B — Estimación de la densidad
# =========================================================

# --- Tablas ---
guardar_xlsx(res_ih, file.path(tab_dir, "casoB_holgate_densidad.xlsx"))
guardar_xlsx(res,    file.path(tab_dir, "casoB_king_hayne_densidad.xlsx"))
guardar_xlsx(d,      file.path(tab_dir, "casoB_distancias.xlsx"))

# Nota: las figuras del casoB no se asignan a objetos (patrón del libro).
# Se renderizan directamente en el reporte HTML.

# --- Objeto consolidado casoB (.rds) ---
resultado_casoB <- list(
  holgate_densidad    = res_ih,
  king_hayne_densidad = res,
  distancias          = d
)

guardar_rds(resultado_casoB, "resultado_casoB.rds")
cat("  [casoB] Objetos guardados.\n")

# =========================================================
# Objeto consolidado del capítulo 6
# =========================================================

resultado_cap6 <- list(
  casoA = resultado_casoA,
  casoB = resultado_casoB
)

guardar_rds(resultado_cap6, "resultado_cap6.rds")
cat("  [cap6] Objeto consolidado guardado.\n")

cat("Salidas del cap\u00edtulo 6 guardadas correctamente.\n")
