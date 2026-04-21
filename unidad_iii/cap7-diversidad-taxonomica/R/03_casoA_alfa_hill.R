# =========================================================
# ANVIDEA - Capítulo 7
# Diversidad taxonómica (TD)
# ---------------------------------------------------------
# Archivo : 03_casoA_alfa_hill.R
# Caso    : A.3 Diversidad alfa con números efectivos de Hill
# =========================================================

cat("\n========================================\n")
cat("Caso A.3 - Diversidad alfa (n\u00fameros de Hill)\n")
cat("========================================\n")

# ---------------------------------------------------------
# Paso 4) Diversidad alfa con números efectivos de Hill
# ---------------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(tibble)
library(kableExtra)
library(iNEXT)
library(iNEXT.4steps)
library(iNEXT.3D)

# Estructura mínima de los datos (abundancia)
biol <- read_xlsx(archivo_datos, sheet = "tax")

biol_sit <-
  biol %>%
  dplyr::select(-tidyselect::any_of("Sites")) %>%
  dplyr::group_by(Sites1) %>%
  dplyr::summarise(dplyr::across(where(is.numeric),
                                 ~ sum(.x, na.rm = TRUE)),
                   .groups = "drop") %>%
  tidyr::pivot_longer(
    cols      = -Sites1,
    names_to  = "Especies",
    values_to = "Abundancia"
  ) %>%
  tidyr::pivot_wider(
    names_from  = Sites1,
    values_from = Abundancia,
    values_fill = 0
  ) %>%
  tibble::column_to_rownames("Especies") %>%
  as.data.frame()

biol_sit %>%
  head(8) %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 4.2 iNEXT (2016): rarefacción/extrapolación como base comparativa
# ---------------------------------------------------------

# iNEXT por estaciones
result <- iNEXT(biol_sit, q = 0, datatype = "abundance")

# Insumos de iNEXT para tabular
result <- result$DataInfo[, c(1:3, 5, 6)]

# Edición de nombres de columnas
colnames(result) <- c("zona", "N", "Riqueza", "f1", "f2")

result %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 4.3 iNEXT.4steps (2020): diversidad alfa en cuatro pasos
# ---------------------------------------------------------

chao.sit <-
  biol_sit %>%
  as.data.frame() %>%
  mutate(across(everything(), as.numeric))

# Resultados de la prueba de diversidad alfa en 4 pasos
result1 <- iNEXT4steps(data = chao.sit, datatype = "abundance")

# a. Paso 1: perfil de completitud
result1$summary$"STEP 1. Sample completeness profiles" %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)

# b. Paso 2: perfil asintótico (observada vs estimada)
asinto <- result1$summary$"STEP 2b. Observed diversity values and asymptotic estimates"

asinto <- asinto %>%
  mutate(sin.det = round(TD_asy - TD_obs))

asinto_tab <- data.frame(
  Ensamblaje  = asinto$Assemblage,
  Estimador   = asinto$qTD,
  D.Observada = asinto$TD_obs,
  D.Estimada  = asinto$TD_asy,
  Sin.Det     = asinto$sin.det
) %>%
  mutate(
    Estimador = dplyr::recode(as.character(Estimador),
      "Species richness"  = "q=0, Riqueza",
      "Shannon diversity" = "q=1, Shannon",
      "Simpson diversity" = "q=2, Simpson"
    )
  )

asinto_tab %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)

# c. Paso 3: perfil no asintótico (rarefacción/extrapolación por cobertura)
result1$summary$"STEP 3. Non-asymptotic coverage-based rarefaction and extrapolation analysis" %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)

# d. Paso 4: uniformidad
result1$summary$"STEP 4. Evenness among species abundances of orders q = 1 and 2 at Cmax based on the normalized slope of a diversity profile" %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 4.5-4.6 Figuras desde iNEXT.4steps
# ---------------------------------------------------------

# a. Figura del paso 1. Completitud de las muestras
result1$figure[[1]] +
  scale_x_continuous(limits = c(0, 2), breaks = seq(0, 2, by = 1)) +
  labs(x        = "Orden q",
       y        = "Completitud de la muestra",
       title    = "Paso 1. Perfil de Completitud",
       subtitle = "Comparaci\u00f3n de las zonas por \u00f3rdenes de diversidad (q)") +
  theme(panel.grid    = element_blank(),
        plot.title    = element_text(size = 13, face = "bold", colour = "blue4"),
        plot.subtitle = element_text(size = 11, colour = "gray30"),
        axis.title    = element_text(size = 11, face = "bold"),
        axis.text     = element_text(size = 10),
        legend.position = "bottom",
        legend.title    = element_blank(),
        legend.text     = element_text(size = 10))

# b. Figura del paso 2. Rarefacción/extrapolación por tamaño
result1$figure[[2]] +
  labs(x        = "Abundancia",
       y        = "Diversidad (n\u00famero efectivo de especies)",
       title    = "Paso 2.1. Tama\u00f1o basado en rarefacci\u00f3n/extrapolaci\u00f3n",
       subtitle = "Curvas por zonas para q = 0 (riqueza), q = 1 (Shannon) y q = 2 (Simpson)") +
  scale_linetype_manual(values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() +
  theme(plot.title      = element_text(size = 13, face = "bold", colour = "blue4"),
        panel.grid      = element_blank(),
        legend.position = "bottom")

# c. Figura del paso 3. Perfil no asintótico por cobertura
result1$figure[[4]] +
  labs(x        = "Cobertura de las estaciones",
       y        = "Diversidad (n\u00famero efectivo de especies)",
       title    = "Paso 3. Perfil no asint\u00f3tico por cobertura",
       subtitle = "Comparaci\u00f3n de M, P y RM a Cmax \u2248 1") +
  geom_vline(xintercept = 1, linetype = 3, linewidth = 0.5, color = "grey50") +
  annotate("text", x = 1, y = Inf, label = "Cmax = 1",
           vjust = 1.3, hjust = 1.05, size = 3, color = "grey35") +
  scale_linetype_manual("", values = c(1, 2),
                        labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw(base_size = 14) +
  theme(panel.grid      = element_blank(),
        axis.title      = element_text(size = 11, face = "bold"),
        axis.text       = element_text(size = 10),
        plot.title      = element_text(size = 13, face = "bold", colour = "blue4"),
        plot.subtitle   = element_text(size = 11, colour = "gray30"),
        strip.text      = element_text(face = "bold"),
        legend.position = "bottom",
        legend.title    = element_blank(),
        legend.text     = element_text(size = 10),
        plot.margin     = margin(8, 10, 8, 8)) +
  scale_x_continuous(limits = c(0, 1),
                     breaks = seq(0, 1, by = 0.25),
                     expand = expansion(add = 0.02))

# d. Figura del paso 4. Perfil de uniformidad
result1$figure[[5]] +
  scale_x_continuous(limits = c(0, 2), breaks = seq(0, 2, by = 1)) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.25),
                     expand = expansion(add = 0.01)) +
  labs(x        = "Orden q",
       y        = "Uniformidad",
       title    = "Paso 4. Perfil de Uniformidad",
       subtitle = "Comparaci\u00f3n de M, P y RM a Cmax \u2248 1") +
  geom_vline(xintercept = 1, linetype = 3, linewidth = 0.5, color = "grey55") +
  annotate("text", x = 1, y = 1, label = "q = 1",
           vjust = -0.6, size = 3.1, color = "grey40") +
  theme_bw(base_size = 14) +
  theme(panel.grid      = element_blank(),
        axis.title      = element_text(size = 11, face = "bold"),
        axis.text       = element_text(size = 10),
        plot.title      = element_text(size = 13, face = "bold", colour = "blue4"),
        plot.subtitle   = element_text(size = 10, colour = "gray30"),
        legend.position = "bottom",
        legend.title    = element_blank(),
        legend.text     = element_text(size = 10),
        plot.margin     = margin(8, 10, 8, 8))


# ---------------------------------------------------------
# 4.4 iNEXT.3D (2021): salidas más ricas y perfiles-q
# ---------------------------------------------------------

# a. Información base del ensamblaje (TDInfo)
result2 <- iNEXT3D(biol_sit,
                   diversity = "TD",
                   q         = c(0, 1, 2),
                   datatype  = "abundance")

result2a <- result2$TDInfo[, c(1:3, 6, 7)]
colnames(result2a) <- c("zona", "N", "Riqueza", "f1", "f2")

result2a %>%
  kbl(booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)

# b. Estimadores estandarizados por tamaño de muestra (TDiNextEst)
result2b <- result2$TDiNextEst$size_based[, 1:8]
colnames(result2b) <- c("Zona", "Orden.q", "m", "M\u00e9todo",
                        "qTD", "qTD.LI", "qTD.LS", "CM")

result2b %>%
  head() %>%
  kbl(digits = 2, booktabs = TRUE, longtable = TRUE) %>%
  kable_classic(full_width = FALSE)

# c. Estimaciones observadas y asintóticas (TDAsyEst)
result2c <- result2$TDAsyEst
colnames(result2c) <- c("Zona", "qTD", "TD_obs", "TD_asy",
                        "e.e.", "qTD.LI", "qTD.LS")

result2c %>%
  head() %>%
  kbl(digits = 2, booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)


# ---------------------------------------------------------
# 4.7 Figuras desde iNEXT.3D
# ---------------------------------------------------------

# a. Curvas size-based de TD por ensamblaje
ggiNEXT3D(result2, type = 1, facet.var = "Assemblage") +
  labs(x        = "N\u00famero de individuos",
       y        = "Diversidad taxon\u00f3mica",
       title    = "Tama\u00f1o basado en rarefacci\u00f3n/extrapolaci\u00f3n",
       subtitle = "Curvas por zonas para 0 (riqueza), 1 (Shannon) y 2 (Simpson)") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() +
  theme(plot.title      = element_text(size = 14, face = "bold", colour = "blue4"),
        plot.subtitle   = element_text(size = 11, colour = "gray30"),
        panel.grid      = element_blank(),
        axis.text       = element_text(size = 11),
        axis.title      = element_text(size = 12, face = "bold"),
        legend.position = "bottom",
        legend.title    = element_blank())

# b. Curvas de completitud de las muestras
ggiNEXT3D(result2, type = 2, color.var = "Assemblage") +
  labs(title    = "Curvas de completitud de las zonas",
       subtitle = "Curvas por zonas para riqueza de especies",
       x        = "N\u00famero de individuos",
       y        = "Cobertura de la muestra",
       color    = "Ensamblaje",
       shape    = "Ensamblaje",
       linetype = "Tipo de curva") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme_bw() +
  theme(plot.title      = element_text(size = 14, face = "bold", colour = "blue4"),
        plot.subtitle   = element_text(size = 11, colour = "gray30"),
        panel.grid      = element_blank(),
        axis.text       = element_text(size = 11),
        axis.title      = element_text(size = 12, face = "bold"),
        legend.position = "bottom",
        legend.title    = element_blank())

# c. Curvas R/E basadas en cobertura
ggiNEXT3D(result2, type = 3, facet.var = "Assemblage") +
  labs(title    = "Curvas R/E basadas en cobertura de las muestras",
       subtitle = "Curvas asint\u00f3ticas",
       x        = "Cobertura de la muestra",
       y        = "Diversidad taxon\u00f3mica") +
  scale_linetype_discrete(labels = c("Rarefacci\u00f3n", "Extrapolaci\u00f3n")) +
  theme(plot.title      = element_text(size = 14, face = "bold", colour = "blue4"),
        plot.subtitle   = element_text(size = 12, colour = "gray30"),
        panel.grid      = element_blank(),
        axis.text       = element_text(size = 11),
        axis.title      = element_text(size = 12, face = "bold"),
        legend.position = "bottom",
        legend.title    = element_blank())

# d. Perfiles de orden q (observado vs asintótico)
result2d <- ObsAsy3D(biol_sit,
                     diversity = "TD",
                     datatype  = "abundance",
                     q         = c(0, 1, 2))

result2d. <- result2d
colnames(result2d.) <- c("Zona", "Orden.q", "qTD", "ee",
                         "qTD.LI", "qTD.LS", "M\u00e9todo")

result2d. %>%
  head() %>%
  kbl(digits = 2, booktabs = TRUE, longtable = FALSE) %>%
  kable_classic(full_width = FALSE)

ggObsAsy3D(result2d) +
  labs(title    = "Perfiles de orden q",
       subtitle = "especies comunes y/o raras (q\u22480) hacia dominantes (q\u22482)",
       x        = "Orden q",
       y        = "Diversidad taxon\u00f3mica",
       linetype = "Tipo de estimaci\u00f3n") +
  scale_linetype_discrete(labels = c("Asint\u00f3tica", "Observada")) +
  theme(plot.title      = element_text(size = 14, face = "bold", colour = "blue4"),
        plot.subtitle   = element_text(size = 12, colour = "gray30"),
        panel.grid      = element_blank(),
        axis.text       = element_text(size = 12),
        axis.title      = element_text(size = 13, face = "bold"),
        legend.position = "bottom",
        legend.title    = element_blank())


# ---------------------------------------------------------
# Tabla comparativa de los tres paquetes iNEXT
# ---------------------------------------------------------

comp <- tibble::tibble(
  Paquete  = c("iNEXT (2016)", "iNEXT.4steps (2020)", "iNEXT.3D (2021)"),
  Contexto = c(
    "Marco base de rarefacci\u00f3n/extrapolaci\u00f3n y estandarizaci\u00f3n para diversidad de Hill.",
    "Flujo did\u00e1ctico en 4 pasos: completitud \u2192 asint\u00f3tico \u2192 R/E por cobertura \u2192 uniformidad.",
    "Extensi\u00f3n para comparar dimensiones (TD, FD y PD) con perfiles-q y salidas gr\u00e1ficas."
  ),
  Entradas = c(
    "Matriz de abundancia o incidencia por ensamblaje.",
    "Matriz de abundancia o incidencia (con \u00e9nfasis en 'summary' por pasos y figuras integradas).",
    "Matriz de abundancia o incidencia; para FD/PD se suma matriz de distancias/\u00e1rbol."
  ),
  Salidas  = c(
    "Curvas R/E, estimaciones estandarizadas, cobertura; tablas (N, S.obs, f1, f2).",
    "Tablas por pasos 1-4 + conjunto de figuras alineadas.",
    "Perfiles de diversidad (q = 0, 1 y 2) y gr\u00e1ficas comparativas entre zonas."
  ),
  Enfoque  = c(
    "Fundamenta la necesidad de estandarizar comparaciones cuando N difiere.",
    "Columna vertebral del cap\u00edtulo: organiza el an\u00e1lisis en secuencia \u00fanica.",
    "Enriquece TD y prepara la transici\u00f3n hacia FD y PD bajo el mismo marco de Hill."
  )
)

comp %>%
  kbl(booktabs = TRUE, longtable = FALSE, escape = TRUE) %>%
  kable_classic(full_width = FALSE) %>%
  kableExtra::kable_styling(latex_options = c("hold_position", "scale_down"),
                            font_size = 9) %>%
  kableExtra::column_spec(1, width = "2.3cm") %>%
  kableExtra::column_spec(2, width = "3.0cm") %>%
  kableExtra::column_spec(3, width = "3.0cm") %>%
  kableExtra::column_spec(4, width = "3.4cm") %>%
  kableExtra::column_spec(5, width = "3.4cm")

cat("\nCaso A.3 finalizado correctamente.\n")
