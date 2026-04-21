# =========================================================
# ANVIDEA - Capítulo 2
# Visualización exploratoria de datos ecológicos
# ---------------------------------------------------------
# Archivo : 01_casoA_mesozooplancton.R
# Caso    : A. Mesozooplancton estuarino
# =========================================================

cat("\n========================================\n")
cat("Caso A - Mesozooplancton estuarino\n")
cat("========================================\n")

# ---------------------------------------------------------
# Cargar paquetes
# ---------------------------------------------------------

library(tidyverse)
library(dplyr)
library(kableExtra)   # Para la edición de tablas
library(readxl)       # Cargar bases de Excel
library(ggrepel)      # Insertar rótulos a los puntos
library(corrplot)     # Figuras de elipses
library(reshape2)     # Figuras de cajas con múltiples variables
library(gridExtra)    # Para figuras estadísticas (varios factores)
library(grid)         # Para figuras estadísticas (varios factores)
library(ggplot2)      # Paquete gráfico
library(forcats)      # Para manipulación de factores
library(viridis)      # Opciones de paletas de colores


# ---------------------------------------------------------
# Preparación de los datos
# ---------------------------------------------------------

# Cargar datos desde Excel
biol <- read_xlsx(archivo_plancton, sheet = "Riqueza")

# Explorar estructura
# glimpse(biol)
# summary(biol)

# Tabla con los datos
head(biol) %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 2) %>%
  kable_classic(full_width = F)


# **Base de datos en formato ancho**

# Procesamiento para ajustar los datos en formato ancho
biol1 <-
  biol %>%
  # Abreviaturas de los taxones
  mutate(Abrev = abbreviate(Groups, minlength = 4)) %>%
  # Variables a factores
  mutate(across(c(Station, Size, Layers), as.factor)) %>%
  # Agrupamiento para el formato ancho
  group_by(Station, Size, Layers) %>%
  # Promedios de las variables ambientales
  summarize(
    across(c(Temperature, Salinity, Density), ~round(mean(.),2)),
    # Totales de las abundancias por cada factor
    Abundance = list(setNames(tapply(Abundance, Abrev, sum,
                                     default = 0), unique(Abrev))),
    # Corregir algunos errores del agrupamiento
    .groups = "drop") %>%
  # Separar las abundancias en las columnas de cada taxon
  unnest_wider(Abundance) %>%
  # Crear columna Ref, tomando iniciales de tres factores
  mutate(
    Ref = paste0(substr(Station, 1, 2),
                 substr(Size, 1, 1),
                 substr(Layers, 1, 1))) %>%
  # Pasar la columna de referencia (consec) a la 1a columna
  select(Ref, everything()) %>%
  # Crear la columna Ab con la suma de las columnas de taxones
  mutate(
    # Suma de las columnas especificadas (Ab)
    Ab = rowSums(across(Qtgn:Otrs), na.rm = TRUE)
  ) %>%
  # Mover la columna de abundancias (AB)
  select(Ref, Station, Size, Layers, Temperature,
         Salinity, Density, Ab, everything())

# Tabla con los datos
head(biol1, 4) %>%
  dplyr::select(1:10) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = F)


# ---------------------------------------------------------
# 1. Tipos de operaciones con tidyverse
# ---------------------------------------------------------

# select — seleccionar columnas de interés
datos_select <- biol %>%
  dplyr::select(Station, Size, Layers, Groups, Abundance,
                Temperature, Salinity, Density)

# filter — filtrar por estación
datos_filtro <- biol %>%
  dplyr::filter(Station == 2)

# mutate — crear nueva variable derivada
biol_rel <- biol %>%
  dplyr::mutate(rel_abund_temp = Abundance / Temperature)

# summarise — estadísticos por grupo (2 factores)
datos_resumidos <-
  biol %>%
  group_by(Station, Size) %>%
  summarise(datos.m   = mean(Abundance, na.rm = TRUE),
            datos.de  = sd(Abundance,   na.rm = TRUE),
            datos.var = var(Abundance,  na.rm = TRUE),
            datos.n   = n(),
            .groups = "drop")

# summarise — estadísticos por grupo (3 factores)
datos_resumidos1 <-
  biol %>%
  group_by(Station, Size, Layers) %>%
  summarise(datos.m   = mean(Abundance, na.rm = TRUE),
            datos.de  = sd(Abundance,   na.rm = TRUE),
            datos.var = var(Abundance,  na.rm = TRUE),
            datos.n   = n(),
            datos.ee  = sd(Abundance, na.rm = TRUE) / sqrt(n()),
            .groups = "drop")

# pivot_longer — formato largo para variables ambientales
datos_largo <- biol %>%
  pivot_longer(
    cols      = c(Temperature, Salinity, Density),
    names_to  = "variable_ambiental",
    values_to = "valor"
  )

# pivot_wider — recuperar formato ancho
datos_ancho <- datos_largo %>%
  pivot_wider(
    names_from  = variable_ambiental,
    values_from = valor,
    values_fn   = dplyr::first
  )

# mutate — transformaciones logarítmica, raíz y estandarización
biol_transformado <- biol %>%
  mutate(
    log_abundancia  = log1p(Abundance),
    sqrt_abundancia = sqrt(Abundance),
    temp_std        = as.numeric(scale(Temperature)),
    sal_std         = as.numeric(scale(Salinity))
  )

# Transponer: taxones como columnas, estaciones como filas
datos_transp <- biol %>%
  select(Station, Groups, Abundance) %>%
  group_by(Station, Groups) %>%
  summarise(Abundance = sum(Abundance, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Station, values_from = Abundance, values_fill = 0)

datos_transp1 <- datos_transp %>%
  pivot_longer(cols = -Groups, names_to = "Station", values_to = "valor") %>%
  pivot_wider(names_from = Groups, values_from = valor)

# left_join — unir tabla de abreviaciones
tabla_abrev <- biol %>%
  distinct(Groups) %>%
  mutate(Abrev = abbreviate(Groups, minlength = 4))

biol1_join <- biol %>%
  left_join(tabla_abrev, by = "Groups")

# Taxones más abundantes (promedio)
biol_ancho <- biol1

abundantes <- biol1 %>%
  select(Qtgn:Otrs) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE))) %>%
  pivot_longer(everything(), names_to = "Grupo", values_to = "Promedio") %>%
  arrange(desc(Promedio))

biol_selec <- abundantes %>%
  slice_head(n = 15)


# ---------------------------------------------------------
# 2. Exploración de relaciones
# ---------------------------------------------------------

# Objetivo: Explorar y comprender las relaciones entre variables
# biológicas y ambientales mediante herramientas gráficas que
# permitan identificar asociaciones lineales y no lineales,
# patrones de dependencia y posibles gradientes ecológicos.


# 2.1 Figuras de elipses y correlogramas
# ----------------------------------------

# Selección de variables biológicas y ambientales
# str(biol1)
# Variables ambientales columnas 5 a 7, biológicas columnas 8 a 20

# Elipses con colores
M <- cor(biol1[,8:20], use = "pairwise.complete.obs")  # Matriz de Correlación (M)

# Figura 10 — Figura de correlaciones con elipses
guardar_base_plot("casoA_fig_corr_ellipse.png",
                  corrplot(M, method = "ellipse"), width = 7, height = 7)

# Figura 11
guardar_base_plot("casoA_fig_corr_mixed.png",
                  corrplot.mixed(M, upper = "ellipse"), width = 7, height = 7)

# Figura 12
guardar_base_plot("casoA_fig_corr_circle.png", {
  corrplot(M, method = "circle",           # Correlaciones con circulos
           type = "lower", insig = "blank",# Forma del panel
           order = "AOE", diag = FALSE,    # Ordenar por nivel de correlación
           addCoef.col = "black",          # Color de los coeficientes
           number.cex = 0.8,              # Tamaño del texto
           col = COL2("RdYlBu", 200))     # Transparencia de los circulos
}, width = 8, height = 8)

# Elipses con colores
M1 <- cor(biol1[,5:7], biol1[,8:20], use = "pairwise.complete.obs")  # Matriz de Correlación (M)

# Figura 13
guardar_base_plot("casoA_fig_corr_amb_taxa.png",
                  corrplot(M1, method = "ellipse", type = "upper"), width = 8, height = 6)


# 2.2 Figuras de dispersión por pares de variables (pairs)
# ----------------------------------------

# Figura 14 — pairs con panel.hist, panel.cor y panel.smooth2
# (funciones definidas en 03_funciones_auxiliares.R)
guardar_base_plot("casoA_fig_pairs.png", {
  pairs(biol1[, c(5:7)],
        diag.panel  = panel.hist,
        upper.panel = panel.cor,
        lower.panel = panel.smooth2)
}, width = 8, height = 8)


# 2.3 Histogramas
# ----------------------------------------

# Cambiar etiquetas de Layers con recode_factor()
biol1 <-
  biol1 %>%
  mutate(Layers = recode_factor(Layers,
                                "Depth"   = "Profunda",
                                "Surface" = "Superficial"))

# Figura 15 — Frecuencias de abundancias por densidad
fig_densidad_capas <-
  ggplot(data = biol1, aes(x = Ab, color = Layers)) +
  geom_density(aes(fill = Layers), alpha = 0.5) +
  labs(y = "Frecuencia", x = "Abundancia",
       color = "Capas", fill = "Capas") +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_densidad_capas)

# Figura 16 — Otra opción
fig_densidad_capas_malla <-
  ggplot(data = biol1, aes(x = Ab, color = Layers)) +
  geom_density(aes(fill = Layers)) +
  labs(y = "Frecuencia", x = "Abundancia",
       color = "Capas", fill = "Capas") +
  facet_wrap(~ Size) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_densidad_capas_malla)


# 2.4 Dispersión X-Y
# ----------------------------------------

# Figura 17 — Regresiones lineales (Esquema ggplot2)
fig_lineal_ab_dens <-
  ggplot(biol1, aes(x = Density, y = Ab)) +
  geom_point(aes(color = Layers), size = 3) +
  geom_smooth(method = "lm") +
  labs(y = "Abundancia de zooplancton",
       x = "Densidad de individuos",
       color = "Capas", fill = "Capas") +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_lineal_ab_dens)

# Figura 18 — Regresiones suavizadas - Loess o Lowess (Esquema ggplot2)
fig_loess_ab_dens1 <-
  ggplot(biol1, aes(x = Density, y = Ab)) +
  geom_point(aes(color = Layers), size = 3) +
  geom_smooth() +
  labs(y = "Abundancia de zooplancton",
       x = "Densidad de individuos",
       color = "Capas", fill = "Capas") +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_loess_ab_dens1)

# Figura 19 — Regresiones suavizadas (Loess)
fig_loess_ab_dens2 <-
  ggplot(biol1, aes(x = Density, y = Ab)) +
  geom_point(aes(color = Layers), size = 3) +
  geom_smooth(se = FALSE, span = 0.5) +
  labs(y = "Abundancia de zooplancton",
       x = "Densidad de individuos",
       color = "Capas", fill = "Capas") +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_loess_ab_dens2)


# ---------------------------------------------------------
# 3. Exploración de diferencias entre muestras
# ---------------------------------------------------------

# Objetivo: Visualizar diferencias o variaciones entre muestras
# de variables agrupadoras como estaciones de muestreo, capas
# de profundidad o tamaños de ojo de malla.


# 3.1 Cajas y Bigotes
# ----------------------------------------

# a. Cajas con un factor: Estaciones

# Convertir variables a factores en caso que se requiera
biol1 <-
  biol1 %>%
  mutate(across(c(Station, Size, Layers), as.factor))

# Figura 20 — Gráfico de caja de la abundancia por estación
fig_estacion <-
  ggplot(biol, aes(x = factor(Station), y = Abundance)) +
  geom_boxplot(aes(fill = factor(Station))) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594',
                               '#377eb8','#e78ac3','#7570b3')) +
  labs(title = "",
       x = "Estaciones", fill = "Estaciones",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_estacion)

# geom_boxplot(notch = T,... para las muescas.


# b. Cajas con dos factores: Estaciones y capas

library(forcats)  # Para manipulación de factores

# Cambiar etiquetas de Layers con recode_factor()
biol <-
  biol %>%
  mutate(Layers = recode_factor(Layers,
                                "Depth"   = "Profunda",
                                "Surface" = "Superficial"))

# Cambiar etiquetas de Layers con recode_factor()
biol1 <-
  biol1 %>%
  mutate(Layers = recode_factor(Layers,
                                "Depth"   = "Profunda",
                                "Surface" = "Superficial"))

# Figura 21 — Gráfico de caja de la abundancia por estación
fig_capas <-
  ggplot(biol1, aes(x = factor(Station), y = Ab)) +
  geom_boxplot(aes(fill = Layers)) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  labs(title = "",
       x = "Estaciones", fill = "Capas",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_capas)

#   facet_wrap(~ Layers, scales = "free")  # Paneles por variable


# c. Cajas con diferentes variables: Ambientales

# Figura 22 — Figuras multivariadas de Cajas y bigotes
fig_capas_facetas <-
  ggplot(melt(biol1[,c(2,5:7)]), aes(x = Station, y = value)) +  # Usar Station en el eje X
  geom_boxplot(aes(fill = Station)) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  scale_color_viridis(discrete = TRUE) +
  labs(title = "",
       x = "Estaciones", fill = "Estaciones",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  facet_wrap(~ variable, scales = "free") +  # Paneles por variable
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_capas_facetas)


# d. Categorización manual de variables ambientales (Temperatura y Salinidad)

# Categorización de la temperatura
biol <-
  biol %>%
  mutate(claseTemp = case_when(
    Temperature <= quantile(Temperature, 1/3, na.rm = TRUE) ~ "T.Baja",
    Temperature <= quantile(Temperature, 2/3, na.rm = TRUE) ~ "T.Media",
    Temperature <= quantile(Temperature, 3/3, na.rm = TRUE) ~ "T.Alta"
  ))

# Categorización de la salinidad
biol <-
  biol %>%
  mutate(claseSal = case_when(
    Salinity <= quantile(Salinity, 1/3, na.rm = TRUE) ~ "S.Baja",
    Salinity <= quantile(Salinity, 2/3, na.rm = TRUE) ~ "S.Media",
    Salinity <= quantile(Salinity, 3/3, na.rm = TRUE) ~ "S.Alta"
  ))

# Se puede resumir el nivel alto por el comando "TRUE ~ "Alta"".

# Figura 23
fig_salinidad_terciles <-
  ggplot(biol, aes(x = factor(Station), y = Abundance)) +
  geom_boxplot(aes(fill = claseTemp)) +
  labs(title = "",
       x = "Estaciones", fill = "Temperatura",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  scale_color_viridis(discrete = TRUE) +
  facet_wrap(~ claseSal, nrow = 1, strip.position = "top") +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_salinidad_terciles)


# 3.2 Figuras con estimadores estadísticos
# ----------------------------------------

# a. Base de datos con múltiples factores

# Resumen estadístico "datos_resum_A"
datos_resum_A <-
  biol1 %>%        # Base de datos resumida
  group_by(Size, Layers) %>%           # Factor o variable agrupadora
  summarise(datos.m   = mean(Ab),      # Media de cada grupo del factor
            datos.de  = sd(Ab),        # Desviaciones estándar de cada grupo
            datos.var = var(Ab),       # Varianzas de cada grupo
            n.Biom    = n(),           # Tamaño de cada grupo
            datos.ee  = sd(Ab)/sqrt(n()))  # Error estándar de cada grupo

# Tabla con los datos
head(datos_resum_A) %>%
  kbl(booktabs = TRUE, longtable = TRUE, digits = 2) %>%
  kable_classic(full_width = F)

# Figura 24 (f1)
f1 = ggplot(datos_resum_A, aes(x = Layers, y = datos.m, fill = Size)) +
     geom_bar(stat = "identity", color = "black",
              position = position_dodge()) +
     geom_errorbar(aes(ymin = datos.m, ymax = datos.m + datos.de), width = .2,
                   position = position_dodge(.9))

# f2: Otro formato de figura bifactorial - theme_classic
f2 = f1 + labs(title = "",
               x = "Capas",
               y = "Abundancia", fill = "Malla") +
     theme_classic() +
     scale_fill_manual(values = c('#E69F00','#999999'))

# Impresión de un panel con las dos figuras de forma horizontal (f1 y f2)
guardar_base_plot("casoA_fig_barras_error_ncol.png",
                  grid.arrange(f1, f2, ncol = 2), width = 10, height = 5)

# Impresión de un panel con las dos figuras de forma vertical (f1 y f2)
guardar_base_plot("casoA_fig_barras_error_nrow.png",
                  grid.arrange(f1, f2, nrow = 2), width = 6, height = 9)


# ---------------------------------------------------------
# 4. Figuras de Burbujas
# ---------------------------------------------------------


# 4.1 Ejercicio con datos hipotéticos
# ----------------------------------------

# Datos de ejemplo
x      <- c(2, 5, 7, 3, 6, 1, 9, 2)
y      <- c(2.2, 2, 1, 2, 1, 4, 1, 6)
size   <- c(100, 30, 50, 250, 120, 140, 80, 36)
group  <- c("A", "A", "A", "B", "C", "B", "D", "B")
group1 <- c("A1", "A2", "A3", "B1", "C1", "B2", "D1", "B2")

# Data frame
datos_burb <- data.frame(x, y, size, group, group1)

# a. Burbujas con leyenda afuera

# Figura 26
fig_burb_ext <-
  ggplot(datos_burb, aes(x = x, y = group1, size = size, color = group)) +
  geom_point(alpha = 0.8) +
  scale_size(range = c(1, 10)) +
  theme_bw() +
  theme(legend.position = "right")

print(fig_burb_ext)

# b. Burbujas con leyenda adentro

# Figura 27
fig_burb_int <-
  ggplot(datos_burb, aes(x = x, y = group1, size = size, color = group)) +
  geom_point(alpha = 0.8) +
  scale_size(range = c(1, 10)) +
  theme_bw() +
  theme(legend.position = c(0.85, 0.35))

print(fig_burb_int)


# 4.2 Ejercicio con datos de Plancton Estuarino
# ----------------------------------------

# Organización de la base de datos
datos1a <- biol1 %>%
  select(Station, Salinity, Qtgn:Otrs) %>%
  pivot_longer(
    cols      = Qtgn:Otrs,
    names_to  = "Taxas",
    values_to = "Abundancia"
  ) %>%
  filter(Abundancia > 0)

# Calcular la Abundancia total por grupo, para luego ordenar taxones
Abundancia_order1 <-
  datos1a %>%
  group_by(Taxas) %>%
  summarise(total_Abundancia = sum(Abundancia)) %>%
  arrange((total_Abundancia)) %>%
  pull(Taxas)

# Ordenar taxones de menor a mayor abundancia
datos1a$Taxas <- factor(datos1a$Taxas, levels = Abundancia_order1)

# Figura 28 — Leyenda afuera (Salinidad)
fig_burb_salinidad1 <-
  ggplot(datos1a, aes(x = Salinity, y = Taxas,
                      size = Abundancia, color = as.factor(Station))) +
  geom_point(alpha = 0.7) +
  scale_size(range = c(1.4, 10)) +
  labs(color = "Estaciones", size = "") +
  theme_bw()

print(fig_burb_salinidad1)

# Figura 29 — Leyenda adentro (Salinidad)
fig_burb_salinidad2 <-
  ggplot(datos1a, aes(x = Salinity, y = Taxas,
                      size = Abundancia, color = as.factor(Station))) +
  geom_point(alpha = 0.7) +
  scale_size(range = c(1.4, 10)) +
  scale_color_viridis(discrete = TRUE) +
  labs(color = "", size = "") +
  theme_bw()

print(fig_burb_salinidad2)


cat("\nCaso A finalizado correctamente.\n")
