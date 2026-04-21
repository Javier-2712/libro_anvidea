# =========================================================
# ANVIDEA - Unidad III
# Capítulo 7 - Diversidad taxonómica
# ---------------------------------------------------------
# Archivo : run_cap7.R
# Propósito: ejecutar secuencialmente todos los scripts
#             del capítulo 7 desde su carpeta raíz
# Uso: source("run_cap7.R")  desde cap7-diversidad-taxonomica/
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Cap\u00edtulo 7\n")
cat("Diversidad taxon\u00f3mica\n")
cat("========================================\n")

# ---------------------------------------------------------
# Verificar que se ejecuta desde la carpeta del capítulo
# ---------------------------------------------------------

if (!dir.exists("R") || !dir.exists("data/raw")) {
  stop(
    "Ejecute run_cap7.R desde la carpeta cap7-diversidad-taxonomica/.\n",
    "Debe contener las subcarpetas R/ y data/raw/."
  )
}

# ---------------------------------------------------------
# Setup y funciones auxiliares
# ---------------------------------------------------------

source("R/00_setup.R")
source("R/07_funciones_auxiliares.R")

# ---------------------------------------------------------
# Caso A — Diversidad alfa
# ---------------------------------------------------------

cat("\n[1/6] Caso A.1: diversidad alfa cl\u00e1sica y curvas RAD...\n")
source("R/01_casoA_alfa_clasica_rad.R")

cat("\n[2/6] Caso A.2: GLMs y PERMANOVAs...\n")
source("R/02_casoA_alfa_glm_permanovas.R")

cat("\n[3/6] Caso A.3: n\u00fameros de Hill (alfa)...\n")
source("R/03_casoA_alfa_hill.R")

# ---------------------------------------------------------
# Caso B — Diversidad beta
# ---------------------------------------------------------

cat("\n[4/6] Caso B.1: diversidad beta cl\u00e1sica y varianza...\n")
source("R/04_casoB_beta_clasica_varianza.R")

cat("\n[5/6] Caso B.2: beta de Podani y recambio...\n")
source("R/05_casoB_beta_podani_recambio.R")

cat("\n[6/6] Caso B.3: n\u00fameros de Hill (beta)...\n")
source("R/06_casoB_beta_hill.R")

# ---------------------------------------------------------
# Guardar salidas consolidadas
# ---------------------------------------------------------

cat("\nGuardando salidas...\n")
source("R/08_guardar_salidas_cap7.R")

# ---------------------------------------------------------
# Renderizar reporte HTML
# ---------------------------------------------------------

cat("\nRenderizando reporte...\n")
source("R/09_render_reporte.R")

cat("\n========================================\n")
cat("Cap\u00edtulo 7 finalizado correctamente.\n")
cat("========================================\n")
