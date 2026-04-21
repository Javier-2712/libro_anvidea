# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica
# ---------------------------------------------------------
# Archivo : 01_casoA_alfa_clasica_rad.R
# Caso    : A.1 Diversidad alfa clásica y curvas RAD
# =========================================================

cat("\n========================================\n")
cat("Caso A.1 - Diversidad alfa clásica y curvas RAD\n")
cat("========================================\n")

# ---------------------------------------------------------
# Cargar paquetes y lectura de bases de datos
# ---------------------------------------------------------

library(tidyverse)
library(readxl)
library(corrplot)
library(vegan)
library(ggrepel)
library(kableExtra)
library(viridis)
library(dplyr)
library(car)
library(MVN)

# a. Base de datos de las especies
biol <- read_xlsx(archivo_datos, sheet = "tax")

biol %>%
  head() %>%
  dplyr::select(1:6) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# b. Tabla con nombres completos, abreviados y abundancia total

tabla <- read_xlsx(archivo_datos, "tax")

tabla_resumen <-
  tabla %>%
  dplyr::select(-Sites, -Sites1) %>%
  summarise(across(everything(), \(x) sum(x, na.rm = TRUE))) %>%
  pivot_longer(
    cols      = everything(),
    names_to  = "Especies",
    values_to = "Abundancia"
  ) %>%
  arrange(desc(Abundancia)) %>%
  mutate(
    Abrev = abbreviate(Especies, minlength = 4),
    ID    = dplyr::row_number()
  ) %>%
  dplyr::select(ID, Especies, Abrev, Abundancia)

tabla_resumen %>%
  head(10) %>%
  kbl(booktabs  = TRUE,
      longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 1. Estimadores clásicos de diversidad alfa por zona
# ---------------------------------------------------------

# Nombres abreviados de los taxones
biol1 <-
  biol %>%
  dplyr::select(-1) %>%
  rename_with(~ abbreviate(.x, minlength = 4), -1)

# Agrupar por zona y sumar abundancia de cada taxón
biol2 <-
  biol1 %>%
  group_by(Sites1) %>%
  summarise(across(everything(), \(x) sum(x, na.rm = TRUE)))

biol2 %>%
  dplyr::select(1:12) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Datos sin la columna de sitios (Sites1)
biol2_alfa <- biol2[, -1]

# Estimadores de diversidad alfa (según Borcard et al. 2018)
N0   <- rowSums(biol2_alfa > 0)              # Riqueza de especies
N0   <- specnumber(biol2_alfa)               # Riqueza de especies (alterno)
H    <- diversity(biol2_alfa)                # Entropía de Shannon (base e)
Hb2  <- diversity(biol2_alfa, base = 2)      # Entropía de Shannon (base 2)
N1   <- exp(H)                               # Diversidad de Shannon (base e)
N1b2 <- 2^Hb2                               # Diversidad de Shannon (base 2)
N2   <- diversity(biol2_alfa, "inv")         # Diversidad de Simpson
J    <- H / log(N0)                          # Equidad de Pielou
E10  <- N1 / N0                              # Equidad de Shannon (Razón de Hill)
E20  <- N2 / N0                              # Equidad de Simpson (Razón de Hill)

# Tabla resumen de diversidad alfa por zona
d.alfa <- data.frame(
  zona      = biol2[, 1],
  q_0       = N0,
  q_1       = round(N1, 1),
  q_2       = round(N2, 1),
  Equidad_J = round(J, 2)
)

d.alfa %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 2. Diversidad alfa con curvas RAD
# ---------------------------------------------------------

# Reestructurar en formato largo por zona
biol_rad <-
  biol2 %>%
  pivot_longer(
    cols      = -c(Sites1),
    names_to  = "Especies",
    values_to = "Abundancia"
  ) %>%
  dplyr::select(Sites1 = Sites1, everything())

# Convertir en factores
biol_rad$Sites1   <- as.factor(biol_rad$Sites1)
biol_rad$Especies <- as.factor(biol_rad$Especies)

# Insertar rango basado en abundancia descendente
biol_rad <-
  biol_rad %>%
  group_by(Sites1) %>%
  mutate(Rango = rank(-Abundancia, ties.method = "min")) %>%
  ungroup()

# Calcular abundancia relativa
biol_rad <-
  biol_rad %>%
  group_by(Sites1) %>%
  mutate(Ab_rel = round(Abundancia / sum(Abundancia), 3)) %>%
  ungroup()

# Seleccionar los 20 taxones más abundantes
top20_taxas <-
  biol_rad %>%
  group_by(Especies) %>%
  summarise(Total_Ab_rel = sum(Ab_rel), .groups = "drop") %>%
  top_n(20, Total_Ab_rel) %>%
  pull(Especies)

# Filtrar datos para los 20 taxones seleccionados
biol_rad <-
  biol_rad %>%
  dplyr::filter(Especies %in% top20_taxas)

head(biol_rad) %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 3) %>%
  kable_classic(full_width = FALSE)

# Figura RAD — abundancia relativa por rango y zona
fig_rad1 <- ggplot(biol_rad,
       aes(x = Rango, y = Ab_rel,
           color = Especies, label = Especies)) +
  geom_point(size = 3) +
  geom_text_repel(aes(label = Especies),
                  hjust = 1, vjust = 1.5, size = 3,
                  box.padding = 0.4, point.padding = 0.2,
                  segment.color = "black",
                  segment.linetype = "dashed",
                  show.legend = FALSE) +
  geom_line(color = "blue") +
  scale_x_continuous(breaks = seq(0, max(biol_rad$Rango), by = 10),
                     expand = expansion(add = c(0, 0.5))) +
  scale_y_log10() +
  labs(x     = "Rangos de Especies",
       y     = expression(log[10]~(Abundancia~Relativa)),
       color = "Especies") +
  facet_wrap(~Sites1, nrow = 1) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        legend.position = "none",
        strip.text = element_text(face = "bold"))
print(fig_rad1)

# Figura RAD — versión con estilo mejorado
fig_rad2 <- ggplot(biol_rad,
       aes(x = Rango, y = Ab_rel,
           color = Especies, label = Especies)) +
  geom_point(size = 4, shape = 21, fill = "white",
             color = "black", stroke = 1.5) +
  geom_text_repel(
    aes(label = Especies), hjust = 1, vjust = 1.5, size = 3.5,
    box.padding = 0.4, point.padding = 0.2,
    segment.color = "gray70", segment.linetype = "dashed",
    show.legend = FALSE
  ) +
  geom_line(color = "blue") +
  scale_x_continuous(breaks = seq(0, max(biol_rad$Rango), by = 10)) +
  scale_y_log10() +
  scale_color_manual(values =
    colorRampPalette(c("darkred", "firebrick", "tomato", "orange"))(20)) +
  labs(x = "Rangos de Especies",
       y = expression(log[10]~(Abundancia~Relativa))) +
  facet_wrap(~Sites1, nrow = 1) +
  theme_bw(base_size = 14) +
  theme(
    panel.grid        = element_blank(),
    panel.background  = element_rect(fill = "gray98", color = NA),
    plot.background   = element_rect(fill = "white"),
    strip.background  = element_rect(fill = "gray80", color = "gray50"),
    strip.text        = element_text(face = "bold", size = 12, color = "black"),
    axis.text         = element_text(color = "gray30"),
    axis.title        = element_text(face = "bold"),
    legend.position   = "none"
  )
print(fig_rad2)


# a. Ajuste de las curvas RAD

# Reestructurar biol2 en formato largo y luego ancho por sitio
biol2 <-
  biol1 %>%
  group_by(Sites1) %>%
  summarise(across(everything(), \(x) sum(x, na.rm = TRUE)))

biol2 <-
  biol2 %>%
  pivot_longer(
    cols      = -c(Sites1),
    names_to  = "Especies",
    values_to = "Abundancia"
  ) %>%
  dplyr::select(Sites1 = Sites1, everything())

biol2 <-
  biol2 %>%
  group_by(Sites1, Especies) %>%
  summarise(Abundance = sum(Abundancia, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from  = Sites1,
              values_from = Abundance,
              values_fill = 0)

biol2 %>%
  head(8) %>%
  kbl(booktabs  = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Ajustar modelos radfit para cada sitio
biol2a <- as.data.frame(biol2)
rownames(biol2a) <- biol2a$Especies
biol2  <- biol2a[, -1]

mod.mountains <- radfit(biol2a[, "M"])
mod.plains    <- radfit(biol2a[, "P"])
mod.mouth     <- radfit(biol2a[, "RM"])

# Tabla: modelo con menor AIC por sitio
extract_model <- function(mod) {
  sapply(mod$models, AIC)
}

tibble(
  Sitio            = c("M", "P", "RM"),
  Modelo_Menor_AIC = c(
    names(which.min(extract_model(mod.mountains))),
    names(which.min(extract_model(mod.plains))),
    names(which.min(extract_model(mod.mouth)))
  )
) %>%
  kbl(booktabs  = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# b. Figuras de los modelos RAD por sitio

dev.new(width = 12, height = 4)
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(mod.mountains, main = "RAD - M",  ylab = "log10(Ab. relativa)", xlab = "Rangos")
plot(mod.plains,    main = "RAD - P",  ylab = "log10(Ab. relativa)", xlab = "Rangos")
plot(mod.mouth,     main = "RAD - RM", ylab = "log10(Ab. relativa)", xlab = "Rangos")
dev.off()

# Modelos con mejor ajuste
dev.new(width = 12, height = 4)
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(mod.mountains$models$Preemption,
     main = "M - Preemption",
     ylab = "log10(Ab. Relativa)", xlab = "Rangos")
plot(mod.plains$models$Null,
     main = "P - Null",
     ylab = "log10(Ab. Relativa)", xlab = "Rangos")
plot(mod.mouth$models$Mandelbrot,
     main = "RM - Mandelbrot",
     ylab = "log10(Ab. Relativa)", xlab = "Rangos")
dev.off()


# ---------------------------------------------------------
# c. Diagnóstico de supuestos
# ---------------------------------------------------------

# c.1 Normalidad multivariada
Estacion_M  <- biol1 %>% dplyr::filter(Sites1 == "M")
Estacion_P  <- biol1 %>% dplyr::filter(Sites1 == "P")
Estacion_RM <- biol1 %>% dplyr::filter(Sites1 == "RM")

# c.2 Homogeneidad de covarianzas
biol1 <- biol1 %>% na.omit()
biol1 <- biol1 %>% mutate(across(-1, ~ replace_na(., 0)))

distancias <- vegdist(biol1[, -c(1)], method = "bray", na.rm = TRUE)
grupo  <- biol1$Sites1
disper <- betadisper(distancias, group = grupo)

anova(disper)
permutest(disper)

# c.3 Independencia de los datos
biol1b <-
  biol1 %>%
  mutate(Total = rowSums(across(-Sites1, ~ replace_na(as.numeric(.), 0))))

modelo <- lm(biol1b$Total ~ Sites1, data = biol1b)
durbinWatsonTest(modelo)

cat("\nCaso A.1 finalizado correctamente.\n")
