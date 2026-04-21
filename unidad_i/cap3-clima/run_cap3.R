# =========================================================
# ANVIDEA - Capítulo 3
# Archivo: run_cap3.R
# Propósito: punto de entrada único para ejecutar todo el capítulo
# Uso: source("run_cap3.R")  desde la raíz del capítulo
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 3\n")
cat("Análisis climático y ecológico en ambientes contrastantes\n")
cat("========================================\n\n")

if (!dir.exists("R"))                 stop("Ejecute run_cap3.R desde la raíz del capítulo.")
if (!file.exists("reporte_cap3.qmd")) stop("No se encontró reporte_cap3.qmd.")

wd_inicial <- getwd()

# ---------------------------------------------------------
# 1. Configuración general
# ---------------------------------------------------------
source(file.path(wd_inicial, "R", "00_setup.R"))
cat("\n[1/4] Configuración cargada.\n")
if (!exists("root_dir")) root_dir <- wd_inicial
setwd(root_dir)

# ---------------------------------------------------------
# 2. Caso guiado
# ---------------------------------------------------------
cat("\n[2/4] Caso guiado: análisis climático y ecológico...\n")
source(file.path(root_dir, "R", "01_caso_clima_ecologia.R"))
cat("[2/4] Caso guiado finalizado.\n")
setwd(root_dir)

# ---------------------------------------------------------
# 3. Guardar salidas
# ---------------------------------------------------------
cat("\n[3/4] Guardando tablas, figuras y objeto final...\n")
source(file.path(root_dir, "R", "03_guardar_salidas_cap3.R"))
cat("[3/4] Salidas guardadas.\n")
setwd(root_dir)

# ---------------------------------------------------------
# 4. Reporte HTML
# ---------------------------------------------------------
cat("\n[4/4] Renderizando reporte...\n")
source(file.path(root_dir, "R", "04_render_reporte.R"))
cat("[4/4] Reporte finalizado.\n")

cat("\nCapítulo 3 completado correctamente.\n")
