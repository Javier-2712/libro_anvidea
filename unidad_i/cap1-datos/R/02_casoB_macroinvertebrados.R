# =========================================================
# ANVIDEA - Capítulo 1
# Fundamentos de manipulación de datos
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

library(tidyverse)   # Manipulación y visualización de datos
library(readxl)      # Lectura de archivos Excel
library(janitor)     # Limpieza de nombres de columnas
library(kableExtra)  # Edición de tablas en Quarto
library(viridis)     # Paletas de color perceptualmente uniformes


# ---------------------------------------------------------
# Lectura de bases de datos
# ---------------------------------------------------------

# Cargar datos desde Excel.
inv1 <- read_xlsx(archivo_invert, sheet = "Taxones1")
inv2 <- read_xlsx(archivo_invert, sheet = "Taxones2")
fq   <- read_xlsx(archivo_invert, sheet = hoja_fq)

# Resumen de dimensiones de las bases cargadas
tibble::tibble(
  hoja     = c("Taxones1", "Taxones2", "Fisicoquímica"),
  filas    = c(nrow(inv1), nrow(inv2), nrow(fq)),
  columnas = c(ncol(inv1), ncol(inv2), ncol(fq))
) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 1. Selección y filtrado
# ---------------------------------------------------------

# a.) Selección de columnas

# Seleccionar columnas específicas: `select()` elige las columnas por nombre.
inv1a <-
  inv1 %>%
  select(Sitio, Baetidae, Belidae, Chironomidae)

# Primeras filas del dataframe filtrado para verificar el resultado.
head(inv1a, 4) %>%
  kbl() %>%
  kable_classic(full_width = F)


# b.) Filtrado condicional

# Filtrar filas: `filter()` selecciona filas basándose en una condición.
inv2a <-
  inv2 %>%
  filter(Sitio != "Caracoli")

# Se muestra las primeras filas del dataframe filtrado para verificar.
head(inv2a, 4) %>%
  dplyr::select(1:7) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 2. Creación de nuevas variables
# ---------------------------------------------------------

# Crear una nueva variable `Abundancia`:
inv1 <-
  inv1 %>%
  mutate(Abundancia = rowSums(across(c(-Sitio, -Microh, -Total))))

# Se muestra las primeras filas del dataframe filtrado para verificar el resultado.
head(inv1, 4) %>%
  dplyr::select(c(1:6, 35)) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 3. Resumen estadístico por sitios
# ---------------------------------------------------------

# Agrupar por `Sitio` y calcular la abundancia promedio.
inv1b <-
  inv1 %>%
  group_by(Sitio) %>%
  summarise(Promedios = mean(Total, na.rm = TRUE))

# Tabulación de los resultados
head(inv1b, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 4. Transformación de datos
# ---------------------------------------------------------

# Transformación log(x+1) en columnas numéricas (excepto Sitio)
inv2_log <-
  inv2 %>%
  mutate(across(-Sitio, log1p))

# Validación rápida
head(inv2_log, 4) %>%
  dplyr::select(1:7) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 5. Transposición de datos
# ---------------------------------------------------------

inv2_long <-
  inv2 %>%
  pivot_longer(
    cols      = -Sitio,
    names_to  = "familia",
    values_to = "abundancia"
  )

# Tabulación del resultado
head(inv2_long, 8) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 6. Unión de datos
# ---------------------------------------------------------

# Unir bases de datos: `left_join()` combina `inv2` (datos bióticos) con `fq`
inv2 <- inv2 %>% mutate(Sitio = as.character(Sitio))
fq   <- fq   %>% mutate(Sitio = as.character(Sitio))

inv2_join <-
  inv2 %>%
  left_join(fq, by = "Sitio")

# Impresión de una muestra de las variables unidas
head(inv2_join) %>%
  dplyr::select(c(1:4, 55:57)) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# %>% glimpse()


# ---------------------------------------------------------
# 7. Conversión de variables categóricas
# ---------------------------------------------------------

# Convertir `Sitio` a un factor ordenado
fq <-
  fq %>%
  mutate(
    Sitio = factor(
      Sitio,
      levels  = c("Pozo Azul", "Arimaca", "Caracoli"),
      ordered = TRUE
    )
  )

# Estructura de Sitio como factor
str(fq$Sitio)


# ---------------------------------------------------------
# 8. Abreviar nombres de grupos biológicos
# ---------------------------------------------------------

# Nombres de las columnas taxonómicas (excepto `Sitio`).
nombres <-
  names(inv2)[-1]

# Crear abreviaciones para los nombres de las familias.
abreviaciones <-
  str_replace_all(nombres, "idae", "") %>%
  str_sub(1, 4) %>%
  make.unique()

# Asignar las abreviaciones como nuevos nombres de columna al dataframe `inv2`.
names(inv2)[-1] <-
  abreviaciones

# Se muestra el dataframe para verificar el resultado.
inv2 %>%
  dplyr::select(1:13) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Diccionario de abreviaciones
diccionario_abrev <- tibble::tibble(
  nombre_original = nombres,
  abreviacion     = abreviaciones
)

diccionario_abrev %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 9. Selección de los taxones más abundantes
# ---------------------------------------------------------

inv2_dom5 <-
  inv2_long %>%
  group_by(familia) %>%
  summarise(total = sum(abundancia, na.rm = TRUE)) %>%
  slice_max(order_by = total, n = 5)

# Se muestra el dataframe para verificar el resultado.
inv2_dom5 %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 10. Visualización
# ---------------------------------------------------------

# Figura 5 — Distribución de las familias más abundantes de macroinvertebrados acuáticos.

# Generar un gráfico de barras de la abundancia media por familia.
fig_dom_familias <-
  inv2_long %>%
  group_by(familia) %>%
  summarise(media = mean(abundancia, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(familia, -media), y = media)) +
  geom_col(fill = "#1f78b4") +
  coord_flip() +
  labs(x = "Familias de Macroinvertebrados",
       y = "Promedio de abundancia",
       title = "Familias más abundantes") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid  = element_blank())

print(fig_dom_familias)


# ---------------------------------------------------------
# 11. Categorizar una variable continua
# ---------------------------------------------------------

# Categorizar el nivel de oxígeno disuelto.
fq_cat <-
  fq %>%
  mutate(
    Cat_oxigeno = case_when(
      Oxigeno <  5.2  ~ "Bajo",
      Oxigeno <= 5.5  ~ "Medio",
      TRUE            ~ "Alto"
    ),
    Cat_oxigeno = factor(Cat_oxigeno,
                         levels  = c("Bajo", "Medio", "Alto"),
                         ordered = TRUE)
  )

# Se muestra el dataframe para verificar el resultado.
fq_cat %>%
  dplyr::select(c(1:8, 27)) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Y como resumen de control (frecuencias por categoría):
tabla_oxigeno <-
  fq_cat %>%
  count(Cat_oxigeno)

tabla_oxigeno %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 12. Dominancia y Condición Ambiental
# ---------------------------------------------------------

# Estandarizar Sitio en ambas tablas y unir dominantes con oxígeno
inv_dom_ox <-
  inv2_long %>%
  mutate(Sitio = std_sitio(Sitio)) %>%
  semi_join(inv2_dom5, by = "familia") %>%
  left_join(
    fq_cat %>%
      mutate(Sitio = std_sitio(Sitio)) %>%
      select(Sitio, Cat_oxigeno),
    by = "Sitio"
  )

head(inv_dom_ox, 8) %>%
  kbl(booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura 6 — Respuesta promedio (±EE) de las cinco familias dominantes
# a categorías de oxígeno disuelto.
fig_dom_ox <-
  inv_dom_ox %>%
  group_by(familia, Cat_oxigeno) %>%
  summarise(
    n     = sum(!is.na(abundancia)),
    media = mean(abundancia, na.rm = TRUE),
    ee    = sd(abundancia,   na.rm = TRUE) / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = Cat_oxigeno, y = media, fill = Cat_oxigeno)) +
  geom_col(width = 0.7) +
  geom_errorbar(aes(ymin = pmax(media - ee, 0), ymax = media + ee), width = 0.2) +
  facet_wrap(~ familia, scales = "free_y") +
  scale_y_continuous(trans = "log10") +
  labs(
    x    = "Categoría de oxígeno disuelto",
    y    = expression(log[10]~"(Abundancia promedio + 1)"),
    fill = "Oxígeno"
  ) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_dom_ox)


# ---------------------------------------------------------
# 13. Gradientes Continuos y Comunidad
# ---------------------------------------------------------

# a.) Calcular métricas comunitarias por sitio

# Abundancia total por sitio
ab_total <-
  inv2 %>%
  mutate(Ab_total = rowSums(across(-Sitio))) %>%
  select(Sitio, Ab_total)

# Riqueza simple por sitio
riqueza <-
  inv2 %>%
  mutate(Riqueza = rowSums(across(-Sitio) > 0)) %>%
  select(Sitio, Riqueza)

# Unir métricas con variables ambientales
famil_ambiente <-
  ab_total %>%
  left_join(riqueza, by = "Sitio") %>%
  left_join(fq, by = "Sitio")

head(famil_ambiente, 4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Figura 7 — Abundancia total vs Oxígeno
fig_ab_ox <-
  ggplot(famil_ambiente,
         aes(x = Oxigeno, y = Ab_total)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    x = "Oxígeno disuelto (mg/L)",
    y = "Abundancia total"
  ) +
  theme_bw() +
  theme(panel.grid = element_blank())

print(fig_ab_ox)

# Figura 8 — Riqueza vs Conductividad
fig_riq_cond <- NULL
if ("Conductividad" %in% names(famil_ambiente)) {
  fig_riq_cond <-
    ggplot(famil_ambiente,
           aes(x = Conductividad, y = Riqueza)) +
    geom_point(size = 3) +
    geom_smooth(method = "lm", se = FALSE) +
    labs(
      x = "Conductividad",
      y = "Riqueza de familias"
    ) +
    theme_bw() +
    theme(panel.grid = element_blank())

  print(fig_riq_cond)
}

# Figura 9 — Riqueza vs Ancho de los tramos
fig_riq_ancho <- NULL
if ("Ancho" %in% names(famil_ambiente)) {
  fig_riq_ancho <-
    ggplot(famil_ambiente,
           aes(x = Ancho, y = Riqueza)) +
    geom_point(size = 3) +
    geom_smooth(method = "lm", se = FALSE) +
    labs(
      x = "Ancho del tramo (m)",
      y = "Riqueza de familias"
    ) +
    theme_bw() +
    theme(panel.grid = element_blank())

  print(fig_riq_ancho)
}


cat("\nCaso B finalizado correctamente.\n")
