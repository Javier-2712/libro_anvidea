# =========================================================
# ANVIDEA - Capítulo 2
# Archivo: 04_guardar_salidas_cap2.R
# Propósito: exportar tablas, figuras y objetos finales
#            Solo contiene saveRDS / write_xlsx / ggsave
#            Sin lógica pedagógica ni análisis
# =========================================================

cat("\nGuardando tablas, figuras y objetos del capítulo 2...\n")

# =========================================================
# CASO A — Mesozooplancton estuarino
# =========================================================

# --- Tablas ---
guardar_xlsx(datos_select,      file.path(ruta_tablas, "casoA_datos_select.xlsx"))
guardar_xlsx(datos_filtro,      file.path(ruta_tablas, "casoA_datos_filtro.xlsx"))
guardar_xlsx(biol_rel,          file.path(ruta_tablas, "casoA_biol_rel.xlsx"))
guardar_xlsx(datos_resumidos,   file.path(ruta_tablas, "casoA_datos_resumidos.xlsx"))
guardar_xlsx(datos_resumidos1,  file.path(ruta_tablas, "casoA_datos_resumidos1.xlsx"))
guardar_xlsx(datos_largo,       file.path(ruta_tablas, "casoA_datos_largo.xlsx"))
guardar_xlsx(datos_ancho,       file.path(ruta_tablas, "casoA_datos_ancho.xlsx"))
guardar_xlsx(biol_transformado, file.path(ruta_tablas, "casoA_biol_transformado.xlsx"))
guardar_xlsx(datos_transp,      file.path(ruta_tablas, "casoA_datos_transp.xlsx"))
guardar_xlsx(datos_transp1,     file.path(ruta_tablas, "casoA_datos_transp1.xlsx"))
guardar_xlsx(tabla_abrev,       file.path(ruta_tablas, "casoA_tabla_abrev.xlsx"))
guardar_xlsx(biol1_join,        file.path(ruta_tablas, "casoA_biol1_join.xlsx"))
guardar_xlsx(biol_ancho,        file.path(ruta_tablas, "casoA_biol_ancho.xlsx"))
guardar_xlsx(abundantes,        file.path(ruta_tablas, "casoA_taxones_abundantes.xlsx"))
guardar_xlsx(biol_selec,        file.path(ruta_tablas, "casoA_biol_selec.xlsx"))
guardar_xlsx(datos_resum_A,     file.path(ruta_tablas, "casoA_datos_resum.xlsx"))

# --- Figuras ggplot2 (casoA) ---
figs_casoA <- list(
  fig_densidad_capas       = "casoA_fig_densidad_capas.png",
  fig_densidad_capas_malla = "casoA_fig_densidad_capas_malla.png",
  fig_lineal_ab_dens       = "casoA_fig_lineal_ab_dens.png",
  fig_loess_ab_dens1       = "casoA_fig_loess_ab_dens1.png",
  fig_loess_ab_dens2       = "casoA_fig_loess_ab_dens2.png",
  fig_estacion             = "casoA_fig_estacion.png",
  fig_capas                = "casoA_fig_capas.png",
  fig_capas_facetas        = "casoA_fig_capas_facetas.png",
  fig_salinidad_terciles   = "casoA_fig_salinidad_terciles.png",
  fig_burb_ext             = "casoA_fig_burb_ext.png",
  fig_burb_int             = "casoA_fig_burb_int.png",
  fig_burb_salinidad1      = "casoA_fig_burb_salinidad1.png",
  fig_burb_salinidad2      = "casoA_fig_burb_salinidad2.png"
)

for (nm in names(figs_casoA)) {
  if (exists(nm, inherits = TRUE) && !is.null(get(nm))) {
    guardar_figura(get(nm), figs_casoA[[nm]])
  }
}

# --- Objeto consolidado casoA (.rds) ---
resultado_casoA <- list(
  biol_dim         = dim(biol),
  datos_select     = datos_select,
  datos_filtro     = datos_filtro,
  biol_rel         = biol_rel,
  datos_resumidos  = datos_resumidos,
  datos_resumidos1 = datos_resumidos1,
  datos_largo      = datos_largo,
  datos_ancho      = datos_ancho,
  biol_transformado = biol_transformado,
  datos_transp     = datos_transp,
  datos_transp1    = datos_transp1,
  tabla_abrev      = tabla_abrev,
  biol1_join       = biol1_join,
  biol_ancho       = biol_ancho,
  abundantes       = abundantes,
  biol_selec       = biol_selec,
  datos_resum      = datos_resum_A,
  figuras          = list.files(ruta_figuras, pattern = "^casoA_.*\\.png$",
                                full.names = FALSE)
)

guardar_rds(resultado_casoA, "resultado_casoA.rds")
cat("  [casoA] Objetos guardados.\n")

# =========================================================
# CASO B — Macroinvertebrados bentónicos fluviales
# =========================================================

# --- Tablas ---
guardar_xlsx(biol2,          file.path(ruta_tablas, "casoB_biol2_top15.xlsx"))
guardar_xlsx(biol3,          file.path(ruta_tablas, "casoB_biol3_promedios.xlsx"))
guardar_xlsx(tabla_abrev,    file.path(ruta_tablas, "casoB_tabla_abrev.xlsx"))
guardar_xlsx(tabla_totales,  file.path(ruta_tablas, "casoB_tabla_totales.xlsx"))
guardar_xlsx(amb,            file.path(ruta_tablas, "casoB_amb_replicas.xlsx"))
guardar_xlsx(amb1,           file.path(ruta_tablas, "casoB_amb1_promedios.xlsx"))
guardar_xlsx(datos_resum_B,  file.path(ruta_tablas, "casoB_datos_resum.xlsx"))

# --- Figuras ggplot2 (casoB) ---
figs_casoB <- list(
  fig_dom_familias     = "casoB_fig_dom_familias.png",
  fig_box_sitio        = "casoB_fig_box_sitio.png",
  fig_box_microh       = "casoB_fig_box_microh.png",
  fig_box_sitio_microh = "casoB_fig_box_sitio_microh.png",
  fig_bar_obs          = "casoB_fig_bar_obs.png",
  fig_bar_error        = "casoB_fig_bar_error.png",
  fig_burb_oxigeno     = "casoB_fig_burb_oxigeno.png"
)

for (nm in names(figs_casoB)) {
  if (exists(nm, inherits = TRUE) && !is.null(get(nm))) {
    guardar_figura(get(nm), figs_casoB[[nm]])
  }
}

# --- Objeto consolidado casoB (.rds) ---
resultado_casoB <- list(
  hoja_fisicoquimica = hoja_fq,
  biol1a             = biol[, 1:7],
  biol2              = biol2,
  biol3              = biol3,
  tabla_abrev        = tabla_abrev,
  tabla_totales      = tabla_totales,
  amb                = amb,
  amb1               = amb1,
  datos_resum        = datos_resum_B,
  figuras            = list.files(ruta_figuras, pattern = "^casoB_.*\\.png$",
                                  full.names = FALSE)
)

guardar_rds(resultado_casoB, "resultado_casoB.rds")
cat("  [casoB] Objetos guardados.\n")

cat("Salidas del capítulo 2 guardadas correctamente.\n")
