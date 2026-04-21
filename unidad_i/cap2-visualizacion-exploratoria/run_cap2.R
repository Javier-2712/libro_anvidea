# =========================================================
# ANVIDEA - Capítulo 2
# Archivo: run_cap2.R
# Propósito: punto de entrada único para ejecutar todo el capítulo
# Uso: source("run_cap2.R")  desde la raíz del capítulo
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 2\n")
cat("Visualización exploratoria de datos ecológicos\n")
cat("========================================\n\n")

if (!dir.exists("R"))              stop("Ejecute run_cap2.R desde la raíz del capítulo.")
if (!file.exists("reporte_cap2.qmd")) stop("No se encontró reporte_cap2.qmd.")

wd_inicial <- getwd()

# ---------------------------------------------------------
# 1. Configuración general
# ---------------------------------------------------------
source(file.path(wd_inicial, "R", "00_setup.R"))
cat("\n[1/5] Configuración cargada.\n")
if (!exists("root_dir")) root_dir <- wd_inicial
setwd(root_dir)

# ---------------------------------------------------------
# 2. Caso A: Mesozooplancton estuarino
# ---------------------------------------------------------
cat("\n[2/5] Caso A: mesozooplancton estuarino...\n")
source(file.path(root_dir, "R", "01_casoA_mesozooplancton.R"))
cat("[2/5] Caso A finalizado.\n")
setwd(root_dir)

# ---------------------------------------------------------
# 3. Caso B: Macroinvertebrados bentónicos fluviales
# ---------------------------------------------------------
cat("\n[3/5] Caso B: macroinvertebrados bentónicos fluviales...\n")
source(file.path(root_dir, "R", "02_casoB_macroinvertebrados.R"))
cat("[3/5] Caso B finalizado.\n")
setwd(root_dir)

# ---------------------------------------------------------
# 4. Guardar salidas
# ---------------------------------------------------------
cat("\n[4/5] Guardando tablas, figuras y objetos...\n")
source(file.path(root_dir, "R", "04_guardar_salidas_cap2.R"))
cat("[4/5] Salidas guardadas.\n")
setwd(root_dir)

# ---------------------------------------------------------
# 5. Reporte HTML
# ---------------------------------------------------------
cat("\n[5/5] Renderizando reporte...\n")
source(file.path(root_dir, "R", "05_render_reporte.R"))
cat("[5/5] Reporte finalizado.\n")

cat("\nCapítulo 2 completado correctamente.\n")
