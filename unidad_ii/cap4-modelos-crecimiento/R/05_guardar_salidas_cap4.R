# =========================================================
# ANVIDEA - Capítulo 4
# Archivo: 05_guardar_salidas_cap4.R
# Propósito: exportar tablas y objetos finales
#            Solo contiene guardar_tabla_csv / saveRDS
#            Sin lógica pedagógica ni análisis
# Nota: este capítulo trabaja con simulación, no con datos
#       empíricos. Las figuras se renderizan directamente
#       en el reporte HTML y no se exportan como archivos.
# =========================================================

cat("\nGuardando tablas y objetos del capítulo 4...\n")

# =========================================================
# A.1 — Modelo exponencial continuo
# =========================================================

guardar_tabla_csv(resultados, "cont_estimacion_r_escenarios.csv")
guardar_tabla_csv(tab_largo,  "cont_Td_Tsr_por_r.csv")

cat("  [A.1] Tablas exponencial continuo guardadas.\n")

# =========================================================
# A.2 — Modelo exponencial discreto
# =========================================================

guardar_tabla_csv(tab_lambda, "disc_estimacion_lambda_escenarios.csv")
guardar_tabla_csv(tab_r,      "disc_conversion_lambda_r.csv")

cat("  [A.2] Tablas exponencial discreto guardadas.\n")

# =========================================================
# B — Modelo logístico
# =========================================================

guardar_tabla_csv(tab_bd,        "log_tasas_b_d.csv")
guardar_tabla_csv(tabla_resumen, "log_resumen_comparativo.csv")

cat("  [B] Tablas modelo logístico guardadas.\n")

# =========================================================
# Objeto consolidado cap4 (.rds)
# =========================================================

resultado_cap4 <- list(
  # Exponencial continuo
  resultados_r  = resultados,
  tab_Td_Tsr    = tab_largo,
  # Exponencial discreto
  tab_lambda    = tab_lambda,
  tab_r         = tab_r,
  # Logístico
  tab_bd        = tab_bd,
  tabla_resumen = tabla_resumen
)

saveRDS(resultado_cap4, file = file.path(rep_dir, "resultado_cap4.rds"))
cat("  [cap4] Objeto consolidado guardado.\n")

cat("Salidas del capítulo 4 guardadas correctamente.\n")
