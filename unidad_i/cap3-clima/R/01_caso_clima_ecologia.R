# =========================================================
# ANVIDEA - Capítulo 3
# Análisis climático y ecológico en ambientes contrastantes
# ---------------------------------------------------------
# Archivo : 01_caso_clima_ecologia.R
# Caso    : Análisis climático y ecológico en ambientes contrastantes
# =========================================================

cat("\n========================================\n")
cat("Caso guiado - Análisis climático y ecológico\n")
cat("========================================\n")

# ---------------------------------------------------------
# Cargar paquetes
# ---------------------------------------------------------

library(tidyverse)   # incluye dplyr, tidyr, ggplot2, stringr, readr, tibble, etc.
library(readxl)      # lectura de Excel
library(kableExtra)  # tablas bonitas en PDF/HTML
library(cowplot)     # composición de figuras (plot_grid, ggdraw)
library(viridis)     # escalas viridis para ggplot (scale_*_viridis_*)
# funciones externas:
# source("bal_hid.R")  — ya cargado desde 00_setup.R


# ---------------------------------------------------------
# Preparación de los datos
# ---------------------------------------------------------

# Cargar la tabla de estaciones derivada de la hoja 'clima'
# (en el libro original se lee desde 'estaciones.xlsx';
#  aquí se construye desde la fuente disponible en el repositorio)
tabla <-
  readxl::read_xlsx(archivo_datos, sheet = "clima") %>%
  dplyr::mutate(altura = as.numeric(altura)) %>%
  dplyr::group_by(Estación) %>%
  dplyr::summarise(
    altura     = dplyr::first(altura),
    Temp_media = mean(Temp, na.rm = TRUE),
    PP_anual   = sum(pp,   na.rm = TRUE),
    .groups = "drop"
  )

tabla %>%
  dplyr::select(1:4) %>%
  kbl(booktabs = TRUE, digits = 2, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# Guardar como tabla_estaciones para compatibilidad con 03_guardar
tabla_estaciones <- tabla


# ---------------------------------------------------------
# 1. Visualización temporal
# ---------------------------------------------------------


# 1.1 Patrón temporal de temperatura
# ----------------------------------------

# Importar datos
serie_temp <- read_excel(archivo_datos, sheet = "serie_temp")

# Pasar a formato largo (tidy)
serie_temp_long <-
  serie_temp %>%
  pivot_longer(
    cols      = -c(Estación, Meses),
    names_to  = "Año",
    values_to = "Temperatura"
  ) %>%
  filter(!is.na(Temperatura)) %>%
  filter(Año != "Promedio") %>%
  mutate(Año = as.numeric(Año))

# Figura 3.1 — Variación mensual de la temperatura promedio
# Las líneas grises representan años individuales y la línea negra
# el promedio multianual.
fig_temp_mensual <-
  ggplot(serie_temp_long, aes(x = Meses, y = Temperatura,
                              group = Año, color = Año)) +
  geom_line(alpha = 0.25, linewidth = 0.6) +
  stat_summary(fun = mean, geom = "line", color = "black",
               linewidth = 1.2, aes(group = 1)) +
  facet_wrap(~Estación, ncol = 1) +
  scale_color_viridis_c(option = "plasma", guide = "none") +
  labs(
    title    = "Variación mensual de la temperatura en Santa Marta",
    subtitle = "Comparación entre estaciones: APTO, PNNT y San Lorenzo",
    x = "Mes",
    y = "Temperatura (°C)"
  ) +
  theme_bw(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(size = 12, color = "gray30"),
    axis.text.x   = element_text(angle = 45, hjust = 1),
    strip.background = element_rect(fill = "gray90", color = NA),
    strip.text    = element_text(face = "bold")
  )

print(fig_temp_mensual)

# Figura 3.2 — Patrón anual de temperatura promedio
# La línea negra representa el promedio general y las líneas de
# colores muestran los promedios de cada mes.

# Formato largo (años desde las columnas)
serie_temp_long <-
  serie_temp %>%
  pivot_longer(
    cols      = -c(Estación, Meses),
    names_to  = "Año",
    values_to = "Temperatura"
  ) %>%
  filter(!is.na(Temperatura), Año != "Promedio") %>%
  mutate(
    Año   = as.numeric(Año),
    Meses = factor(Meses,
                   levels  = c("ene","feb","mar","abr","may","jun",
                               "jul","ago","sep","oct","nov","dic"),
                   ordered = TRUE)
  )

# Media anual (línea negra)
media_anual <-
  serie_temp_long %>%
  group_by(Estación, Año) %>%
  summarise(Temp_media = mean(Temperatura, na.rm = TRUE), .groups = "drop")

# Guardar el resumen interanual para uso posterior
serie_temp_interanual <- media_anual

# Determinar año mínimo observado (para el límite inferior)
xmin <- min(serie_temp_long$Año, na.rm = TRUE)

# Gráfico: eje x fijado a [xmin, 2020] en todos los paneles
fig_temp_anual <-
  ggplot(serie_temp_long, aes(x = Año, y = Temperatura,
                              color = Meses, group = Meses)) +
  geom_line(alpha = 0.55, linewidth = 0.7) +
  geom_point(alpha = 0.4, size = 0.8, stroke = 0) +
  geom_line(data = media_anual, aes(x = Año, y = Temp_media, group = 1),
            inherit.aes = FALSE, color = "black", linewidth = 1.2) +
  facet_wrap(~ Estación, ncol = 1, scales = "free_y") +
  scale_x_continuous(
    limits = c(xmin, 2020),
    breaks = scales::pretty_breaks(n = 8)
  ) +
  scale_color_viridis_d(option = "plasma", end = 0.95, name = "Mes") +
  labs(
    title    = "Variación interanual de la temperatura",
    subtitle = "Líneas por mes; línea negra = promedio anual (eje X termina en 2020)",
    x = "Año",
    y = "Temperatura (°C)"
  ) +
  theme_bw(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 15),
    plot.subtitle    = element_text(size = 12, color = "gray30"),
    strip.background = element_rect(fill = "gray90", color = NA),
    strip.text       = element_text(face = "bold"),
    legend.position  = "right"
  )

print(fig_temp_anual)


# 1.2 Patrón temporal de precipitación
# ----------------------------------------

# Importar y poner en formato largo
precip <- read_excel(archivo_datos, sheet = "serie_precipit")

# Base de datos en formato largo
precip_long <-
  precip %>%
  pivot_longer(
    cols      = -c(Estación, Meses),
    names_to  = "Año",
    values_to = "Precip_mm"
  ) %>%
  filter(!is.na(Precip_mm)) %>%
  filter(Año != "Promedio") %>%
  mutate(
    Año   = suppressWarnings(as.numeric(Año)),
    Meses = factor(
      Meses,
      levels  = c("ene","feb","mar","abr","may","jun",
                  "jul","ago","sep","oct","nov","dic"),
      ordered = TRUE
    )
  )

# Figura 3.3 — Patrón mensual de precipitación
# La línea negra representa el promedio general y las líneas de
# colores muestran los promedios del total de precipitación de cada mes.
fig_pp_mensual <-
  ggplot(precip_long, aes(x = Meses, y = Precip_mm,
                          group = Año, color = Año)) +
  geom_line(alpha = 0.25, linewidth = 0.6) +
  # Promedio mensual (línea negra) por faceta
  stat_summary(fun = mean, geom = "line", color = "black",
               linewidth = 1.2, aes(group = 1)) +
  facet_wrap(~ Estación, ncol = 1, scales = "free_y") +
  scale_color_viridis_c(option = "plasma", guide = "none") +
  labs(
    title    = "Variación mensual de la precipitación en Santa Marta",
    subtitle = "Comparación entre estaciones (líneas claras = años individuales; negro = promedio mensual)",
    x = "Mes",
    y = "Precipitación (mm)"
  ) +
  theme_bw(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(size = 12, colour = "gray30"),
    axis.text.x   = element_text(angle = 45, hjust = 1),
    strip.background = element_rect(fill = "gray90", colour = NA),
    strip.text    = element_text(face = "bold")
  )

print(fig_pp_mensual)

# Figura 3.5 — Patrón anual de precipitación total mensual
# La línea negra representa el promedio general y las líneas de
# colores muestran los promedios de cada mes.

# Totales anuales (línea negra)
precip_anual <-
  precip_long %>%
  group_by(Estación, Año) %>%
  summarise(Precip_media_anual = mean(Precip_mm, na.rm = TRUE), .groups = "drop")

# Guardar el resumen interanual para uso posterior
serie_pp_interanual <- precip_anual

# Límite inferior común del eje X (año mínimo observado)
xmin_pp <- min(precip_long$Año, na.rm = TRUE)

# Figura: eje x = Años; líneas por Mes; línea negra = total anual
fig_pp_anual <-
  ggplot(precip_long, aes(x = Año, y = Precip_mm,
                          color = Meses, group = Meses)) +
  geom_line(alpha = 0.55, linewidth = 0.7) +
  geom_point(alpha = 0.4, size = 0.8, stroke = 0) +
  geom_line(data = precip_anual,
            aes(x = Año, y = Precip_media_anual, group = 1),
            inherit.aes = FALSE, color = "black", linewidth = 1.2) +
  facet_wrap(~ Estación, ncol = 1, scales = "free_y") +
  scale_x_continuous(
    limits = c(xmin_pp, 2020),
    breaks = scales::pretty_breaks(n = 8)
  ) +
  scale_color_viridis_d(option = "plasma", end = 0.95, name = "Mes") +
  labs(
    title    = "Variación interanual de la precipitación",
    subtitle = "Líneas por mes; línea negra = promedio mensual anual",
    x = "Año",
    y = "Precipitación (mm)"
  ) +
  theme_bw(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(size = 12, color = "gray30"),
    strip.background = element_rect(fill = "gray90", color = NA),
    strip.text    = element_text(face = "bold"),
    legend.position = "right"
  )

print(fig_pp_anual)


# ---------------------------------------------------------
# 2. Climatograma
# ---------------------------------------------------------

# Definir el orden cronológico de los meses
meses_orden <- c("ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC")

# Cargar y organizar la tabla climática base
climatog <-
  read_excel(archivo_datos, sheet = "clima") %>%
  dplyr::rename(estación = `Estación`,
                mes = Mes, temp = Temp, pp = pp) %>%
  filter(!is.na(mes), mes != "", mes %in% meses_orden) %>%
  mutate(
    mes = factor(mes, levels = meses_orden, ordered = TRUE)
  )

# Definir el máximo de precipitación esperado por estación
mm_max_por_est <- c("APTO" = 140, "PNNT" = 300, "SL" = 500)

# Función base para PNNT y SL (sin rótulos de ejes; sec.axis sin nombre)
p_clima <- function(df_est, mm_max, titulo = NULL) {
  lim_temp <- max(
    mm_max / 2,
    max(df_est$pp,   na.rm = TRUE) / 2,
    max(df_est$temp, na.rm = TRUE)
  )
  ggplot(df_est, aes(x = mes)) +
    geom_col(aes(y = pp / 2), fill = "skyblue", alpha = .85, width = .8) +
    geom_line(aes(y = temp, group = 1), color = "firebrick", linewidth = 1) +
    geom_point(aes(y = temp), color = "firebrick", size = 2) +
    scale_y_continuous(
      limits   = c(0, lim_temp),
      sec.axis = sec_axis(~ . * 2, name = NULL),
      expand   = expansion(mult = c(0, .03))
    ) +
    labs(title = ifelse(is.null(titulo), unique(df_est$estación), titulo),
         x = "Mes", y = NULL) +
    theme_bw(base_size = 13) +
    theme(
      plot.title          = element_text(face = "bold", size = 14),
      axis.text.x         = element_text(angle = 45, hjust = 1),
      axis.title.y        = element_blank(),
      axis.title.y.right  = element_blank(),
      panel.grid.minor    = element_blank(),
      plot.margin         = margin(6, 12, 6, 8)
    )
}

# APTO con escala fija solicitada
p1 <-
  ggplot(filter(climatog, estación == "APTO"), aes(x = mes)) +
  geom_col(aes(y = pp / 2), fill = "skyblue", alpha = 0.85, width = 0.8) +
  geom_line(aes(y = temp, group = 1), color = "firebrick", linewidth = 1) +
  geom_point(aes(y = temp), color = "firebrick", size = 2) +
  scale_y_continuous(
    limits   = c(0, 80),
    breaks   = seq(0, 80, by = 20),
    sec.axis = sec_axis(~ . * 2,
                        breaks = seq(0, 160, by = 40),
                        name   = NULL),
    expand   = expansion(mult = c(0, .03))
  ) +
  labs(title = "APTO – Aeropuerto Simón Bolívar", x = "Mes", y = NULL) +
  theme_bw(base_size = 13) +
  theme(
    plot.title         = element_text(face = "bold", size = 14),
    axis.text.x        = element_text(angle = 45, hjust = 1),
    axis.title.y       = element_blank(),
    axis.title.y.right = element_blank(),
    panel.grid.minor   = element_blank(),
    plot.margin        = margin(6, 12, 6, 8)
  )

# PNNT y SL con función base (límites personalizados automáticos)
p2 <- p_clima(filter(climatog, estación == "PNNT"),
              mm_max_por_est["PNNT"], "PNNT – Parque Tayrona")
p3 <- p_clima(filter(climatog, estación == "SL"),
              mm_max_por_est["SL"],   "SL – San Lorenzo")

# Componer verticalmente
combo <- plot_grid(p1, p2, p3, ncol = 1,
                   rel_heights = c(1, 1, 1),
                   align = "v")

# Reservar márgenes laterales y añadir rótulos globales centrados
left_gutter  <- 0.08
right_gutter <- 0.08

# Figura 3.6 — Climatograma de las localidades evaluadas
fig_climatograma <-
  ggdraw() +
  draw_plot(combo, x = left_gutter, y = 0,
            width = 1 - left_gutter - right_gutter, height = 1) +
  draw_label("Temperatura (°C)",
             x = left_gutter / 2, y = 0.5, angle = 90,
             vjust = 0.5, fontface = "bold", size = 14) +
  draw_label("Precipitación (mm)",
             x = 1 - right_gutter / 2, y = 0.5, angle = -90,
             vjust = 0.5, fontface = "bold", size = 14)

print(fig_climatograma)


# ---------------------------------------------------------
# 3. Índice pluviométrico de Lang
# ---------------------------------------------------------

# Cargar la base de datos
clima_lang <-
  read_xlsx(archivo_datos, sheet = "clima") %>%
  dplyr::rename(Estación = `Estación`, Temp = Temp, pp = pp)

# Ponderaciones del índice de Lang (tabla reproducible)
ponderaciones <-
  tibble::tribble(
    ~Rango_mm_por_oC, ~Clase,
    "<20",     "Muy árido",
    "20–40",   "Árido",
    "40–60",   "Semiárido",
    "60–100",  "Subhúmedo seco",
    "100–160", "Húmedo",
    ">160",    "Hiperhúmedo"
  )

# Imprimir ponderaciones
ponderaciones %>%
  kbl(booktabs = TRUE, longtable = TRUE,
      align = c("c", "l")) %>%
  kable_classic(full_width = FALSE, html_font = "Cambria")

# Vector de cortes y etiquetas para clasificar y graficar
breaks_lang  <- c(0, 20, 40, 60, 100, 160, Inf)
labels_lang  <- c("Muy árido","Árido","Semiárido","Subhúmedo seco","Húmedo","Hiperhúmedo")
cortes_plot  <- breaks_lang[2:(length(breaks_lang) - 1)]  # 20, 40, 60, 100, 160

# Cálculo del índice de Lang por estación desde 'clima'
lang_tabla <-
  clima_lang %>%
  group_by(Estación) %>%
  summarise(
    PP_anual_mm = sum(pp,   na.rm = TRUE),
    T_media_C   = mean(Temp, na.rm = TRUE),
    Lang        = PP_anual_mm / T_media_C,
    .groups = "drop"
  ) %>%
  mutate(
    Clase = cut(Lang, breaks = breaks_lang,
                labels = labels_lang, right = TRUE)
  ) %>%
  arrange(desc(Lang))

# Imprimir tabla de resultados
lang_tabla %>%
  mutate(
    PP_anual_mm = round(PP_anual_mm, 1),
    T_media_C   = round(T_media_C,  2),
    Lang        = round(Lang,        1)
  ) %>%
  kbl(booktabs = TRUE, longtable = TRUE,
      align = c("l","r","r","r","l")) %>%
  kable_classic(full_width = FALSE, html_font = "Cambria")

# Figura 3.7 — Índice de Lang por estación
# Colores (se mostrarán solo los presentes en los datos)
pal <- c(
  "Muy árido"      = "grey30",
  "Árido"          = "grey50",
  "Semiárido"      = "#9FD0F1",
  "Subhúmedo seco" = "#6BAED6",
  "Húmedo"         = "#4A79C5",
  "Hiperhúmedo"    = "#D33F3F"
)
niveles_presentes <- levels(droplevels(lang_tabla$Clase))

fig_lang <-
  ggplot(lang_tabla, aes(x = reorder(Estación, Lang),
                         y = Lang, fill = Clase)) +
  geom_col(width = 0.75, alpha = 0.9) +
  geom_text(aes(label = sprintf("%.1f", Lang)),
            hjust = -0.15, size = 3.7) +
  geom_hline(yintercept = cortes_plot,
             linetype = "dashed", linewidth = 0.4, color = "grey40") +
  coord_flip(ylim = c(0, max(lang_tabla$Lang, na.rm = TRUE) * 1.10)) +
  scale_fill_manual(values = pal[niveles_presentes],
                    breaks = niveles_presentes, name = "Clase") +
  labs(
    title    = "Índice de Lang por estación",
    subtitle = "Lang = P anual (mm) / T media anual (°C)",
    x = "Estación", y = "Índice de Lang (mm/°C)",
    caption  = paste(
      "Cortes (mm/°C): <20 Muy árido · 20–40 Árido · 40–60 Semiárido ·",
      "\n60–100 Subhúmedo seco · 100–160 Húmedo · >160 Hiperhúmedo"
    )
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold"),
    legend.position = "right",
    plot.caption  = element_text(size = 9, colour = "grey30"),
    panel.grid    = element_blank()
  )

print(fig_lang)


# ---------------------------------------------------------
# 4. Balance Hídrico
# ---------------------------------------------------------

# Función de Balance hídrico mensual de Thornthwaite–Mather
# source("bal_hid.R")  — ya cargado desde 00_setup.R

clima <-
  read_excel(archivo_datos, sheet = "clima") %>%
  dplyr::rename(
    estacion  = `Estación`,
    mes       = Mes,
    temp      = Temp,
    pp        = pp,
    horas_luz = horas_luz,
    dias_mes  = `días_mes`
  )

# 1) Ejecutar el balance (S_max editable)
S_max   <- 100
balance <- bal_hid(clima, S_max = S_max, corr_horas_dias = TRUE)

# Figura 3.8 — Balance hídrico calculado para las tres estaciones de estudio
fig_balance <-
  ggplot(balance, aes(x = mes)) +
  geom_col(aes(y = pp), fill = "skyblue", alpha = 0.6, width = 0.8) +
  geom_line(aes(y = etp_cor, group = 1, linetype = "ETP corregida"),
            color = "#e41a1c", linewidth = 1) +
  geom_point(aes(y = etp_cor), color = "#e41a1c", size = 1.8) +
  geom_line(aes(y = ETR, group = 1, linetype = "ETR"),
            color = "#377eb8", linewidth = 1) +
  geom_point(aes(y = ETR), color = "#377eb8", size = 1.8) +
  facet_wrap(~ estacion, ncol = 1, scales = "free_y") +
  scale_linetype_manual(
    values = c("ETP corregida" = "solid", "ETR" = "dashed"),
    name   = NULL
  ) +
  labs(
    title    = "Balance hídrico mensual por estación",
    subtitle = paste0("S_max = ", S_max, " mm\n",
                      "Barras: pp (mm) · Líneas: ETP_cor (rojo) y ETR (azul)"),
    x = "Mes", y = "mm"
  ) +
  theme_bw(base_size = 15) +
  theme(
    plot.title    = element_text(face = "bold"),
    axis.text.x   = element_text(angle = 45, hjust = 1, size = 15),
    axis.text.y   = element_text(size = 15),
    legend.position = "top",
    strip.background = element_rect(fill = "grey90", colour = NA)
  )

print(fig_balance)


# ---------------------------------------------------------
# 5. Biomas, zonas de vida o formaciones vegetales
# ---------------------------------------------------------

# Paso 1: Se calcula la ETP_corr mensual con la fórmula de
# Thornthwaite (corrigiendo por días del mes y horas de luz).

# Leer datos y preparar
clima_biomas <-
  read_xlsx(archivo_datos, sheet = "clima") %>%
  dplyr::rename(
    Estación  = `Estación`,
    Mes       = Mes,
    Temp      = Temp,       # °C
    pp        = pp,         # mm
    horas_luz = horas_luz,  # h/día
    dias_mes  = `días_mes`,
    altura    = `altura`
  ) %>%
  mutate(Temp_pos = pmax(Temp, 0))  # Thornthwaite usa 0 si T<0

# Índice de calor y ETP Thornthwaite corregida
thornthwaite_a <- function(I) 6.75e-7 * I^3 - 7.71e-5 * I^2 +
  1.792e-2 * I + 0.49239

# Índice de calor (I)
I_tab <-
  clima_biomas %>%
  group_by(Estación) %>%
  summarise(I = sum((Temp_pos / 5)^1.514, na.rm = TRUE),
            .groups = "drop")

# Datos climáticos, más ETP_cor
clima_biomas <-
  clima_biomas %>%
  left_join(I_tab, by = "Estación") %>%
  mutate(
    a_tw     = thornthwaite_a(I),
    etp_base = if_else(I > 0, 16 * ((10 * Temp_pos / I)^a_tw), 0),  # base 30 días, 12 h
    ETP_corr = etp_base * (dias_mes / 30) * (horas_luz / 12)         # corrección mensual
  )

# Mostrar tabla (Tabla 3.4)
head(clima_biomas) %>%
  dplyr::select(c(1:8, 11)) %>%
  kbl(booktabs = TRUE, digits = 1, longtable = TRUE,
      align = "lrrrllll") %>%
  kable_classic(full_width = FALSE)


# Paso 2: Se construye la tabla resumen (Tabla 3.5)

resumen <-
  clima_biomas %>%
  group_by(Estación) %>%
  summarise(
    `Precipit. (mm)` = sum(pp,       na.rm = TRUE),
    `Temp. (°C)`     = mean(Temp,    na.rm = TRUE),
    `ETP_corr (mm)`  = sum(ETP_corr, na.rm = TRUE),
    Lang             = `Precipit. (mm)` / `Temp. (°C)`,
    .groups          = "drop"
  ) %>%
  mutate(
    Aridez = cut(
      Lang,
      breaks = c(0, 20, 40, 60, 100, 160, Inf),
      labels = c("Muy árido","Árido","Semiárido",
                 "Subhúmedo seco","Húmedo","Hiperhúmedo"),
      right  = TRUE
    ),
    # Columnas que el estudiante completa manualmente usando la hoja 'biomas'
    `Holdridge (1967)`   = NA_character_,
    `Espinal_Montenegro` = NA_character_,
    `Hernández_Camacho`  = NA_character_
  ) %>%
  select(
    Estación,
    `Precipit. (mm)`,
    `Temp. (°C)`,
    Lang, Aridez,
    `ETP_corr (mm)`,
    `Holdridge (1967)`,
    `Espinal_Montenegro`,
    `Hernández_Camacho`
  )

resumen %>%
  dplyr::select(c(1:8)) %>%
  kbl(booktabs = TRUE, digits = 1, align = "lrrrllll") %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(full_width = FALSE, font_size = 8)


# Paso 3: Se completa la tabla resumen diligenciando de forma
# manual las tres últimas columnas (Tabla 3.6).

# Plantilla con los datos faltantes (clasif_manual):
clasif_manual <-
  tibble::tribble(
    ~Estación, ~`Holdridge (1967)`,        ~`Espinal_Montenegro`,         ~`Hernández_Camacho`,
    "APTO",    "Bosque muy seco tropical (bms-T)", "Bosque muy seco tropical (bms-T)", "Zonobioma Subxerofítico Tropical",
    "PNNT",    "Bosque seco tropical (bs-T)",      "Bosque seco tropical (bs-T)",      "Zonobioma tropical alternohígrico",
    "SL",      "Bosque muy húmedo montano (bmh-M)","Bosque muy húmedo montano (bmh-M)","Orobiomas de Selva Andina"
  )

# Tabla completa
resumen_final <-
  resumen %>%
  select(-`Holdridge (1967)`, -`Espinal_Montenegro`, -`Hernández_Camacho`) %>%
  left_join(clasif_manual, by = "Estación")

# Tabla en kbl
resumen_final %>%
  kbl(booktabs = TRUE, digits = 1) %>%
  kable_classic(full_width = FALSE) %>%
  kable_styling(full_width = FALSE, font_size = 8)


cat("\nCaso guiado finalizado correctamente.\n")
