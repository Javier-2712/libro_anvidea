# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# ---------------------------------------------------------
# Archivo : 05_casoB_beta_podani_recambio.R
# Caso    : B.2 Beta Podani y recambio
# =========================================================

cat("\n========================================\n")
cat("Caso B.2 - Beta de Podani y recambio\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 3) Diversidad beta en sus componentes de recambio
#         y diferencia de riqueza (Podani & Schmera, 2011)
# ---------------------------------------------------------

library(dplyr)
library(tidyr)
library(adespatial)
library(ade4)
library(cluster)
library(factoextra)
library(ggplot2)
library(ggrepel)
library(ggforce)
library(patchwork)
library(gridExtra)
library(kableExtra)
library(vegan)

# Nota: biol, biol1, biol2 provienen del casoB.1

# ---- a. Beta general con datos binarios (Podani & Schmera, 2011) ----

# Preparar datos: solo columnas numéricas, sin NA ni Inf
biol3 <-
  biol1 %>%
  dplyr::select(where(is.numeric)) %>%
  mutate(across(everything(), ~ as.numeric(.x))) %>%
  mutate(across(everything(), ~ tidyr::replace_na(.x, 0))) %>%
  as.data.frame()

biol3[!is.finite(as.matrix(biol3))] <- 0

# Abundancia -> binario
biol.bin <- (as.matrix(biol3) > 0) * 1

# Jaccard Podani (datos binarios)
beta.pod <- beta.div.comp(biol.bin, coef = "J", quant = FALSE)

summary(beta.pod)

# Estadísticos generados
round(beta.pod$part, 3)

# Figura: diferencias de riqueza respecto al sitio 42 (referencia)
peces.riq    <- as.matrix(beta.pod$rich)
peces.riq.42 <- peces.riq[42, -42]
site.names   <- (1:42)[-42]

df <- data.frame(Sitio = site.names, DifRiqueza = peces.riq.42)

ggplot(df, aes(x = Sitio, y = DifRiqueza)) +
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
       x     = "Sitios",
       y     = "Diferencia de Riqueza (Jaccard - Podani)") +
  theme_bw(base_size = 10) +
  theme(panel.grid.minor = element_blank())

# Figura: componentes beta apilados respecto al sitio 42
ref <- 42

M.rec  <- as.matrix(beta.pod$repl)
M.riq  <- as.matrix(beta.pod$rich)
M.beta <- if (!is.null(beta.pod$beta)) as.matrix(beta.pod$beta) else M.rec + M.riq

datos <- tibble(
  Sitio    = factor(seq_len(nrow(M.rec))),
  Beta     = as.numeric(M.beta[ref, ]),
  Recambio = as.numeric(M.rec[ref, ]),
  Dif.Riq  = as.numeric(M.riq[ref, ])
) %>%
  mutate(across(-Sitio, ~ ifelse(Sitio == ref, 0, .))) %>%
  pivot_longer(-Sitio, names_to = "Parameters", values_to = "valores") %>%
  mutate(Parameters = factor(Parameters,
                             levels  = c("Dif.Riq", "Recambio", "Beta"),
                             ordered = TRUE))

colores <- c("Beta" = "#525252", "Recambio" = "#969696", "Dif.Riq" = "#cccccc")

ggplot(datos, aes(x = Sitio, y = valores, fill = Parameters)) +
  geom_col(position = "stack", width = 0.8) +
  scale_fill_manual(values = colores) +
  scale_x_discrete(breaks = levels(datos$Sitio)[seq(1, nlevels(datos$Sitio), by = 2)]) +
  labs(title = "Componentes Podani (Jaccard) respecto al sitio 42",
       x     = "Sitios",
       y     = "Fracci\u00f3n (beta, recambio, dif. riqueza)",
       fill  = "Par\u00e1metros") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# ---- b. Beta por parejas de sitios ----

M.rec  <- as.matrix(beta.pod$repl)
M.riq  <- as.matrix(beta.pod$rich)
M.beta <- if (is.null(beta.pod$beta)) M.rec + M.riq else as.matrix(beta.pod$beta)

n   <- nrow(M.rec)
idx <- cbind(1:(n - 1), 2:n)
pares <- paste0(idx[, 1], "-", idx[, 2])

datos_parejas <- tibble(
  Pareja   = factor(pares, levels = pares),
  Beta     = M.beta[idx],
  Recambio = M.rec[idx],
  Dif.Riq  = M.riq[idx]
) %>%
  pivot_longer(-Pareja, names_to = "Parameters", values_to = "valores") %>%
  mutate(Parameters = factor(Parameters,
                             levels  = c("Dif.Riq", "Recambio", "Beta"),
                             ordered = TRUE))

ggplot(datos_parejas, aes(x = Pareja, y = valores, fill = Parameters)) +
  geom_col(position = "stack", width = 0.8) +
  scale_fill_manual(values = colores) +
  labs(title = "Beta Jaccard, dif. riqueza y recambio por sitios vecinos",
       x     = "Parejas de sitios",
       y     = "\u00cdndices de Podani (beta, recambio, dif. riqueza)",
       fill  = "Par\u00e1metros") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))


# ---- c. Gráficos triangulares (Legendre 2014) ----

# Diversidad beta con cuatro índices de disimilitud
beta.pod.J  <- beta.div.comp(biol.bin, coef = "J", quant = FALSE)  # Jaccard
beta.pod.S  <- beta.div.comp(biol.bin, coef = "S", quant = FALSE)  # Sorensen
beta.pod.qJ <- beta.div.comp(biol.bin, coef = "J", quant = TRUE)   # Ruzicka
beta.pod.qS <- beta.div.comp(biol.bin, coef = "S", quant = TRUE)   # % diferencias

beta.pod.J.3 <- cbind((1 - beta.pod.J$D),   beta.pod.J$repl,  beta.pod.J$rich)
colnames(beta.pod.J.3)  <- c("Similarity", "Repl", "RichDiff")

beta.pod.S.3 <- cbind((1 - beta.pod.S$D),   beta.pod.S$repl,  beta.pod.S$rich)
colnames(beta.pod.S.3)  <- c("Similarity", "Repl", "RichDiff")

beta.pod.qJ.3 <- cbind((1 - beta.pod.qJ$D), beta.pod.qJ$repl, beta.pod.qJ$rich)
colnames(beta.pod.qJ.3) <- c("Similarity", "Repl", "AbDiff")

beta.pod.qS.3 <- cbind((1 - beta.pod.qS$D), beta.pod.qS$repl, beta.pod.qS$rich)
colnames(beta.pod.qS.3) <- c("Similarity", "Repl", "AbDiff")

# Panel 2 x 2 de triángulos
dev.new(width = 10, height = 10)
par(mfrow = c(2, 2))

triangle.plot(as.data.frame(beta.pod.J.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Riq", cex = 1)
text( 0.40, 0.55, "Reempl",  cex = 1)
text( 0.00, -0.6, "Similitud de Jaccard", cex = 1)

triangle.plot(as.data.frame(beta.pod.S.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Riq", cex = 1)
text( 0.40, 0.55, "Reempl",  cex = 1)
text( 0.00, -0.6, "Similitud de S\u00f8rensen", cex = 1)

triangle.plot(as.data.frame(beta.pod.qJ.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Ab",  cex = 1)
text( 0.40, 0.55, "Reempl",  cex = 1)
text( 0.00, -0.6, "S = 1 \u2013 Ru\u017ei\u010dka D", cex = 1)

triangle.plot(as.data.frame(beta.pod.qS.3[, c(3, 1, 2)]),
              show = FALSE, labeltriangle = FALSE, addmean = TRUE)
text(-0.45, 0.55, "Dif.Ab",  cex = 1)
text( 0.40, 0.55, "Reempl",  cex = 1)
text( 0.00, -0.6, "S = 1 \u2013 Porcentaje de diferencia", cex = 1)
dev.off()


# ---- d. Clasificación de zonas por componentes de beta ----

labs <- make.unique(as.character(biol2[[1]]))

biol.bin2 <-
  biol2[, -1] %>%
  mutate(across(everything(), ~ as.numeric(.x))) %>%
  tidyr::replace_na(list()) %>%
  as.data.frame()

biol.bin2[!is.finite(as.matrix(biol.bin2))] <- 0
rownames(biol.bin2) <- labs
biol.bin2 <- (as.matrix(biol.bin2) > 0) * 1

beta.pod <- beta.div.comp(biol.bin2, coef = "J", quant = FALSE)

Cl.upgma1 <- hclust(beta.pod$D,    method = "average")
Cl.upgma2 <- hclust(beta.pod$rich, method = "average")
Cl.upgma3 <- hclust(beta.pod$repl, method = "average")

f1 <- fviz_dend(Cl.upgma1, k = 2, cex = 0.7,
                ylab = "Distancia Jaccard", xlab = "Beta Total",    main = "(a)")
f2 <- fviz_dend(Cl.upgma2, k = 2, cex = 0.7,
                ylab = "Distancia Jaccard", xlab = "Dif. Riqueza",  main = "(b)")
f3 <- fviz_dend(Cl.upgma3, k = 2, cex = 0.7,
                ylab = "Distancia Jaccard", xlab = "Recambio",      main = "(c)")

grid.arrange(f1, f2, f3, ncol = 3)


# ---- e. Clasificación de sitios por componentes de beta ----

labs1 <- make.unique(as.character(biol[[1]]))

biol4 <-
  biol1[, -1] %>%
  mutate(across(everything(), ~ as.numeric(.x))) %>%
  tidyr::replace_na(list()) %>%
  as.data.frame()

biol4[!is.finite(as.matrix(biol4))] <- 0
biol.bin <- (as.matrix(biol4) > 0) * 1
rownames(biol.bin) <- labs1

beta.pod <- beta.div.comp(biol.bin, coef = "J", quant = FALSE)

Cl.upgma1 <- hclust(beta.pod$D,    method = "average")
Cl.upgma2 <- hclust(beta.pod$rich, method = "average")
Cl.upgma3 <- hclust(beta.pod$repl, method = "average")

f1 <- fviz_dend(Cl.upgma1, k = 3, margins = c(5, 12), cex = 0.6,
                ylab = "Distancia Jaccard", xlab = "Beta Total",   main = "(a)")
f2 <- fviz_dend(Cl.upgma2, k = 3, margins = c(5, 12), cex = 0.6,
                ylab = "Distancia Jaccard", xlab = "Dif. Riqueza", main = "(b)")
f3 <- fviz_dend(Cl.upgma3, k = 3, margins = c(5, 12), cex = 0.6,
                ylab = "Distancia Jaccard", xlab = "Recambio",     main = "(c)")

grid.arrange(f1, f2, f3, ncol = 3)

# PAM (k-medoids) sobre matrices de distancias
pal <- c('#fc8d59', '#377eb8', '#99d594')

pc_total <- as.data.frame(cmdscale(beta.pod$D,    k = 2))
pc_rich  <- as.data.frame(cmdscale(beta.pod$rich, k = 2))
pc_repl  <- as.data.frame(cmdscale(beta.pod$repl, k = 2))
colnames(pc_total) <- colnames(pc_rich) <- colnames(pc_repl) <- c("PCoA1", "PCoA2")

pam_total <- cluster::pam(beta.pod$D,    k = 3, diss = TRUE)
pam_rich  <- cluster::pam(beta.pod$rich, k = 3, diss = TRUE)
pam_repl  <- cluster::pam(beta.pod$repl, k = 3, diss = TRUE)

fig1 <- factoextra::fviz_cluster(
  list(data = pc_total, cluster = pam_total$clustering),
  palette = pal, ellipse.type = "confidence",
  repel = TRUE, labelsize = 8,
  ggtheme = ggplot2::theme_bw()) +
  ggplot2::labs(title = "(a) Beta total (Jaccard)") +
  ggplot2::xlab("PCoA1") + ggplot2::ylab("PCoA2")

fig2 <- factoextra::fviz_cluster(
  list(data = pc_rich, cluster = pam_rich$clustering),
  palette = pal, ellipse.type = "confidence",
  repel = TRUE, labelsize = 8,
  ggtheme = ggplot2::theme_bw()) +
  ggplot2::labs(title = "(b) Diferencia de riqueza") +
  ggplot2::xlab("PCoA1") + ggplot2::ylab("PCoA2")

fig3 <- factoextra::fviz_cluster(
  list(data = pc_repl, cluster = pam_repl$clustering),
  palette = pal, ellipse.type = "confidence",
  repel = TRUE, labelsize = 8,
  ggtheme = ggplot2::theme_bw()) +
  ggplot2::labs(title = "(c) Recambio") +
  ggplot2::xlab("PCoA1") + ggplot2::ylab("PCoA2")

fig2 <- fig2 + guides(color = "none", shape = "none", fill = "none")
fig3 <- fig3 + guides(color = "none", shape = "none", fill = "none")

(fig1 | fig2 | fig3) + plot_layout(guides = "collect") &
  theme(legend.position = "bottom",
        panel.grid  = element_blank(),
        text        = element_text(size = 9),
        axis.text   = element_text(size = 8, face = "bold"),
        legend.text = element_text(size = 8),
        strip.text  = element_text(size = 9, face = "bold"))


# ---- f. Efecto de variables ambientales sobre componentes de beta ----

peces.riq  <- beta.pod$rich
peces.repl <- beta.pod$repl

amb <- read_xlsx(archivo_datos, sheet = "amb")

amb1 <-
  amb %>%
  dplyr::select(`pH`, `Water temperature`, `Conductivity`,
                `Salinity`, `Transparency`, `Oxygen`,
                `Carbon Dioxide`, `Alkalinity`, `NO2`,
                `NO3`, `Ammonium`, `Hardness`,
                `Phosphates`, `TDS`)

# Recambio
dbrda.repl <- dbrda(peces.repl ~ ., data = amb1, add = "cailliez")
anova(dbrda.repl)$"Pr(>F)"
RsquareAdj(dbrda.repl)

# Diferencia de riqueza — todas las variables
dbrda.riq <- dbrda(peces.riq ~ ., data = amb1, add = "cailliez")
anova(dbrda.riq)$"Pr(>F)"
RsquareAdj(dbrda.riq)

# Variables ambientales significativas (envfit)
amb2 <- envfit(dbrda.riq, amb1)

amb2 <-
  amb2$vectors$pvals %>%
  as.data.frame() %>%
  tibble::rownames_to_column("Variable") %>%
  dplyr::rename(valor_p = 2) %>%
  dplyr::arrange(valor_p)

amb2 %>%
  dplyr::filter(valor_p < 0.05) %>%
  kbl(booktabs = TRUE) %>%
  kable_classic(full_width = FALSE)

# Diferencia de riqueza — variables seleccionadas
amb3 <-
  amb %>%
  dplyr::select(`Conductivity`, `Salinity`, `Transparency`,
                `NO2`, `Hardness`, `Phosphates`, `TDS`)

dbrda.riq <- dbrda(peces.riq ~ ., data = amb3, add = "cailliez")
anova(dbrda.riq)$"Pr(>F)"
RsquareAdj(dbrda.riq)

# Coordenadas de los sitios
coord.sit <- as.data.frame(scores(dbrda.riq, choices = 1:2, display = "sites"))
coord.sit$sitio <- rownames(coord.sit)
coord.sit$grp   <- biol1$Sites1

# Coordenadas de las variables ambientales
coord.amb <- as.data.frame(scores(dbrda.riq, choices = 1:2, display = "bp"))
coord.amb$amb <- rownames(coord.amb)

# Figura db-RDA
ggplot() +
  geom_mark_ellipse(data  = coord.sit,
                    aes(x = dbRDA1, y = dbRDA2,
                        fill = grp, group = grp), alpha = 0.20) +
  geom_text_repel(data = coord.sit,
                  aes(dbRDA1, dbRDA2, label = row.names(coord.sit)), size = 4) +
  geom_point(data = coord.sit,
             aes(dbRDA1, dbRDA2, colour = grp), size = 4) +
  scale_shape_manual(values = c(21:25)) +
  geom_segment(data = coord.amb,
               aes(x = 0, y = 0, xend = dbRDA1 * 4, yend = dbRDA2 * 4),
               arrow  = arrow(angle = 22.5, length = unit(0.25, "cm"),
                              type = "closed"),
               linetype = 1, linewidth = 0.6, colour = "blue") +
  geom_text_repel(data = coord.amb,
                  aes(dbRDA1 * 4, dbRDA2 * 4, label = row.names(coord.amb)),
                  colour = "blue") +
  geom_hline(yintercept = 0, linetype = 3, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = 3, linewidth = 1) +
  guides(shape = guide_legend(title = NULL, color = "black"),
         fill  = guide_legend(title = NULL)) +
  theme_bw() +
  theme(panel.grid = element_blank())

cat("\nCaso B.2 finalizado correctamente.\n")
