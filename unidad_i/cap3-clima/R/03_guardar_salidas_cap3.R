# =========================================================
# ANVIDEA - Capítulo 3
# Archivo: 03_guardar_salidas_cap3.R
# Propósito: exportar tablas, figuras y objeto final
#            Solo contiene saveRDS / write_xlsx / ggsave
#            Sin lógica pedagógica ni análisis
# =========================================================

cat("\nGuardando tablas, figuras y objeto final del capítulo 3...\n")

# =========================================================
# 1. Tablas
# =========================================================

guardar_xlsx(tabla_estaciones,   file.path(ruta_tablas, "cap3_tabla_estaciones.xlsx"))
guardar_xlsx(serie_temp_long,    file.path(ruta_tablas, "cap3_serie_temp_long.xlsx"))
guardar_xlsx(serie_temp_interanual, file.path(ruta_tablas, "cap3_serie_temp_interanual.xlsx"))
guardar_xlsx(precip_long,        file.path(ruta_tablas, "cap3_serie_precipit_long.xlsx"))
guardar_xlsx(serie_pp_interanual, file.path(ruta_tablas, "cap3_serie_precipit_interanual.xlsx"))
guardar_xlsx(climatog,           file.path(ruta_tablas, "cap3_clima_base.xlsx"))
guardar_xlsx(ponderaciones,      file.path(ruta_tablas, "cap3_lang_ponderaciones.xlsx"))
guardar_xlsx(lang_tabla,         file.path(ruta_tablas, "cap3_lang_estaciones.xlsx"))
guardar_xlsx(balance,            file.path(ruta_tablas, "cap3_balance_hidrico.xlsx"))
guardar_xlsx(clima_biomas,       file.path(ruta_tablas, "cap3_clima_etp.xlsx"))
guardar_xlsx(resumen,            file.path(ruta_tablas, "cap3_resumen_climatico.xlsx"))
guardar_xlsx(resumen_final,      file.path(ruta_tablas, "cap3_resumen_ecologico_final.xlsx"))

# =========================================================
# 2. Figuras
# =========================================================

guardar_figura(fig_temp_mensual,  "cap3_fig_temp_mensual.png",   width = 8,  height = 7)
guardar_figura(fig_temp_anual,    "cap3_fig_temp_anual.png",     width = 8,  height = 10)
guardar_figura(fig_pp_mensual,    "cap3_fig_precipit_mensual.png", width = 8, height = 7)
guardar_figura(fig_pp_anual,      "cap3_fig_precipit_anual.png", width = 8,  height = 10)
guardar_figura(fig_climatograma,  "cap3_climatograma.png",       width = 10, height = 12)
guardar_figura(fig_lang,          "cap3_fig_lang.png",           width = 8,  height = 6)
guardar_figura(fig_balance,       "cap3_balance_hidrico.png",    width = 8,  height = 10)

# =========================================================
# 3. Tablas resumidas para el reporte
# =========================================================

serie_temp_mensual <-
  serie_temp_long %>%
  dplyr::group_by(Estación, Meses) %>%
  dplyr::summarise(temp_media = mean(Temperatura, na.rm = TRUE), .groups = "drop")

serie_pp_mensual <-
  precip_long %>%
  dplyr::group_by(Estación, Meses) %>%
  dplyr::summarise(pp_media = mean(Precip_mm, na.rm = TRUE), .groups = "drop")

# =========================================================
# 4. Objeto consolidado (.RDS)
# =========================================================

resultado_cap3 <- list(
  tabla_estaciones    = tabla_estaciones,
  serie_temp_long     = serie_temp_long,
  serie_temp_mensual  = serie_temp_mensual,
  serie_temp_anual    = serie_temp_interanual,
  serie_pp_long       = precip_long,
  serie_pp_mensual    = serie_pp_mensual,
  serie_pp_anual      = serie_pp_interanual,
  clima               = climatog,
  lang_ponderaciones  = ponderaciones,
  lang_tabla          = lang_tabla,
  clima_etp           = clima_biomas,
  balance             = balance,
  resumen             = resumen,
  resumen_final       = resumen_final,
  figuras             = list.files(ruta_figuras, pattern = "^cap3_.*png$",  full.names = FALSE),
  tablas              = list.files(ruta_tablas,  pattern = "^cap3_.*xlsx$", full.names = FALSE)
)

guardar_rds(resultado_cap3, "resultado_cap3.RDS")
cat("  [cap3] Objetos guardados.\n")

cat("Salidas del capítulo 3 guardadas correctamente.\n")
