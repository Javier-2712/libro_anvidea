# =========================================================
# ANDIVEA - Unidad II
# Capítulo 5 - Tablas de vida y modelos matriciales
# Archivo: 01_casoA1_tabla_vida_edad.R
# =========================================================

source("R/00_setup.R")
source("R/03_funciones_auxiliares.R")

archivo_datos <- file.path(data_dir, "datos.c5.xlsx")

message("→ Leyendo datos de cementerios...")

# -----------------------------------------
# Cementerio 1
# -----------------------------------------
datos1 <- leer_cementerio(archivo_datos, "cement1") %>%
  mutate(sexo = trimws(tolower(sexo))) %>%
  filter(!is.na(edad), edad >= 0)

tv1 <- construir_tabla_vida(datos1$edad, ancho = 10)

# -----------------------------------------
# Cementerio 2
# -----------------------------------------
datos2 <- leer_cementerio(archivo_datos, "cement2") %>%
  filter(!is.na(edad), edad >= 0)

tv2 <- construir_tabla_vida(datos2$edad, ancho = 10)

message("→ Construyendo tablas de vida...")

# -----------------------------------------
# Comparación por sexo (cementerio 1)
# -----------------------------------------
tv1_sexo <- datos1 %>%
  group_by(sexo) %>%
  group_modify(~construir_tabla_vida(.x$edad, ancho = 10)) %>%
  ungroup()

# -----------------------------------------
# Gráficos
# -----------------------------------------
p_lx <- ggplot(tv1_sexo, aes(x, lx, color = sexo)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  labs(
    title = "Curvas de supervivencia por sexo",
    x = "Edad (clases)",
    y = "l[x]"
  ) +
  theme_bw()

p_ex <- ggplot(tv1_sexo, aes(x, ex, color = sexo)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  labs(
    title = "Esperanza de vida por sexo",
    x = "Edad (clases)",
    y = "e[x]"
  ) +
  theme_bw()

library(cowplot)
fig <- plot_grid(p_lx, p_ex, ncol = 2)

guardar_figura(fig, "cap5_tabla_vida_sexos_cement1.png", width = 11, height = 5)

# -----------------------------------------
# Bootstrap de diferencia en e0
# -----------------------------------------
if (n_distinct(na.omit(datos1$sexo)) == 2) {

  message("→ Ejecutando bootstrap para diferencia en e0...")

  boot <- bootstrap_diferencia_e0(
    datos1,
    grupo = "sexo",
    reps = 500,
    ancho = 10
  )

  resumen_boot <- boot %>%
    summarise(
      media = mean(diff, na.rm = TRUE),
      li = quantile(diff, 0.025, na.rm = TRUE),
      ls = quantile(diff, 0.975, na.rm = TRUE)
    )

  guardar_tabla_excel(
    list(
      cementerio1 = tv1,
      cementerio2 = tv2,
      cementerio1_sexo = tv1_sexo,
      bootstrap = boot,
      resumen_bootstrap = resumen_boot
    ),
    archivo = "cap5_tablas_vida.xlsx"
  )

} else {

  guardar_tabla_excel(
    list(
      cementerio1 = tv1,
      cementerio2 = tv2,
      cementerio1_sexo = tv1_sexo
    ),
    archivo = "cap5_tablas_vida.xlsx"
  )
}

message("✔ Capítulo 5 - Caso A1 ejecutado correctamente")
