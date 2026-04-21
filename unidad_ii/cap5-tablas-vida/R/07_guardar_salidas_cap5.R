# =========================================================
# ANVIDEA - Capítulo 5
# Tablas de vida y modelos matriciales
# ---------------------------------------------------------
# Archivo : 07_guardar_salidas_cap5.R
# Propósito: exportar tablas, figuras y objetos finales
#            Solo contiene guardar_xlsx / guardar_figura / guardar_rds
#            Sin lógica pedagógica ni análisis
# =========================================================

cat("\nGuardando tablas, figuras y objetos del capítulo 5...\n")

# =========================================================
# CASO A1 — Tabla de vida por edades
# =========================================================

# --- Tablas ---
guardar_xlsx(tabla_vida_sm, file.path(tab_dir, "casoA1_cementerio1_sanmiguel.xlsx"))
guardar_xlsx(tabla_vida_jp, file.path(tab_dir, "casoA1_cementerio2_jardines.xlsx"))
guardar_xlsx(tv_sex,        file.path(tab_dir, "casoA1_cementerio1_por_sexo.xlsx"))
guardar_xlsx(resumen_e0,    file.path(tab_dir, "casoA1_resumen_e0_sexo.xlsx"))
guardar_xlsx(res_boot,      file.path(tab_dir, "casoA1_bootstrap_sexos.xlsx"))
guardar_xlsx(tabla,         file.path(tab_dir, "casoA1_tamano_analitico.xlsx"))

# Nota: las figuras del casoA1 no se asignan a objetos en el script
# (patrón del libro). Se renderizan directamente en el reporte HTML.

# --- Objeto consolidado casoA1 (.rds) ---
resultado_casoA1 <- list(
  cementerio1      = tabla_vida_sm,
  cementerio2      = tabla_vida_jp,
  cementerio1_sexo = tv_sex,
  resumen_e0       = resumen_e0,
  bootstrap_sexos  = res_boot,
  tamano_analitico = tabla
)

guardar_rds(resultado_casoA1, "resultado_casoA1.rds")
cat("  [casoA1] Objetos guardados.\n")

# =========================================================
# CASO A2 — Tabla de vida clásica (Gotelli)
# =========================================================

# --- Tablas ---
guardar_xlsx(tabla,   file.path(tab_dir, "casoA2_base_gotelli.xlsx"))
guardar_xlsx(tabla_v, file.path(tab_dir, "casoA2_tabla_vida.xlsx"))
guardar_xlsx(estad,   file.path(tab_dir, "casoA2_estadisticos_demograficos.xlsx"))
guardar_xlsx(tabla2,  file.path(tab_dir, "casoA2_estructura_edad.xlsx"))

# --- Objeto consolidado casoA2 (.rds) ---
resultado_casoA2 <- list(
  base_gotelli    = tabla,
  tabla_vida      = tabla_v,
  estadisticos    = estad,
  estructura_edad = tabla2
)

guardar_rds(resultado_casoA2, "resultado_casoA2.rds")
cat("  [casoA2] Objetos guardados.\n")

# =========================================================
# CASO B — Modelo de Leslie
# =========================================================

# --- Tablas ---
guardar_xlsx(tabla2,
             file.path(tab_dir, "casoB_estructura_edad.xlsx"))
guardar_xlsx(as.data.frame(L_pre),
             file.path(tab_dir, "casoB_matriz_leslie_pre.xlsx"))
guardar_xlsx(as.data.frame(L_post),
             file.path(tab_dir, "casoB_matriz_leslie_post.xlsx"))
guardar_xlsx(simulacion,
             file.path(tab_dir, "casoB_simulacion_ancho.xlsx"))
guardar_xlsx(simulacion_l,
             file.path(tab_dir, "casoB_simulacion_largo.xlsx"))

# Nota: las figuras del casoB no se asignan a objetos (patrón del libro).

# --- Objeto consolidado casoB (.rds) ---
resultado_casoB <- list(
  estructura_edad    = tabla2,
  matriz_leslie_pre  = as.data.frame(L_pre),
  matriz_leslie_post = as.data.frame(L_post),
  simulacion_ancho   = simulacion,
  simulacion_largo   = simulacion_l
)

guardar_rds(resultado_casoB, "resultado_casoB.rds")
cat("  [casoB] Objetos guardados.\n")

# =========================================================
# CASO C — Modelo de Lefkovitch
# =========================================================

# --- Tablas ---
guardar_xlsx(tabla_v,
             file.path(tab_dir, "casoC_tabla_estados_semillas.xlsx"))
guardar_xlsx(tabla_v1,
             file.path(tab_dir, "casoC_tabla_vida_estados.xlsx"))
guardar_xlsx(estad,
             file.path(tab_dir, "casoC_estadisticos_demograficos.xlsx"))
guardar_xlsx(tabla2,
             file.path(tab_dir, "casoC_estructura_estados.xlsx"))
guardar_xlsx(as.data.frame(L_pre),
             file.path(tab_dir, "casoC_matriz_lefkovitch_pre.xlsx"))
guardar_xlsx(as.data.frame(L_post),
             file.path(tab_dir, "casoC_matriz_lefkovitch_post.xlsx"))
guardar_xlsx(simulacion,
             file.path(tab_dir, "casoC_simulacion_ancho.xlsx"))
guardar_xlsx(simulacion_l,
             file.path(tab_dir, "casoC_simulacion_largo.xlsx"))

# Nota: las figuras del casoC no se asignan a objetos (patrón del libro).

# --- Objeto consolidado casoC (.rds) ---
resultado_casoC <- list(
  tabla_estados      = tabla_v,
  tabla_vida_estados = tabla_v1,
  estadisticos       = estad,
  estructura_estados = tabla2,
  matriz_pre         = as.data.frame(L_pre),
  matriz_post        = as.data.frame(L_post),
  simulacion_ancho   = simulacion,
  simulacion_largo   = simulacion_l
)

guardar_rds(resultado_casoC, "resultado_casoC.rds")
cat("  [casoC] Objetos guardados.\n")

cat("Salidas del capítulo 5 guardadas correctamente.\n")
