# =========================================================
# ANVIDEA - Capítulo 2
# Visualización exploratoria de datos ecológicos
# ---------------------------------------------------------
# Archivo : 02_casoB_macroinvertebrados.R
# Caso    : B. Macroinvertebrados bentónicos fluviales
# =========================================================

cat("\n========================================\n")
cat("Caso B - Macroinvertebrados bentónicos fluviales\n")
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
library(scales)       # Formato de ejes


# ---------------------------------------------------------
# Carga y exploración de datos
# ---------------------------------------------------------

# Lectura de la base de datos xlsx
biol <- read_xlsx(archivo_invert, "Taxones1")

# View(biol)
# str(biol) # taxones 3:33

# Impresión de la tabla con los datos
biol %>%
  dplyr::select(1:7) %>%
  kbl(booktabs = F, longtable = T) %>%
  kable_classic(full_width = F, html_font = "Cambria")


# a. Abreviación de los nombres de los taxones (biol1)

# Nombres abreviados de los taxones
biol1 <-
  biol[,c(-1,-2)] %>%
  rename_with(~ abbreviate(.x, minlength = 4))

# Impresión de la tabla con los datos
biol1 %>%
  dplyr::select(1:12) %>%
  kbl(booktabs = F, longtable = T) %>%
  kable_classic(full_width = F, html_font = "Cambria")


# b. Tabla con nombres completos y abreviados en formato largo

# Lectura de la base de datos
tabla <- read_xlsx(archivo_invert, "Taxones2")

# Datos en formato largo
tabla <-
  tabla %>%
  pivot_longer(       # Formato ancho a largo
    cols = -c(Sitio), # Pivotea todas las columnas excepto "Sitio"
    names_to  = "Taxas",       # Nombre de la nueva y única columna "Taxas"
    values_to = "Abundancia"   # Valores de las columnas en columna "Abundancia"
  )

# Tabla con nombres abreviados de las familias y numeración de filas
tabla_abrev <-
  tabla %>%
  select(Taxas) %>%  # Selecciona solo la columna "Taxas"
  distinct() %>%     # Elimina duplicados para dejar una fila por c/taxón
  mutate(Abrev = substr(Taxas, 1, 4),  # Columna "Abrev" con nombres abrev
         ID = row_number()) %>%         # Consecutivo "ID" desde 1
  select(ID, everything())             # Ubica a "ID" en la primera columna

# Tabla con taxones
head(tabla_abrev) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = F)


# c. Incluir la columna de abundancias totales

# Leer la tabla original
tabla2 <- read_xlsx(archivo_invert, sheet = "Taxones2")

# Crear fila de totales de abundancia
total <-
  tabla2 %>%
  select(-1) %>%           # Excluye la primera columna (taxones)
  summarise(across(everything(),
                   sum, na.rm = TRUE)) %>%  # Suma los valores (por sitio)
  mutate(Sitio = "Total") %>%               # Agrega fila "Total" en columna "Sitio"
  select(Sitio, everything())               # Reordena columna "Sitio" al principio

# Ubica a la fila "Total" al final de la tabla original
tabla_total <- bind_rows(tabla2, total)

# Filtrar solo la fila Total, pivotear y limpiar
tabla_totales <-
  tabla_total %>%
  filter(Sitio == "Total") %>%     # Selecciona solo la fila "Total" de "Sitio"
  pivot_longer(cols = -Sitio,      # Convierte columna Sitio a una columna "Taxas"
               names_to = "Taxas",
               values_to = "Abundancia") %>%
  select(-Sitio) %>%                    # Eliminar "Sitio" porque solo tiene "Total"
  mutate(
    Abrev = substr(Taxas, 1, 4)) %>%    # Crea columna "Abrev" de cada taxón
  arrange(desc(Abundancia)) %>%         # Ordena de mayor a menor abundancia
  mutate(ID = row_number()) %>%         # Crea columna "ID" con numeración
  select(ID, Taxas, Abrev, everything())  # Ordena columnas de la tabla

# Tabla con taxones
head(tabla_totales, 8) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = F)


# d. Taxones más abundantes con nombres abreviados (biol2)

# Extraer los promedios de las abundancias
prom <- colMeans(biol1[,1:31])  # Columna 32 se excluye por ser el total de ab.

# Extraer los 15 taxones más abundantes. FALSE muestra las 15 menos abundantes
ab <- names(sort(prom, decreasing = TRUE)[1:15])

# Crear un nuevo dataframe con las dos columnas seleccionadas
biol2 <- data.frame(Sitio = biol[,1], biol1[, ab])

biol2 %>%
  dplyr::select(1:12) %>%
  kbl(booktabs = F, longtable = T) %>%
  kable_classic(full_width = F, html_font = "Cambria")


# e. Promedios de los 15 taxones más abundantes (biol3)

# Promedios de abundancia de los taxones
biol3 <-
  biol2 %>%
  group_by(Sitio) %>%   # Agrupamiento por sitios
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE)))

# Impresión de la tabla con los datos
biol3 %>%
  dplyr::select(1:8) %>%
  kbl(booktabs = F, longtable = T, digits = 2) %>%
  kable_classic(full_width = F, html_font = "Cambria")

# Complemento opcional al script "summarise" na.rm = TRUE, .names = "{.col}"


# f. Base de datos ambiental

amb <- read_xlsx(archivo_invert, hoja_fq)
amb = amb[,c(-13,-15,-16,-17)]

# Impresión de la tabla con los datos
amb %>%
  dplyr::select(1:9) %>%
  kbl(booktabs = F, longtable = T, digits = 3) %>%
  kable_classic(full_width = F, html_font = "Cambria")

# View(amb)
# str(amb) # ambientales 3:26


# g. Promedios de las variables ambientales (amb1)

# Promedios de variables ambientales
amb1 <-
  amb %>%
  group_by(Sitio) %>%
  summarise(across(-Replica, mean, na.rm = TRUE, .names = "{.col}"))

# Impresión de la tabla con los datos
amb1 %>%
  dplyr::select(1:9) %>%
  kbl(booktabs = F, longtable = T, digits = 2) %>%
  kable_classic(full_width = F, html_font = "Cambria")

# print(amb1)
# View(amb1)
# str(amb1)


# ---------------------------------------------------------
# 1. Exploración de relaciones
# ---------------------------------------------------------


# 1.1 Figuras de elipses y correlogramas
# ----------------------------------------

# Matriz de correlación
M = cor(biol1, use = "pairwise.complete.obs")

# Figura 30 — Figura de correlaciones
guardar_base_plot("casoB_fig_corr_taxa.png",
                  corrplot(M, "ellipse", order = "AOE"), width = 8, height = 8)


# Preparar tabla larga para barras de dominancia
tabla_inv2 <- read_xlsx(archivo_invert, sheet = "Taxones2")

tabla_long <-
  tabla_inv2 %>%
  select(-Sitio) %>%
  rename_with(~ abbreviate(.x, minlength = 4)) %>%
  mutate(Sitio = tabla_inv2$Sitio) %>%
  select(Sitio, everything()) %>%
  pivot_longer(-Sitio, names_to = "familia", values_to = "abundancia")

# Generar un gráfico de barras de la abundancia media por familia:
tabla_long1 <-
  tabla_long %>%
  group_by(familia) %>%
  summarise(media = mean(abundancia, na.rm = TRUE))

# Figura 31
fig_dom_familias <-
  ggplot(tabla_long1, aes(x = reorder(familia, -media), y = media)) +
  geom_col(fill = "#1f78b4") +
  geom_text(aes(label = round(media, 1)),
            vjust = -0.3, size = 3, color = "black") +
  labs(x = "Familias de Macroinvertebrados",
       y = "Promedio de abundancia",
       title = "") +
  scale_y_continuous(labels = comma) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid  = element_blank())

print(fig_dom_familias)

# Figura 32 — Matriz de correlación
M = cor(amb1[,-1], biol3[,-1], use = "pairwise.complete.obs")

guardar_base_plot("casoB_fig_corr_amb_taxa.png",
                  corrplot(M, "ellipse"), width = 8, height = 6)


# ---------------------------------------------------------
# 2. Exploración de diferencias
# ---------------------------------------------------------

# View(biol)
biol.dif <-
  biol[,-34] %>%
  gather(Taxones, Abundancia, -Sitio, -Microh)

# Impresión de la tabla con los seis (6) primeros datos (filas)
head(biol.dif) %>%
  kbl(booktabs = F, longtable = T) %>%
  kable_classic(full_width = F, html_font = "Cambria")


# 2.1 Cajas y Bigotes: comparación entre grupos
# ----------------------------------------

# a. Diferencias entre sitios

# Figura 33
fig_box_sitio <-
  ggplot(biol.dif, aes(x = Sitio, y = Abundancia)) +
  geom_boxplot(aes(fill = Sitio)) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  labs(title = "",
       x = "Sitios", fill = "Sitios",
       y = expression(log[10]~(Abundancia~de~Insectos))) +
  scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594')) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_box_sitio)


# b. Diferencias entre microhábitats

# Figura 34
fig_box_microh <-
  ggplot(biol.dif, aes(x = Microh, y = Abundancia)) +
  geom_boxplot(aes(fill = Microh)) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  labs(title = "",
       x = "Microhábitats", fill = "Microhábitats",
       y = expression(log[10]~(Abundancia~de~Insectos))) +
  scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594')) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_box_microh)


# c. Sitio × microhábitat: patrón combinado

# Figura 35
fig_box_sitio_microh <-
  ggplot(biol.dif, aes(x = Sitio, y = Abundancia)) +
  geom_boxplot(aes(fill = Microh)) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  labs(title = "",
       x = "", fill = "Microhábitats",
       y = expression(log[10]~(Abundancia~de~Insectos))) +
  scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594')) +
  facet_wrap(~ Sitio, scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_blank()) +
  theme(panel.grid  = element_blank())

print(fig_box_sitio_microh)


# 2.2 Comparación alternativa: barras por observación
# ----------------------------------------

# Figura 36
fig_bar_obs <-
  ggplot(biol.dif, aes(x = Sitio, y = Abundancia)) +
  geom_bar(stat = "identity", aes(fill = Microh),
           position = position_dodge()) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  labs(title = "",
       x = "", fill = "Microhábitats",
       y = expression(log[10]~(Abundancia~de~Insectos))) +
  scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594')) +
  theme_bw() +
  theme(panel.grid  = element_blank())

print(fig_bar_obs)


# 2.3 Figuras con estimadores estadísticos
# ----------------------------------------

# Resumen estadístico "datos_resum_B"
datos_resum_B <-
  biol.dif %>%   # Base de datos resumida
  group_by(Sitio, Microh) %>%  # Factor o variable agrupadora
  summarise(datos.m   = mean(Abundancia),   # Media de cada grupo del factor
            datos.de  = sd(Abundancia),     # Desviaciones estándar de cada grupo
            datos.var = var(Abundancia),    # Varianzas de cada grupo
            n.Ab      = n(),                # Tamaño de cada grupo
            datos.ee  = sd(Abundancia)/sqrt(n()))  # Error estándar de cada grupo

# Impresión de la tabla
datos_resum_B %>%
  kbl(booktabs = F, digits = 2, longtable = T) %>%
  kable_classic(full_width = F, html_font = "Cambria")

# Figura 37
fig_bar_error <-
  ggplot(datos_resum_B, aes(x = Sitio, y = datos.m, fill = Microh)) +
  geom_bar(stat = "identity", color = "black",
           position = position_dodge()) +
  geom_errorbar(aes(ymin = datos.m,
                    ymax = datos.m + datos.de), width = .2,
                position = position_dodge(.9)) +
  labs(x = "", y = "Abundancia de Insectos",
       fill = "Microhábitats") +
  scale_fill_manual(values = c('#E69F00','#4daf4a','#377eb8')) +
  facet_wrap(~ Sitio, scales = "free") +
  theme_bw() +
  theme(axis.text.x = element_blank()) +
  theme(panel.grid  = element_blank())

print(fig_bar_error)


# ---------------------------------------------------------
# 3. Figuras de Burbujas
# ---------------------------------------------------------

# Dataframe con ambientales y biológicas abreviadas
# Hay que dejar solo el factor a graficar (sitios)
datos = data.frame(amb[,-2], biol1)

# Base de datos con variables ambientales seleccionadas
# Eliminar ambientales que no se usarán
datos1 = datos[,-c(2,3,5,7:12, 14:21)]

# Base de datos en formato largo, sin ambientales
datos1a <-
  datos1 %>%
  pivot_longer(
    cols = -c(Sitio, Oxigeno, Amonio, Prof.Media),
    names_to  = "Taxas",
    values_to = "Abundancia"
  )

# Extraer a los valores de abundancias > 0
datos1a <-
  datos1a %>%
  filter(Abundancia > 0)

# Configurar los factores requeridos
datos1a$Taxas = as.factor(datos1a$Taxas)
datos1a$Sitio = as.factor(datos1a$Sitio)

# Calcular la Abundancia total por grupo, para luego ordenar taxones
Abundancia_order1 <-
  datos1a %>%
  group_by(Taxas) %>%
  summarise(total_Abundancia = sum(Abundancia)) %>%
  arrange((total_Abundancia)) %>%
  pull(Taxas)

# Ordenar taxones de menor a mayor abundancia
datos1a$Taxas <- factor(datos1a$Taxas, levels = Abundancia_order1)

# Figura 38 — Por niveles de Oxígeno
fig_burb_oxigeno <-
  ggplot(datos1a, aes(x = Oxigeno, y = Taxas, size = Abundancia, color = Sitio)) +
  geom_point(alpha = 0.7) +
  scale_size(range = c(1.4, 19)) +
  scale_color_viridis(discrete = TRUE) +
  scale_size(name = "Tamaño", range = c(1, 8)) +
  scale_x_continuous(
    limits = c(4.7, 6),           # Rangos que dependen de la variable ambiental
    breaks = seq(4.7, 6, by = 0.4)  # Establecer intervalos de 0.4
  ) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),                    # Eliminar la cuadrícula principal
    panel.grid.minor = element_blank(),                    # Eliminar la cuadrícula menor
    axis.ticks.y     = element_line(color = "black"),      # Marcas de graduación del eje y
    axis.text.x      = element_text(size = 9, angle = 45, hjust = 1),  # Rotar valores eje x
    axis.text.y      = element_text(size = 9),             # Tamaño del texto en el eje y
    axis.title.y     = element_blank()                     # Quitar el título del eje y
  ) +
  geom_vline(xintercept = c(4.7, 5.1, 5.5, 5.9), color = "gray") +
  guides(
    size  = guide_legend(title = NULL,
                         override.aes = list(shape = 1,
                                             color = "#377eb8",
                                             stroke = 1.2)),  # Grosor de los círculos
    color = guide_legend(title = NULL,
                         override.aes = list(size = 5))       # Elimina el título de la leyenda
  )

print(fig_burb_oxigeno)


cat("\nCaso B finalizado correctamente.\n")
