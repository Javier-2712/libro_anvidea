# =========================================================
# ANVIDEA - Unidad III
# Ecología de comunidades
# ---------------------------------------------------------
# Archivo : run_unidad3.R
# Propósito: ejecutar la Unidad III completa en secuencia
# Uso: source("run_unidad3.R") desde la carpeta unidad_iii/
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Unidad III\n")
cat("Ecología de comunidades\n")
cat("========================================\n")

# ---------------------------------------------------------
# Verificar que se ejecuta desde la carpeta correcta
# ---------------------------------------------------------

if (!dir.exists("cap7-diversidad-taxonomica") ||
    !dir.exists("cap8-diversidad-funcional-filogenetica")) {
  stop(
    "Ejecute run_unidad3.R desde la carpeta unidad_iii/.\n",
    "Debe contener las subcarpetas cap7-diversidad-taxonomica/ ",
    "y cap8-diversidad-funcional-filogenetica/."
  )
}

# ---------------------------------------------------------
# Capítulo 7 — Diversidad taxonómica
# ---------------------------------------------------------

cat("\n[Cap. 7] Diversidad taxonómica...\n")

unidad_dir <- getwd()
setwd(file.path(unidad_dir, "cap7-diversidad-taxonomica"))
source("run_cap7.R")
setwd(unidad_dir)

# ---------------------------------------------------------
# Capítulo 8 — Diversidad funcional y filogenética
# ---------------------------------------------------------

cat("\n[Cap. 8] Diversidad funcional y filogenética...\n")

setwd(file.path(unidad_dir, "cap8-diversidad-funcional-filogenetica"))
source("run_cap8.R")
setwd(unidad_dir)

# ---------------------------------------------------------
# Cierre
# ---------------------------------------------------------

cat("\n========================================\n")
cat("Unidad III ejecutada correctamente.\n")
cat("Resultados en outputs/ de cada capítulo.\n")
cat("========================================\n")
