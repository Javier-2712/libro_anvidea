# =========================================================
# ANVIDEA - Capítulo 5
# Tablas de vida y modelos matriciales
# ---------------------------------------------------------
# Archivo : run_cap5.R
# Propósito: ejecutar secuencialmente todo el capítulo
# =========================================================

cat("\n========================================\n")
cat("ANVIDEA - Capítulo 5\n")
cat("Tablas de vida y modelos matriciales\n")
cat("========================================\n")

if (!dir.exists("R")) {
  stop("Debes ejecutar run_cap5.R desde la carpeta cap5-tablas-vida")
}

# ---------------------------------------------------------
# Setup y funciones auxiliares
# ---------------------------------------------------------

source("R/00_setup.R")
source("R/05_funciones_auxiliares.R")

# ---------------------------------------------------------
# Ejecutar casos guiados
# ---------------------------------------------------------

cat("\n[1/4] Caso A1: tabla de vida por edad...\n")
source("R/01_casoA1_tabla_vida_edad.R")

cat("[2/4] Caso A2: tabla de vida tipo Gotelli...\n")
source("R/02_casoA2_tabla_vida_gotelli.R")

cat("[3/4] Caso B: modelo de Leslie...\n")
source("R/03_casoB_modelo_leslie.R")

cat("[4/4] Caso C: modelo de Lefkovitch...\n")
source("R/04_casoC_modelo_lefkovitch.R")

# ---------------------------------------------------------
# Guardar salidas
# ---------------------------------------------------------

cat("\nGuardando salidas...\n")
source("R/07_guardar_salidas_cap5.R")

# ---------------------------------------------------------
# Renderizar reporte
# ---------------------------------------------------------

cat("\nRenderizando reporte...\n")
source("R/06_render_reporte.R")

cat("\n========================================\n")
cat("Capítulo 5 finalizado correctamente.\n")
cat("========================================\n")
