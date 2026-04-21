# =========================================================
# ANVIDEA - Capítulo 4
# Modelos de crecimiento poblacional
# ---------------------------------------------------------
# Archivo : run_cap4.R
# Propósito: Ejecutar de forma secuencial todo el capítulo
# =========================================================

cat("\n========================================\n")
cat("ANVIDEA - Capítulo 4\n")
cat("Modelos de crecimiento poblacional\n")
cat("========================================\n")

# ---------------------------------------------------------
# Verificar directorio de trabajo
# ---------------------------------------------------------

if (!dir.exists("R")) {
  stop("Debes ejecutar run_cap4.R desde la carpeta cap4-modelos-poblacionales")
}

# ---------------------------------------------------------
# Setup y funciones auxiliares
# ---------------------------------------------------------

source("R/00_setup.R")
source("R/06_funciones_auxiliares.R")

# ---------------------------------------------------------
# Ejecutar scripts del capítulo
# ---------------------------------------------------------

cat("\n[1/3] Modelo exponencial continuo...\n")
source("R/01_modelo_exponencial_continuo.R")

cat("[2/3] Modelo exponencial discreto...\n")
source("R/02_modelo_exponencial_discreto.R")

cat("[3/3] Modelo logístico...\n")
source("R/03_modelo_logistico.R")

# ---------------------------------------------------------
# Guardar salidas
# ---------------------------------------------------------

cat("\nGuardando salidas...\n")
source("R/05_guardar_salidas_cap4.R")

# ---------------------------------------------------------
# Renderizar reporte
# ---------------------------------------------------------

cat("\nRenderizando reporte...\n")
source("R/04_render_reporte.R")

cat("\n========================================\n")
cat("Capítulo 4 finalizado correctamente.\n")
cat("========================================\n")
