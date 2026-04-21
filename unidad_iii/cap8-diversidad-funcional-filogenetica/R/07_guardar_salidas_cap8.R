# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# ---------------------------------------------------------
# Archivo : 07_guardar_salidas_cap8.R
# Propósito: exportar tablas, figuras y objetos finales
#            del capítulo 8. Sin lógica pedagógica.
# =========================================================

cat("\nGuardando tablas y objetos del cap\u00edtulo 8...\n")

# =========================================================
# CASO A — Diversidad funcional cl\u00e1sica
# =========================================================

# Tablas
guardar_xlsx(tabla_fd_indices,
             file.path(tab_dir, "casoA_indices_FD_alpha.xlsx"))
guardar_xlsx(tabla_rao_fd,
             file.path(tab_dir, "casoA_resumen_Rao_FD.xlsx"))
guardar_xlsx(tabla_rao_pd,
             file.path(tab_dir, "casoA_resumen_Rao_PD.xlsx"))
guardar_xlsx(as.data.frame(cwm),
             file.path(tab_dir, "casoA_cwm.xlsx"))
guardar_xlsx(as.data.frame(biol_zona),
             file.path(tab_dir, "casoA_biol_zona.xlsx"))

# RDS
resultado_casoA <- list(
  taxas            = taxas,
  rasgos           = rasgos,
  biol1            = biol1,
  rasgos_fd        = rasgos1,
  abund_site       = abund_site,
  cwm              = cwm,
  fd_alpha         = fd_alpha,
  tabla_fd_indices = tabla_fd_indices,
  biol_zona        = biol_zona,
  fd_dist          = fd_dist,
  pd_dist          = pd_dist,
  rao_out          = rao_out,
  tabla_rao_fd     = tabla_rao_fd,
  tabla_rao_pd     = tabla_rao_pd,
  coord_sitios     = coord_sitios,
  div_completo     = div_completo,
  div_rao_resumen  = div_rao_resumen,
  grupos_funcionales = grupos_funcionales
)
guardar_rds(resultado_casoA, "resultado_casoA.rds")
cat("  [casoA] Objetos guardados.\n")


# =========================================================
# CASO B.1 — Diversidad alfa con n\u00fameros de Hill (iNEXT.3D)
# =========================================================

# Tablas PD
guardar_xlsx(as.data.frame(head(salida_abun2$PDInfo[, 1:9], 6)),
             file.path(tab_dir, "casoB1_PD_info.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun2$PDiNextEst$size_based)),
             file.path(tab_dir, "casoB1_PD_sizebased.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun2$PDiNextEst$coverage_based)),
             file.path(tab_dir, "casoB1_PD_coveragebased.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun2$PDAsyEst)),
             file.path(tab_dir, "casoB1_PD_asymptotico.xlsx"))

# Tablas FD
guardar_xlsx(as.data.frame(salida_abun3$FDInfo),
             file.path(tab_dir, "casoB1_FD_info.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun3$FDiNextEst$size_based)),
             file.path(tab_dir, "casoB1_FD_sizebased.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun3$FDiNextEst$coverage_based)),
             file.path(tab_dir, "casoB1_FD_coveragebased.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun3$FDAsyEst)),
             file.path(tab_dir, "casoB1_FD_asintotico.xlsx"))

# Tablas ObsAsy FD
guardar_xlsx(as.data.frame(head(salida_abun3a)),
             file.path(tab_dir, "casoB1_FD_tau_profiles.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun3b)),
             file.path(tab_dir, "casoB1_FD_q_profiles.xlsx"))

# Figuras PD
guardar_figura(fig_PD_1,   "casoB1_fig_PD_RE_assemblage.png",  width = 9, height = 5)
guardar_figura(fig_PD_2,   "casoB1_fig_PD_RE_orderq.png",      width = 9, height = 5)
guardar_figura(fig_PD_3,   "casoB1_fig_PD_completitud.png",    width = 9, height = 5)
guardar_figura(fig_PD_4,   "casoB1_fig_PD_cov_assemblage.png", width = 9, height = 5)
guardar_figura(fig_PD_5,   "casoB1_fig_PD_cov_orderq.png",     width = 9, height = 5)
guardar_figura(fig_PD_tau, "casoB1_fig_PD_tau_profiles.png",   width = 9, height = 5)

# Figuras FD
guardar_figura(fig_FD_1,   "casoB1_fig_FD_RE_assemblage.png",  width = 9, height = 5)
guardar_figura(fig_FD_2,   "casoB1_fig_FD_RE_orderq.png",      width = 9, height = 5)
guardar_figura(fig_FD_3,   "casoB1_fig_FD_completitud.png",    width = 9, height = 5)
guardar_figura(fig_FD_4,   "casoB1_fig_FD_cov_assemblage.png", width = 9, height = 5)
guardar_figura(fig_FD_5,   "casoB1_fig_FD_cov_orderq.png",     width = 9, height = 5)
guardar_figura(fig_FD_tau, "casoB1_fig_FD_tau_profiles.png",   width = 9, height = 5)
guardar_figura(fig_FD_q,   "casoB1_fig_FD_q_profiles.png",     width = 9, height = 5)

# RDS
resultado_casoB1 <- list(
  biol_PD        = biol_PD,
  biol           = biol,
  biol.dist.alfa = biol.dist.alfa,
  salida_abun2   = salida_abun2,
  salida_abun3   = salida_abun3,
  salida_abun3a  = salida_abun3a,
  salida_abun3b  = salida_abun3b
)
guardar_rds(resultado_casoB1, "resultado_casoB1.rds")
cat("  [casoB.1] Objetos guardados.\n")


# =========================================================
# CASO B.2 — Diversidad beta con n\u00fameros de Hill (iNEXTbeta.3D)
# =========================================================

# Tablas PD beta
guardar_xlsx(as.data.frame(head(salida.abun21$M_vs_P$gamma)),
             file.path(tab_dir, "casoB2_PD_cov_gamma_MvsP.xlsx"))
guardar_xlsx(as.data.frame(head(salida.abun22$M_vs_P$gamma)),
             file.path(tab_dir, "casoB2_PD_size_gamma_MvsP.xlsx"))
guardar_xlsx(as.data.frame(informacion_gral_PD),
             file.path(tab_dir, "casoB2_PD_datainfo.xlsx"))

# Tablas FD beta
guardar_xlsx(as.data.frame(head(salida_abun31$M_vs_P$gamma)),
             file.path(tab_dir, "casoB2_FD_cov_gamma_MvsP.xlsx"))
guardar_xlsx(as.data.frame(head(salida_abun32$M_vs_P$gamma)),
             file.path(tab_dir, "casoB2_FD_size_gamma_MvsP.xlsx"))
guardar_xlsx(as.data.frame(informacion_gral_FD),
             file.path(tab_dir, "casoB2_FD_datainfo_tau.xlsx"))
guardar_xlsx(as.data.frame(informacion_gral_FD1),
             file.path(tab_dir, "casoB2_FD_datainfo_AUC.xlsx"))

# Figuras PD beta
guardar_figura(fig_PD_beta_cov,  "casoB2_fig_PD_beta_cobertura.png", width = 9, height = 6)
guardar_figura(fig_PD_beta_size, "casoB2_fig_PD_beta_tamano.png",    width = 9, height = 6)

# Figuras FD beta
guardar_figura(fig_FD_beta_cov,  "casoB2_fig_FD_beta_cobertura.png", width = 9, height = 6)
guardar_figura(fig_FD_beta_size, "casoB2_fig_FD_beta_tamano.png",    width = 9, height = 6)

# RDS
resultado_casoB2 <- list(
  biol_PD           = biol_PD,
  biol_FD_beta      = biol_FD_beta,
  arbol_PD          = arbol_PD,
  biol.dist.beta    = biol.dist.beta,
  salida.abun21     = salida.abun21,
  salida.abun22     = salida.abun22,
  salida_abun31     = salida_abun31,
  salida_abun32     = salida_abun32,
  informacion_gral_PD  = informacion_gral_PD,
  informacion_gral_FD  = informacion_gral_FD,
  informacion_gral_FD1 = informacion_gral_FD1
)
guardar_rds(resultado_casoB2, "resultado_casoB2.rds")
cat("  [casoB.2] Objetos guardados.\n")


# =========================================================
# Objeto consolidado del cap\u00edtulo 8
# =========================================================

resultado_cap8 <- list(
  casoA  = resultado_casoA,
  casoB1 = resultado_casoB1,
  casoB2 = resultado_casoB2
)

guardar_rds(resultado_cap8, "resultado_cap8.rds")
cat("  [cap8] Objeto consolidado guardado.\n")
cat("Salidas del cap\u00edtulo 8 guardadas correctamente.\n")
