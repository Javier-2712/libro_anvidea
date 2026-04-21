# =========================================================
# ANVIDEA - Capítulo 1
# Fundamentos de manipulación de datos
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

# install.packages("tidyverse") # Instalar en caso de ser necesario
library(tidyverse)   # Manipulación y visualización de datos
library(readxl)      # Lectura de archivos Excel
library(janitor)     # Limpieza de nombres de columnas
library(kableExtra)  # Edición de tablas en Quarto
library(viridis)     # Paletas de color perceptualmente uniformes


# ---------------------------------------------------------
# Preparación de los datos
# ---------------------------------------------------------

# Cargar datos desde Excel.
biol <- read_xlsx(archivo_plancton, sheet = "Riqueza")
# glimpse(biol)
# summary(biol)

# Se recomienda verificar que Station, Size y Layers estén como factores
# si serán usadas como agrupadoras en análisis posteriores.

# biol <- biol %>%
#   mutate(
#     Station = as.factor(Station),
#     Size    = as.factor(Size),
#     Layers  = as.factor(Layers)
#   )


# ---------------------------------------------------------
# 1. Selección y filtrado
# ---------------------------------------------------------

datos_select <-
  biol %>%
  select(Station, Size, Layers, Abundance, Temperature, Salinity)

# Validar distribución: `head()` muestra las primeras filas del dataframe.
head(datos_select, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = F)

datos_filtro =
  biol %>%
  filter(Temperature > 28)

head(datos_filtro, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = F)

# Se construye `rel_Ab_Temp` dividiendo `Abundance` por `Temperature`.
biol_rel =
  biol %>%
  mutate(rel_Ab_Temp = Abundance / Temperature)

# Validar distribución: primeras filas del dataframe con la nueva variable.
head(biol_rel, 4) %>%
  dplyr::select(c(1:6, 9)) %>%
  kbl(booktabs = TRUE, digits = 3, longtable = TRUE) %>%
  kable_classic(full_width = F)


# ---------------------------------------------------------
# 3. Resumen estadístico de datos agrupados
# ---------------------------------------------------------

# Asegurar que las variables agrupadoras estén definidas como factores
biol <- biol %>%
  mutate(
    Station = as.factor(Station),
    Size    = as.factor(Size)
  )

# Resumen estadístico de un factor "datos_resumidos" por estaciones
datos_resumidos <-
  biol %>%
  group_by(Station, Size) %>%
  summarise(
    datos.m   = mean(Abundance, na.rm = TRUE),   # Media
    datos.de  = sd(Abundance,   na.rm = TRUE),   # Desviación estándar
    datos.var = var(Abundance,  na.rm = TRUE),   # Varianza
    datos.n   = n(),                             # Tamaño de muestra
    .groups   = "drop"
  )

# Validar distribución: Muestra las primeras 4 filas de la tabla resumida.
head(datos_resumidos, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Resumen estadístico de tres factores "datos_resumidos1"
datos_resumidos1 =
  biol %>%
  group_by(Station, Size, Layers) %>%
  summarise(datos.m   = mean(Abundance, na.rm = TRUE),   # Medias
            datos.de  = sd(Abundance,   na.rm = TRUE),   # Desviaciones
            datos.var = var(Abundance,  na.rm = TRUE),   # Varianzas
            datos.n   = n(),                             # Tamaño de la muestra
            datos.ee  = sd(Abundance,   na.rm = TRUE) /  # Error estándar
                        sqrt(n())
            )

# Validar distribución: Muestra las primeras filas de la tabla resumida.
head(datos_resumidos1, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 4. Transformación de datos
# ---------------------------------------------------------

# Convertir columnas "Temperature, Salinity, Density" de formato ancho a largo
datos_largo <-
  biol %>%
  pivot_longer(
    cols     = c(Temperature, Salinity, Density),  # Estas columnas en 1 sola
    names_to  = "Environmental_Variable",           # Nombre de la nueva columna
    values_to = "Value"                             # Valores de las columnas
  )

# Validar distribución: Primeras filas del dataframe en formato largo.
head(datos_largo, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = F)

# Convertir columnas "Temperature, Salinity, Density" de formato largo a ancho
datos_ancho <-
  datos_largo %>%
  # Usa esta columna (Environmental_Variable) para crear nuevas columnas
  pivot_wider(names_from  = Environmental_Variable,
              values_from = Value,    # Valores de las nuevas columnas
              values_fn   = first)    # Primer valor en caso de duplicados

# Validar distribución: primeras filas del dataframe en formato ancho.
head(datos_ancho, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = F)

# Transformaciones usando mutate()
biol_transformado <-
  biol %>%
  mutate(
    log_abundancia     = log1p(Abundance),       # log(x + 1)
    sqrt_abundancia    = sqrt(Abundance),        # raíz cuadrada
    temp_estandarizada = as.numeric(scale(Temperature)),
    sal_estandarizada  = as.numeric(scale(Salinity))
  )

# Comparar transformaciones
biol_transformado %>%
  select(Groups, Abundance, log_abundancia, sqrt_abundancia,
         Temperature, temp_estandarizada) %>%
  slice_head(n = 8) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 5. Transposición de datos
# ---------------------------------------------------------

# Agrupar a los taxones en filas y a las estaciones en columnas
datos_transp <-
  biol %>%
  select(Station, Groups, Abundance) %>%
  group_by(Station, Groups) %>%
  summarise(
    Abundance = sum(Abundance, na.rm = TRUE),  # Suma la ab. por grupo y estación
    .groups   = "drop"
  ) %>%
  pivot_wider(
    names_from  = Station,
    values_from = Abundance,    # Convierte "Station" en nuevas columnas.
    values_fill = 0             # Evita generar NA que pueden afectar análisis.
  )

# Validar distribución: Muestra las primeras filas de la tabla transpuesta.
head(datos_transp, 4) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Transponer la anterior usando pivot_longer y pivot_wider
datos_transp1 <-
  datos_transp %>%
  pivot_longer(cols      = -1,              # Todas las columnas excepto la primera
               names_to  = "Station",       # Los nombres de las columnas se almacenan
               values_to = "value") %>%
  # Usa la primera columna original para crear nuevas columnas
  pivot_wider(names_from  = names(datos_transp)[1],
              values_from = value)          # Valores se colocan en las nuevas columnas

# Validar distribución: Muestra las primeras filas de la tabla transpuesta.
head(datos_transp1, 4) %>%
  dplyr::select(c(1:7)) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 6. Unión de datos
# ---------------------------------------------------------

# Se requiere a Station como factor
biol$Station = as.factor(biol$Station)

# Crear una base de datos adicional de regiones (nueva variable)
Regiones =
  tibble(Station = c("2",  "4",  "7",  "9", "13", "15"),
         Region  = c("Norte", "Sur", "Este", "Oeste", "Central", "Otras"))

# Unir bases de datos con `left_join()`
biol1 =
  biol %>%
  left_join(Regiones, by = "Station")

# Validar distribución: Muestra las primeras filas del dataframe combinado.
head(biol1, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 7. Conversión de variables a factores
# ---------------------------------------------------------

# Opción con Tidy, (across) para "Station, Size y Layers"
biol <-
  biol %>%
  mutate(across(c(Station, Size, Layers), as.factor))

# Validar distribución: Muestra las primeras filas del dataframe
# con las variables convertidas.
head(biol, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 8. Abreviar nombres de grupos biológicos
# ---------------------------------------------------------

# Nueva columna "Abrev" al final, con abreviaturas de los taxas
biol =
  biol %>%
  mutate(Abrev = abbreviate(Groups, minlength = 4))

# Editar tabla: Muestra las primeras filas del dataframe con las abreviaturas.
head(biol, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Tabla adicional, con nombres completos y abreviados de los taxones
tabla_abrev <-
  cbind(Grupos = biol[, 4],
        Abreviaturas = biol$Abrev)

# Editar tabla: Muestra las primeras filas de la tabla de abreviaturas.
head(tabla_abrev, 6) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Procesamiento para ajustar los datos en formato ancho
biol_ancho <-
  biol %>%
  # Variables a factores
  mutate(across(c(Station, Size, Layers), as.factor)) %>%
  # Variables agrupadoras
  group_by(Station, Size, Layers) %>%
  # Promedios de las variables ambientales
  summarize(
    across(c(Temperature, Salinity, Density), ~ round(mean(.), 2)),
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
  select(Ref, everything())

# Validar distribución: primeras filas del dataframe `biol_ancho`.
head(biol_ancho, 4) %>%
  dplyr::select(1:10) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 9. Seleccionar los 5 taxones más abundantes
# ---------------------------------------------------------

# Cinco (5) grupos taxonómicos más abundantes
cols_taxa <- setdiff(names(biol_ancho),
                     c("Ref", "Station", "Size", "Layers",
                       "Temperature", "Salinity", "Density"))

abundantes <-
  biol_ancho %>%
  ungroup() %>%          # Elimina cualquier agrupación previa
  select(all_of(cols_taxa)) %>%
  summarise(across(everything(),
                   sum, na.rm = TRUE)) %>%  # Abundancia total de cada grupo
  pivot_longer(cols      = everything(),
               names_to  = "Grupo",
               values_to = "Total") %>%     # Convierte a formato largo
  arrange(desc(Total)) %>%                  # Ordena de mayor a menor
  slice_head(n = 5)                         # 5 grupos más abundantes

# Validar distribución
head(abundantes, 5) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Filtrar en biol_ancho solo estos 5 taxones más abundantes
biol_selec <-
  biol_ancho %>%
  select(Ref, Station, Size, Layers,
         Temperature, Salinity, Density,
         all_of(abundantes$Grupo))  # Mantiene solo los grupos seleccionados

# Validar distribución
head(biol_selec, 4) %>%
  dplyr::select(1:10) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 10. Visualización de factores
# ---------------------------------------------------------

# Convertir variables a factores en caso que se requiera
biol <-
  biol %>%
  mutate(across(c(Station, Size, Layers), as.factor))

# Figura 1 — Gráfico de caja de la abundancia por estación
fig_estacion <-
  ggplot(biol, aes(x = factor(Station), y = Abundance)) +
  geom_boxplot(aes(fill = factor(Station))) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  scale_fill_manual(values = c('#fc8d59','#ffffbf','#99d594',
                               '#377eb8','#e78ac3','#7570b3')) +
  labs(title = "Distribución de la Abundancia por Estación",
       x = "Estaciones", fill = "Estaciones",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

print(fig_estacion)
# probar: scale_color_viridis(discrete = TRUE)

# Figura 2 — Cambiar etiquetas de Layers con recode_factor()
biol <-
  biol %>%
  mutate(Layers = recode_factor(Layers,
                                "Depth"   = "Profunda",
                                "Surface" = "Superficial"))

fig_capas <-
  ggplot(biol, aes(x = factor(Station), y = Abundance)) +
  geom_boxplot(aes(fill = Layers)) +
  scale_y_continuous(trans = "log10") +  # Transformación logarítmica
  labs(title = "Distribución de la Abundancia por Estación",
       x = "Estaciones", fill = "Capas",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

print(fig_capas)

# Figura 3 — Con facetas por tamaño de malla
# Cambiar etiquetas de Layers con recode_factor()
biol <-
  biol %>%
  mutate(Layers = recode_factor(Layers,
                                "Depth"   = "Profunda",
                                "Surface" = "Superficial"))

fig_capas_facetas <-
  ggplot(biol, aes(x = factor(Station), y = Abundance)) +
  geom_boxplot(aes(fill = Layers)) +
  labs(
    x = "Estaciones", fill = "Capas",
    y = expression(log[10]~(Abundancia~indv.~m^-3))
  ) +
  scale_y_continuous(trans = "log10") +  # Aplicar la transformación logarítmica
  scale_color_viridis(discrete = TRUE) +
  facet_wrap(~ Size, nrow = 1, strip.position = "top") +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

print(fig_capas_facetas)


# ---------------------------------------------------------
# 11. Categorizar una variable continua
# ---------------------------------------------------------

# a.) Método basado en cuantiles (terciles)

biol <-
  biol %>%
  mutate(Salinity_Level = case_when(
    Salinity <= quantile(Salinity, 1/3, na.rm = TRUE) ~ "Baja",
    Salinity <= quantile(Salinity, 2/3, na.rm = TRUE) ~ "Media",
    Salinity <= quantile(Salinity, 3/3, na.rm = TRUE) ~ "Alta"
  ))
# Se puede resumir el nivel alto por el comando "TRUE ~ "Alta"".

# Validar distribución
head(biol, 4) %>%
  dplyr::select(c(1:7, 10)) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura 4 — Distribución de la Abundancia por Niveles de Salinidad
fig_salinidad_terciles <-
  ggplot(biol, aes(x = Salinity_Level, y = Abundance)) +
  geom_boxplot(aes(fill = Salinity_Level)) +
  scale_y_continuous(trans = "log10") +  # Transformación logarítmica
  scale_fill_manual(values = c('#fc8d59','#99d594','#377eb8')) +
  labs(title = "Distribución de la Abundancia por Niveles de Salinidad",
       x = "Niveles de Salinidad", fill = "Salinidad",
       y = expression(log[10]~(Abundancia~indv.~m^-3))) +
  theme_bw() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

print(fig_salinidad_terciles)


# b.) Método "manual" con apoyo de `summary()`

summary(biol$Salinity)

biol <-
  biol %>%
  mutate(Salinity_Level = case_when(
    Salinity < 30                     ~ "Baja",
    Salinity >= 30 & Salinity < 35    ~ "Media",
    Salinity >= 35                    ~ "Alta"
  ))
# Se puede resumir el nivel alto por el comando "TRUE ~ "Alta"".

# Validar distribución
head(biol, 4) %>%
  dplyr::select(c(1:7, 10)) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# c.) Método basado en `summarise()` + categorización ecológica (estuarina)

# Analizar distribución de salinidad usando summarise()
resumen_salinidad <-
  biol %>%
  summarise(
    minimo  = min(Salinity,                    na.rm = TRUE),
    q25     = quantile(Salinity, 0.25,         na.rm = TRUE),
    mediana = median(Salinity,                 na.rm = TRUE),
    q75     = quantile(Salinity, 0.75,         na.rm = TRUE),
    maximo  = max(Salinity,                    na.rm = TRUE),
    media   = mean(Salinity,                   na.rm = TRUE),
    sd      = sd(Salinity,                     na.rm = TRUE)
  )

resumen_salinidad %>%
  kbl(booktabs = TRUE, digits = 2) %>%
  kable_classic(full_width = FALSE)

# Crear categorías de salinidad usando mutate() y case_when()
biol_sal <-
  biol %>%
  mutate(
    salinidad_categoria = case_when(
      Salinity < 5  ~ "Dulce",
      Salinity < 18 ~ "Oligohalina",
      Salinity < 30 ~ "Mesohalina",
      Salinity < 40 ~ "Polihalina",
      TRUE          ~ "Euhalina"
    ),
    zona_estuarina = case_when(
      Salinity < 15 ~ "Zona Fluvial",
      Salinity < 25 ~ "Zona de Mezcla",
      Salinity < 35 ~ "Zona Marina",
      TRUE          ~ "Zona Hipersalina"
    )
  ) %>%
  mutate(
    salinidad_categoria = factor(salinidad_categoria,
                                 levels  = c("Dulce", "Oligohalina", "Mesohalina",
                                             "Polihalina", "Euhalina"),
                                 ordered = TRUE),
    zona_estuarina = factor(zona_estuarina,
                            levels  = c("Zona Fluvial", "Zona de Mezcla",
                                        "Zona Marina", "Zona Hipersalina"),
                            ordered = TRUE)
  )

# Validar distribución
head(biol_sal) %>%
  dplyr::select(c(1:5, 10:11)) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Tabla de frecuencia, de contingencia o de validación cruzada
tabla_cruce_salinidad <-
  biol_sal %>%
  count(salinidad_categoria, zona_estuarina) %>%
  pivot_wider(names_from  = zona_estuarina,
              values_from = n,
              values_fill = 0)

tabla_cruce_salinidad %>%
  kbl(booktabs = TRUE) %>%
  kable_classic(full_width = FALSE)


cat("\nCaso A finalizado correctamente.\n")
