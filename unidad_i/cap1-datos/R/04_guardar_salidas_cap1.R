# =========================================================
# ANVIDEA - Capítulo 1
# Archivo: 04_guardar_salidas_cap1.R
# Propósito: exportar tablas, figuras y objetos finales
#            Solo contiene saveRDS / write_xlsx / ggsave
#            Sin lógica pedagógica ni análisis
# =========================================================

cat("\nGuardando tablas, figuras y objetos del capítulo 1...\n")

# =========================================================
# CASO A — Mesozooplancton estuarino
# =========================================================

# --- Tablas ---
guardar_xlsx(datos_select,          file.path(ruta_tablas, "casoA_datos_select.xlsx"))
guardar_xlsx(datos_filtro,          file.path(ruta_tablas, "casoA_datos_filtro.xlsx"))
guardar_xlsx(biol_rel,              file.path(ruta_tablas, "casoA_biol_rel.xlsx"))
guardar_xlsx(datos_resumidos,       file.path(ruta_tablas, "casoA_datos_resumidos.xlsx"))
guardar_xlsx(datos_resumidos1,      file.path(ruta_tablas, "casoA_datos_resumidos1.xlsx"))
guardar_xlsx(datos_largo,           file.path(ruta_tablas, "casoA_datos_largo.xlsx"))
guardar_xlsx(datos_ancho,           file.path(ruta_tablas, "casoA_datos_ancho.xlsx"))
guardar_xlsx(biol_transformado,     file.path(ruta_tablas, "casoA_biol_transformado.xlsx"))
guardar_xlsx(datos_transp,          file.path(ruta_tablas, "casoA_datos_transp.xlsx"))
guardar_xlsx(datos_transp1,         file.path(ruta_tablas, "casoA_datos_transp1.xlsx"))
guardar_xlsx(biol1,                 file.path(ruta_tablas, "casoA_biol1_join.xlsx"))
guardar_xlsx(tabla_abrev,           file.path(ruta_tablas, "casoA_tabla_abrev.xlsx"))
guardar_xlsx(biol_ancho,            file.path(ruta_tablas, "casoA_biol_ancho.xlsx"))
guardar_xlsx(abundantes,            file.path(ruta_tablas, "casoA_taxones_abundantes.xlsx"))
guardar_xlsx(biol_selec,            file.path(ruta_tablas, "casoA_biol_selec.xlsx"))
guardar_xlsx(resumen_salinidad,     file.path(ruta_tablas, "casoA_resumen_salinidad.xlsx"))
guardar_xlsx(biol_sal,              file.path(ruta_tablas, "casoA_biol_sal.xlsx"))
guardar_xlsx(tabla_cruce_salinidad, file.path(ruta_tablas, "casoA_cruce_salinidad.xlsx"))

# --- Figuras ---
exportar_figura(fig_estacion,           file.path(ruta_figuras, "casoA_fig_estacion.png"))
exportar_figura(fig_capas,              file.path(ruta_figuras, "casoA_fig_capas.png"))
exportar_figura(fig_capas_facetas,      file.path(ruta_figuras, "casoA_fig_capas_facetas.png"), width = 10, height = 5)
exportar_figura(fig_salinidad_terciles, file.path(ruta_figuras, "casoA_fig_salinidad_terciles.png"))

# --- Objeto consolidado casoA (.rds) ---
resultado_casoA <- list(
  biol_dim              = dim(biol),
  datos_select          = datos_select,
  datos_filtro          = datos_filtro,
  biol_rel              = biol_rel,
  datos_resumidos       = datos_resumidos,
  datos_resumidos1      = datos_resumidos1,
  datos_largo           = datos_largo,
  datos_ancho           = datos_ancho,
  biol_transformado     = biol_transformado,
  datos_transp          = datos_transp,
  datos_transp1         = datos_transp1,
  biol1                 = biol1,
  tabla_abrev           = tabla_abrev,
  biol_ancho            = biol_ancho,
  abundantes            = abundantes,
  biol_selec            = biol_selec,
  resumen_salinidad     = resumen_salinidad,
  biol_sal              = biol_sal,
  tabla_cruce_salinidad = tabla_cruce_salinidad,
  figuras               = list.files(ruta_figuras, pattern = "^casoA_.*\\.png$",
                                     full.names = FALSE)
)

saveRDS(resultado_casoA, file = file.path(ruta_reportes, "resultado_casoA.rds"))
cat("  [casoA] Objetos guardados.\n")

# =========================================================
# CASO B — Macroinvertebrados bentónicos fluviales
# =========================================================

# --- Tablas ---
guardar_xlsx(inv1a,             file.path(ruta_tablas, "casoB_inv1a.xlsx"))
guardar_xlsx(inv2a,             file.path(ruta_tablas, "casoB_inv2a.xlsx"))
guardar_xlsx(inv1,              file.path(ruta_tablas, "casoB_inv1_abundancia.xlsx"))
guardar_xlsx(inv1b,             file.path(ruta_tablas, "casoB_promedios_sitio.xlsx"))
guardar_xlsx(inv2_log,          file.path(ruta_tablas, "casoB_inv2_log.xlsx"))
guardar_xlsx(inv2_long,         file.path(ruta_tablas, "casoB_inv2_long.xlsx"))
guardar_xlsx(inv2_join,         file.path(ruta_tablas, "casoB_inv2_join.xlsx"))
guardar_xlsx(diccionario_abrev, file.path(ruta_tablas, "casoB_diccionario_abrev.xlsx"))
guardar_xlsx(inv2_dom5,         file.path(ruta_tablas, "casoB_inv2_dom5.xlsx"))
guardar_xlsx(fq_cat,            file.path(ruta_tablas, "casoB_fq_cat.xlsx"))
guardar_xlsx(tabla_oxigeno,     file.path(ruta_tablas, "casoB_tabla_oxigeno.xlsx"))
guardar_xlsx(inv_dom_ox,        file.path(ruta_tablas, "casoB_inv_dom_ox.xlsx"))
guardar_xlsx(famil_ambiente,    file.path(ruta_tablas, "casoB_famil_ambiente.xlsx"))

# --- Figuras ---
exportar_figura(fig_dom_familias, file.path(ruta_figuras, "casoB_fig_dom_familias.png"), width = 8,  height = 5)
exportar_figura(fig_dom_ox,       file.path(ruta_figuras, "casoB_fig_dom_ox.png"),       width = 10, height = 6)
exportar_figura(fig_ab_ox,        file.path(ruta_figuras, "casoB_fig_ab_ox.png"),        width = 6,  height = 5)

if (exists("fig_riq_cond",  inherits = TRUE) && !is.null(fig_riq_cond)) {
  exportar_figura(fig_riq_cond,  file.path(ruta_figuras, "casoB_fig_riq_cond.png"),  width = 6, height = 5)
}

if (exists("fig_riq_ancho", inherits = TRUE) && !is.null(fig_riq_ancho)) {
  exportar_figura(fig_riq_ancho, file.path(ruta_figuras, "casoB_fig_riq_ancho.png"), width = 6, height = 5)
}

# --- Objeto consolidado casoB (.rds) ---
resultado_casoB <- list(
  dim_inv1           = dim(inv1),
  dim_inv2           = dim(inv2),
  dim_fq             = dim(fq),
  hoja_fisicoquimica = hoja_fq,
  inv1a              = inv1a,
  inv2a              = inv2a,
  inv1               = inv1,
  inv1b              = inv1b,
  inv2_log           = inv2_log,
  inv2_long          = inv2_long,
  inv2_join          = inv2_join,
  diccionario_abrev  = diccionario_abrev,
  inv2_dom5          = inv2_dom5,
  fq_cat             = fq_cat,
  tabla_oxigeno      = tabla_oxigeno,
  inv_dom_ox         = inv_dom_ox,
  famil_ambiente     = famil_ambiente,
  figuras            = list.files(ruta_figuras, pattern = "^casoB_.*\\.png$",
                                  full.names = FALSE)
)

saveRDS(resultado_casoB, file = file.path(ruta_reportes, "resultado_casoB.rds"))
cat("  [casoB] Objetos guardados.\n")

cat("Salidas del capítulo 1 guardadas correctamente.\n")
