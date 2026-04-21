# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# ---------------------------------------------------------
# Archivo : 08_guardar_salidas_cap7.R
# Propósito: exportar TODAS las tablas, figuras y objetos
#            del capítulo 7 hacia outputs/tablas/ y outputs/figuras/
# =========================================================

cat("\nGuardando tablas y objetos del cap\u00edtulo 7...\n")

# =========================================================
# CASO A.1 — Diversidad alfa clásica y curvas RAD
# =========================================================

# --- Tablas ---
guardar_xlsx(biol_head,
             file.path(tab_dir, "casoA1_biol_head_6sitios.xlsx"))
guardar_xlsx(tabla_resumen,
             file.path(tab_dir, "casoA1_especies_abrev_abundancia.xlsx"))
guardar_xlsx(as.data.frame(biol2[, 1:12]),
             file.path(tab_dir, "casoA1_matriz_zonas_especies.xlsx"))
guardar_xlsx(d.alfa,
             file.path(tab_dir, "casoA1_diversidad_alfa_zonas.xlsx"))
guardar_xlsx(head(biol_rad, 20),
             file.path(tab_dir, "casoA1_biol_rad_top20.xlsx"))

# Tabla modelo menor AIC por sitio
tab_aic <- tibble::tibble(
  Sitio = c("M", "P", "RM"),
  Modelo_Menor_AIC = c(
    names(which.min(sapply(mod.mountains$models, AIC))),
    names(which.min(sapply(mod.plains$models,    AIC))),
    names(which.min(sapply(mod.mouth$models,     AIC)))
  )
)
guardar_xlsx(tab_aic, file.path(tab_dir, "casoA1_radfit_modelo_menor_AIC.xlsx"))

# Diagnóstico de supuestos — capturar como data frames
tab_anova_disper <- as.data.frame(anova(disper))
tab_permutest    <- as.data.frame(permutest(disper)$tab)
tab_dw           <- data.frame(
  Estadistico = durbinWatsonTest(modelo)$dw,
  p_valor     = durbinWatsonTest(modelo)$p
)
guardar_xlsx(tab_anova_disper, file.path(tab_dir, "casoA1_anova_betadisper.xlsx"))
guardar_xlsx(tab_permutest,    file.path(tab_dir, "casoA1_permutest_betadisper.xlsx"))
guardar_xlsx(tab_dw,           file.path(tab_dir, "casoA1_durbinwatson.xlsx"))

# --- Figuras ---
guardar_figura(fig_rad1, "casoA1_fig_rad_simple.png",   width = 12, height = 5)
guardar_figura(fig_rad2, "casoA1_fig_rad_mejorado.png", width = 12, height = 5)

png(file.path(fig_dir, "casoA1_fig_radfit_todos.png"),
    width = 12, height = 4, units = "in", res = 300)
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(mod.mountains, main = "RAD - M",  ylab = "log10(Ab. relativa)", xlab = "Rangos")
plot(mod.plains,    main = "RAD - P",  ylab = "log10(Ab. relativa)", xlab = "Rangos")
plot(mod.mouth,     main = "RAD - RM", ylab = "log10(Ab. relativa)", xlab = "Rangos")
dev.off()

png(file.path(fig_dir, "casoA1_fig_radfit_mejor.png"),
    width = 12, height = 4, units = "in", res = 300)
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(mod.mountains$models$Preemption,
     main = "M - Preemption", ylab = "log10(Ab. Relativa)", xlab = "Rangos")
plot(mod.plains$models$Null,
     main = "P - Null",       ylab = "log10(Ab. Relativa)", xlab = "Rangos")
plot(mod.mouth$models$Mandelbrot,
     main = "RM - Mandelbrot",ylab = "log10(Ab. Relativa)", xlab = "Rangos")
dev.off()

# --- RDS ---
resultado_casoA1 <- list(
  biol_head        = biol_head,
  tabla_resumen    = tabla_resumen,
  biol2_zonas      = as.data.frame(biol2[, 1:12]),
  d.alfa           = d.alfa,
  biol_rad         = biol_rad,
  tab_aic          = tab_aic,
  anova_disper     = tab_anova_disper,
  permutest_disper = tab_permutest,
  dw_test          = tab_dw
)
guardar_rds(resultado_casoA1, "resultado_casoA1.rds")
cat("  [casoA.1] Objetos guardados.\n")


# =========================================================
# CASO A.2 — GLMs y PERMANOVAs
# =========================================================

# Resúmenes GLM capturados como texto
sum_poisson <- capture.output(summary(poisson))
sum_mod_nb  <- capture.output(summary(mod_nb))
sum_bin_neg <- capture.output(summary(bin_neg))

guardar_xlsx(as.data.frame(biol.permanova),
             file.path(tab_dir, "casoA2_permanova.xlsx"))
guardar_xlsx(simper.M_P,
             file.path(tab_dir, "casoA2_simper_M_P.xlsx"))
guardar_xlsx(simper.M_RM,
             file.path(tab_dir, "casoA2_simper_M_RM.xlsx"))
guardar_xlsx(simper.P_RM,
             file.path(tab_dir, "casoA2_simper_P_RM.xlsx"))

resultado_casoA2 <- list(
  sum_poisson = sum_poisson,
  sum_mod_nb  = sum_mod_nb,
  sum_bin_neg = sum_bin_neg,
  permanova   = as.data.frame(biol.permanova),
  simper.M_P  = simper.M_P,
  simper.M_RM = simper.M_RM,
  simper.P_RM = simper.P_RM
)
guardar_rds(resultado_casoA2, "resultado_casoA2.rds")
cat("  [casoA.2] Objetos guardados.\n")


# =========================================================
# CASO A.3 — Diversidad alfa con números de Hill
# =========================================================

# Tablas pasos iNEXT.4steps
tab_paso1 <- result1$summary$"STEP 1. Sample completeness profiles"
tab_paso3 <- result1$summary$"STEP 3. Non-asymptotic coverage-based rarefaction and extrapolation analysis"
tab_paso4 <- result1$summary$"STEP 4. Evenness among species abundances of orders q = 1 and 2 at Cmax based on the normalized slope of a diversity profile"

guardar_xlsx(as.data.frame(biol_sit),
             file.path(tab_dir, "casoA3_biol_sit_especies_zonas.xlsx"))
guardar_xlsx(result,
             file.path(tab_dir, "casoA3_inext_datainfo.xlsx"))
guardar_xlsx(as.data.frame(tab_paso1),
             file.path(tab_dir, "casoA3_inext4steps_paso1_completitud.xlsx"))
guardar_xlsx(asinto_tab,
             file.path(tab_dir, "casoA3_inext4steps_paso2_asintotico.xlsx"))
guardar_xlsx(as.data.frame(tab_paso3),
             file.path(tab_dir, "casoA3_inext4steps_paso3_cobertura.xlsx"))
guardar_xlsx(as.data.frame(tab_paso4),
             file.path(tab_dir, "casoA3_inext4steps_paso4_uniformidad.xlsx"))
guardar_xlsx(result2a,
             file.path(tab_dir, "casoA3_inext3d_TDInfo.xlsx"))
guardar_xlsx(head(result2b, 12),
             file.path(tab_dir, "casoA3_inext3d_TDiNextEst_sizebased.xlsx"))
guardar_xlsx(result2c,
             file.path(tab_dir, "casoA3_inext3d_TDAsyEst.xlsx"))
guardar_xlsx(head(result2d., 9),
             file.path(tab_dir, "casoA3_ObsAsy3D_perfiles_q.xlsx"))

# Figuras iNEXT.4steps
fig_a3_paso1 <- result1$figure[[1]] +
  scale_x_continuous(limits = c(0, 2), breaks = seq(0, 2, by = 1)) +
  labs(x = "Orden q", y = "Completitud de la muestra",
       title = "Paso 1. Perfil de Completitud",
       subtitle = "Comparaci\u00f3n de las zonas por \u00f3rdenes de diversidad (q)") +
  theme(panel.grid = element_blank(), legend.position = "bottom",
        legend.title = element_blank())

fig_a3_paso2 <- result1$figure[[2]] +
  labs(x = "Abundancia",
       y = "Diversidad (n\u00famero efectivo de especies)",
       title = "Paso 2.1. Tama\u00f1o basado en rarefacci\u00f3n/extrapolaci\u00f3n",
       subtitle = "Curvas por zonas para q = 0 (riqueza), q = 1 (Shannon) y q = 2 (Simpson)") +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom")

fig_a3_paso3 <- result1$figure[[4]] +
  labs(x = "Cobertura de las estaciones",
       y = "Diversidad (n\u00famero efectivo de especies)",
       title = "Paso 3. Perfil no asint\u00f3tico por cobertura",
       subtitle = "Comparaci\u00f3n de M, P y RM a Cmax \u2248 1") +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom")

fig_a3_paso4 <- result1$figure[[5]] +
  scale_x_continuous(limits = c(0, 2), breaks = seq(0, 2, by = 1)) +
  labs(x = "Orden q", y = "Uniformidad",
       title = "Paso 4. Perfil de Uniformidad",
       subtitle = "Comparaci\u00f3n de M, P y RM a Cmax \u2248 1") +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom")

fig_a3_3d1 <- ggiNEXT3D(result2, type = 1, facet.var = "Assemblage") +
  labs(x = "N\u00famero de individuos", y = "Diversidad taxon\u00f3mica",
       title = "Tama\u00f1o basado en rarefacci\u00f3n/extrapolaci\u00f3n",
       subtitle = "Curvas por zonas para q = 0, 1 y 2") +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom")

fig_a3_3d2 <- ggiNEXT3D(result2, type = 2, color.var = "Assemblage") +
  labs(title = "Curvas de completitud de las zonas",
       x = "N\u00famero de individuos", y = "Cobertura de la muestra") +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom")

fig_a3_3d3 <- ggiNEXT3D(result2, type = 3, facet.var = "Assemblage") +
  labs(title = "Curvas R/E basadas en cobertura",
       x = "Cobertura de la muestra", y = "Diversidad taxon\u00f3mica") +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom")

fig_a3_obsasy <- ggObsAsy3D(result2d) +
  labs(title = "Perfiles de orden q",
       subtitle = "especies comunes/raras (q\u22480) hacia dominantes (q\u22482)",
       x = "Orden q", y = "Diversidad taxon\u00f3mica") +
  theme(panel.grid = element_blank(), legend.position = "bottom")

guardar_figura(fig_a3_paso1,  "casoA3_fig_paso1_completitud.png",      width = 7, height = 4)
guardar_figura(fig_a3_paso2,  "casoA3_fig_paso2_rarefa_tamano.png",    width = 7, height = 5)
guardar_figura(fig_a3_paso3,  "casoA3_fig_paso3_rarefa_cobertura.png", width = 7, height = 5)
guardar_figura(fig_a3_paso4,  "casoA3_fig_paso4_uniformidad.png",      width = 7, height = 4)
guardar_figura(fig_a3_3d1,    "casoA3_fig_inext3d_sizebased.png",      width = 9, height = 5)
guardar_figura(fig_a3_3d2,    "casoA3_fig_inext3d_completitud.png",    width = 9, height = 5)
guardar_figura(fig_a3_3d3,    "casoA3_fig_inext3d_cobertura.png",      width = 9, height = 5)
guardar_figura(fig_a3_obsasy, "casoA3_fig_obsasy_perfiles_q.png",      width = 7, height = 5)

resultado_casoA3 <- list(
  biol_sit   = biol_sit,
  result     = result,
  tab_paso1  = as.data.frame(tab_paso1),
  asinto_tab = asinto_tab,
  tab_paso3  = as.data.frame(tab_paso3),
  tab_paso4  = as.data.frame(tab_paso4),
  result1    = result1,
  result2    = result2,
  result2a   = result2a,
  result2b   = head(result2b, 12),
  result2c   = result2c,
  result2d.  = result2d.
)
guardar_rds(resultado_casoA3, "resultado_casoA3.rds")
cat("  [casoA.3] Objetos guardados.\n")


# =========================================================
# CASO B.1 — Diversidad beta clásica y varianza
# =========================================================

# beta_ob y beta_est como tabla
tab_beta_wb <- data.frame(
  Estimador  = c("Beta observada (Whittaker)", "Beta estimada (Chao)"),
  Valor      = c(
    gamma.est$Riqueza / alfa.est$Alfa_est[1],
    gamma.est$Chao    / alfa.est$Alfa_est[2]
  )
)

guardar_xlsx(gamma.est,
             file.path(tab_dir, "casoB1_gamma_estimada.xlsx"))
guardar_xlsx(alfa.est,
             file.path(tab_dir, "casoB1_alfa_estimada.xlsx"))
guardar_xlsx(tab_beta_wb,
             file.path(tab_dir, "casoB1_beta_whittaker_obs_est.xlsx"))
guardar_xlsx(beta.est,
             file.path(tab_dir, "casoB1_beta_jaccard_sorensen_whittaker.xlsx"))
tab_dbeta <- as.data.frame(t(round(d.beta$beta, 4)))
guardar_xlsx(tab_dbeta,
             file.path(tab_dir, "casoB1_dbeta_SStotal_BDtotal.xlsx"))
guardar_xlsx(p,
             file.path(tab_dir, "casoB1_scbd_significativos.xlsx"))

# LCBD con p.adjust
tab_lcbd <- data.frame(
  LCBD    = round(d.beta$LCBD, 4),
  p_LCBD  = round(d.beta$p.LCBD, 4),
  p_holm  = round(p.adjust(d.beta$p.LCBD, "holm"), 4)
)
guardar_xlsx(tab_lcbd, file.path(tab_dir, "casoB1_lcbd_pvalores.xlsx"))

guardar_figura(fig_lcbd, "casoB1_fig_lcbd_georef.png", width = 8, height = 5)

resultado_casoB1 <- list(
  gamma.est    = gamma.est,
  alfa.est     = alfa.est,
  tab_beta_wb  = tab_beta_wb,
  beta.est     = beta.est,
  d.beta       = d.beta,
  tab_dbeta    = as.data.frame(t(round(d.beta$beta, 4))),
  tab_lcbd     = tab_lcbd,
  d.beta1      = d.beta1,
  p_scbd       = p
)
guardar_rds(resultado_casoB1, "resultado_casoB1.rds")
cat("  [casoB.1] Objetos guardados.\n")


# =========================================================
# CASO B.2 — Beta Podani y recambio
# =========================================================

guardar_xlsx(as.data.frame(round(beta.pod$part, 3)),
             file.path(tab_dir, "casoB2_podani_part.xlsx"))
guardar_xlsx(amb2,
             file.path(tab_dir, "casoB2_dbrda_variables_significativas.xlsx"))

# RsquareAdj de los db-RDA
tab_rsq <- data.frame(
  Componente  = c("Recambio", "Diferencia de riqueza"),
  R2          = c(RsquareAdj(dbrda.repl)$r.squared,
                  RsquareAdj(dbrda.riq)$r.squared),
  R2_adj      = c(RsquareAdj(dbrda.repl)$adj.r.squared,
                  RsquareAdj(dbrda.riq)$adj.r.squared),
  p_anova     = c(anova(dbrda.repl)$"Pr(>F)"[1],
                  anova(dbrda.riq)$"Pr(>F)"[1])
)
guardar_xlsx(tab_rsq, file.path(tab_dir, "casoB2_dbrda_rsquared.xlsx"))

# Figuras ggplot
colores <- c("Beta" = "#525252", "Recambio" = "#969696", "Dif.Riq" = "#cccccc")

fig_b2_riq42 <- ggplot(df, aes(x = Sitio, y = DifRiqueza)) +
  geom_line(color = "red", linewidth = 1) +
  geom_point(shape = 21, size = 3, fill = "red") +
  annotate("text", x = 3,  y = 0.42, label = "Monta\u00f1as",
           color = "darkgreen", size = 5, fontface = "italic") +
  annotate("text", x = 17, y = 0.9,  label = "planicies",
           color = "darkgreen", size = 5, fontface = "italic") +
  annotate("text", x = 33, y = 0.2,  label = "Desembocadura",
           color = "darkgreen", size = 5, fontface = "italic") +
  scale_x_continuous(breaks = seq(1, 41, by = 2)) +
  labs(title = "Diferencias de riqueza respecto al sitio 42 (referencia)",
       x = "Sitios", y = "Diferencia de Riqueza (Jaccard - Podani)") +
  theme_bw(base_size = 10) + theme(panel.grid.minor = element_blank())

fig_b2_apilado <- ggplot(datos,
    aes(x = Sitio, y = valores, fill = Parameters)) +
  geom_col(position = "stack", width = 0.8) +
  scale_fill_manual(values = colores) +
  scale_x_discrete(breaks = levels(datos$Sitio)[seq(1, nlevels(datos$Sitio), by = 2)]) +
  labs(title = "Componentes Podani (Jaccard) respecto al sitio 42",
       x = "Sitios", y = "Fracci\u00f3n (\u03b2, recambio, dif. riqueza)",
       fill = "Par\u00e1metros") +
  theme_classic() + theme(axis.text.x = element_text(angle = 45, hjust = 1))

fig_b2_parejas <- ggplot(datos_parejas,
    aes(x = Pareja, y = valores, fill = Parameters)) +
  geom_col(position = "stack", width = 0.8) +
  scale_fill_manual(values = colores) +
  labs(title = "\u03b2 de Jaccard, dif. riqueza y recambio por sitios vecinos",
       x = "Parejas de sitios",
       y = "\u00cdndices de Podani (\u03b2, recambio, dif. riqueza)",
       fill = "Par\u00e1metros") +
  theme_classic() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

# Figura db-RDA
fig_b2_dbrda <- ggplot() +
  geom_mark_ellipse(data = coord.sit,
                    aes(x = dbRDA1, y = dbRDA2, fill = grp, group = grp),
                    alpha = 0.20) +
  geom_text_repel(data = coord.sit,
                  aes(dbRDA1, dbRDA2, label = row.names(coord.sit)), size = 4) +
  geom_point(data = coord.sit,
             aes(dbRDA1, dbRDA2, colour = grp), size = 4) +
  geom_segment(data = coord.amb,
               aes(x = 0, y = 0, xend = dbRDA1 * 4, yend = dbRDA2 * 4),
               arrow = arrow(angle = 22.5, length = unit(0.25, "cm"), type = "closed"),
               linewidth = 0.6, colour = "blue") +
  geom_text_repel(data = coord.amb,
                  aes(dbRDA1 * 4, dbRDA2 * 4, label = row.names(coord.amb)),
                  colour = "blue") +
  geom_hline(yintercept = 0, linetype = 3, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = 3, linewidth = 1) +
  theme_bw() + theme(panel.grid = element_blank()) +
  labs(title = "db-RDA: variables ambientales y diferencia de riqueza",
       colour = "Zona", fill = "Zona")

guardar_figura(fig_b2_riq42,   "casoB2_fig_dif_riqueza_sitio42.png",  width = 9,  height = 4)
guardar_figura(fig_b2_apilado, "casoB2_fig_componentes_apilados.png", width = 9,  height = 5)
guardar_figura(fig_b2_parejas, "casoB2_fig_beta_parejas_vecinas.png", width = 10, height = 5)
guardar_figura(fig_b2_dbrda,   "casoB2_fig_dbrda_riqueza.png",        width = 9,  height = 6)

# Triángulos símplex
png(file.path(fig_dir, "casoB2_fig_triangulos_podani.png"),
    width = 10, height = 10, units = "in", res = 300)
par(mfrow = c(2, 2))
triangle.plot(as.data.frame(beta.pod.J.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Riq", cex = 1); text(0.40, 0.55, "Reempl", cex = 1)
text(0.00, -0.6, "Similitud de Jaccard", cex = 1)
triangle.plot(as.data.frame(beta.pod.S.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Riq", cex = 1); text(0.40, 0.55, "Reempl", cex = 1)
text(0.00, -0.6, "Similitud de Sorensen", cex = 1)
triangle.plot(as.data.frame(beta.pod.qJ.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Ab", cex = 1); text(0.40, 0.55, "Reempl", cex = 1)
text(0.00, -0.6, "S = 1 - Ruzicka D", cex = 1)
triangle.plot(as.data.frame(beta.pod.qS.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Ab", cex = 1); text(0.40, 0.55, "Reempl", cex = 1)
text(0.00, -0.6, "S = 1 - Porcentaje diferencia", cex = 1)
dev.off()

# Dendogramas UPGMA — zonas
png(file.path(fig_dir, "casoB2_fig_dendogramas_zonas.png"),
    width = 12, height = 5, units = "in", res = 300)
grid.arrange(
  fviz_dend(hclust(beta.pod$D,    method = "average"), k = 2, cex = 0.7,
            ylab = "Distancia Jaccard", xlab = "Beta Total",   main = "(a)"),
  fviz_dend(hclust(beta.pod$rich, method = "average"), k = 2, cex = 0.7,
            ylab = "Distancia Jaccard", xlab = "Dif. Riqueza", main = "(b)"),
  fviz_dend(hclust(beta.pod$repl, method = "average"), k = 2, cex = 0.7,
            ylab = "Distancia Jaccard", xlab = "Recambio",     main = "(c)"),
  ncol = 3
)
dev.off()

# PAM + PCoA — sitios
pal <- c('#fc8d59', '#377eb8', '#99d594')
pc_total <- as.data.frame(cmdscale(beta.pod$D,    k = 2))
pc_rich  <- as.data.frame(cmdscale(beta.pod$rich, k = 2))
pc_repl  <- as.data.frame(cmdscale(beta.pod$repl, k = 2))
colnames(pc_total) <- colnames(pc_rich) <- colnames(pc_repl) <- c("PCoA1", "PCoA2")

pam_total <- cluster::pam(beta.pod$D,    k = 3, diss = TRUE)
pam_rich  <- cluster::pam(beta.pod$rich, k = 3, diss = TRUE)
pam_repl  <- cluster::pam(beta.pod$repl, k = 3, diss = TRUE)

fp1 <- factoextra::fviz_cluster(list(data = pc_total, cluster = pam_total$clustering),
        palette = pal, ellipse.type = "confidence", repel = TRUE, labelsize = 8,
        ggtheme = theme_bw()) + labs(title = "(a) Beta total (Jaccard)")
fp2 <- factoextra::fviz_cluster(list(data = pc_rich, cluster = pam_rich$clustering),
        palette = pal, ellipse.type = "confidence", repel = TRUE, labelsize = 8,
        ggtheme = theme_bw()) + labs(title = "(b) Diferencia de riqueza") +
        guides(color = "none", shape = "none", fill = "none")
fp3 <- factoextra::fviz_cluster(list(data = pc_repl, cluster = pam_repl$clustering),
        palette = pal, ellipse.type = "confidence", repel = TRUE, labelsize = 8,
        ggtheme = theme_bw()) + labs(title = "(c) Recambio") +
        guides(color = "none", shape = "none", fill = "none")

fig_b2_pam <- (fp1 | fp2 | fp3) + plot_layout(guides = "collect") &
  theme(legend.position = "bottom", panel.grid = element_blank(),
        text = element_text(size = 9))

guardar_figura(fig_b2_pam, "casoB2_fig_pam_pcoa_sitios.png", width = 12, height = 5)

resultado_casoB2 <- list(
  beta.pod   = beta.pod,
  beta.pod.J = beta.pod.J,
  beta.pod.S = beta.pod.S,
  tab_rsq    = tab_rsq,
  amb2       = amb2,
  dbrda.repl = dbrda.repl,
  dbrda.riq  = dbrda.riq
)
guardar_rds(resultado_casoB2, "resultado_casoB2.rds")
cat("  [casoB.2] Objetos guardados.\n")


# =========================================================
# CASO B.3 — Diversidad beta con números de Hill
# =========================================================

guardar_xlsx(result_b3,
             file.path(tab_dir, "casoB3_inext_alfa.xlsx"))
guardar_xlsx(head(biol.pares$M_vs_P,  6),
             file.path(tab_dir, "casoB3_biol_pares_MvsP.xlsx"))
guardar_xlsx(head(biol.pares$M_vs_RM, 6),
             file.path(tab_dir, "casoB3_biol_pares_MvsRM.xlsx"))
guardar_xlsx(head(biol.pares$P_vs_RM, 6),
             file.path(tab_dir, "casoB3_biol_pares_PvsRM.xlsx"))
guardar_xlsx(head(diversidad_abun_cov$M_vs_P$beta,  6),
             file.path(tab_dir, "casoB3_inextbeta3D_beta_MvsP.xlsx"))
guardar_xlsx(head(diversidad_abun_cov$M_vs_RM$beta, 6),
             file.path(tab_dir, "casoB3_inextbeta3D_beta_MvsRM.xlsx"))
guardar_xlsx(head(diversidad_abun_cov$P_vs_RM$beta, 6),
             file.path(tab_dir, "casoB3_inextbeta3D_beta_PvsRM.xlsx"))

fig_b3_tamano <- ggiNEXTbeta3D(diversidad_abun) +
  labs(x = "N\u00famero de individuos", y = "Diversidad taxon\u00f3mica",
       title = "(a) Rarefacci\u00f3n basada en el tama\u00f1o de la muestra y extrapolaci\u00f3n 2n",
       subtitle = "Comparaci\u00f3n de las parejas M_vs_P, M_vs_RM, P_vs_RM") +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom",
                     legend.title = element_blank(), legend.box = "vertical")

fig_b3_cobertura <- ggiNEXTbeta3D(diversidad_abun_cov) +
  labs(x = "Cobertura de las muestras", y = "Diversidad taxon\u00f3mica",
       title = "(b) Rarefacci\u00f3n y extrapolaci\u00f3n basada en cobertura",
       subtitle = "Diversidad gamma, alfa y beta para las tres parejas de zonas") +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() + theme(panel.grid = element_blank(), legend.position = "bottom",
                     legend.title = element_blank(), legend.box = "vertical")

guardar_figura(fig_b3_tamano,    "casoB3_fig_inextbeta_tamano.png",    width = 8, height = 7)
guardar_figura(fig_b3_cobertura, "casoB3_fig_inextbeta_cobertura.png", width = 8, height = 7)

resultado_casoB3 <- list(
  result_b3           = result_b3,
  biol                = biol,
  biol.pares          = biol.pares,
  diversidad_abun     = diversidad_abun,
  diversidad_abun_cov = diversidad_abun_cov
)
guardar_rds(resultado_casoB3, "resultado_casoB3.rds")
cat("  [casoB.3] Objetos guardados.\n")


# =========================================================
# Objeto consolidado del capítulo 7
# =========================================================

resultado_cap7 <- list(
  casoA1 = resultado_casoA1,
  casoA2 = resultado_casoA2,
  casoA3 = resultado_casoA3,
  casoB1 = resultado_casoB1,
  casoB2 = resultado_casoB2,
  casoB3 = resultado_casoB3
)

guardar_rds(resultado_cap7, "resultado_cap7.rds")
cat("  [cap7] Objeto consolidado guardado.\n")
cat("Salidas del cap\u00edtulo 7 guardadas correctamente.\n")
