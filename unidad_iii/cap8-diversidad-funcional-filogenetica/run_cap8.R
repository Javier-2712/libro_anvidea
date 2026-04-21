# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# ---------------------------------------------------------
# Archivo : run_cap8.R
# Propósito: ejecutar secuencialmente todos los scripts
#             del capítulo 8 desde su carpeta raíz
# Uso: source("run_cap8.R") desde cap8-diversidad-funcional-filogenetica/
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 8\n")
cat("Diversidad funcional y filogenética\n")
cat("========================================\n")

# ---------------------------------------------------------
# Verificar que se ejecuta desde la carpeta del capítulo
# ---------------------------------------------------------

if (!dir.exists("R") || !dir.exists("data/raw")) {
  stop(
    "Ejecute run_cap8.R desde la carpeta cap8-diversidad-funcional-filogenetica/.\n",
    "Debe contener las subcarpetas R/ y data/raw/."
  )
}

# ---------------------------------------------------------
# Setup y funciones auxiliares
# ---------------------------------------------------------

source("R/00_setup.R")
source("R/04_funciones_auxiliares.R")
source("R/05_alineador.R")
source("R/06_Rao.R")

# ---------------------------------------------------------
# Caso A — Diversidad alfa clásica de FD y PD
# ---------------------------------------------------------

cat("\n[1/3] Caso A: diversidad funcional y filogenética alfa...\n")
source("R/01_casoA_clasica.R")

# ---------------------------------------------------------
# Caso B.1 — Números de Hill (alfa)
# ---------------------------------------------------------

cat("\n[2/3] Caso B.1: números de Hill (alfa)...\n")
source("R/02_casoB1_alfa_hill.R")

# ---------------------------------------------------------
# Caso B.2 — Números de Hill (beta)
# ---------------------------------------------------------

cat("\n[3/3] Caso B.2: números de Hill (beta)...\n")
source("R/03_casoB2_beta_hill.R")

# ---------------------------------------------------------
# Guardar salidas consolidadas
# ---------------------------------------------------------

cat("\nGuardando salidas...\n")
source("R/07_guardar_salidas_cap8.R")

# ---------------------------------------------------------
# Renderizar reporte HTML
# ---------------------------------------------------------

cat("\nRenderizando reporte...\n")
source("R/08_render_reporte.R")

cat("\n========================================\n")
cat("Capítulo 8 finalizado correctamente.\n")
cat("========================================\n")
