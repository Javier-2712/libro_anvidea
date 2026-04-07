# =========================================================
# ANVIDEA - Unidad III
# Archivo: run_unidad3.R
# Propósito: ejecutar la Unidad III completa
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Unidad III\n")
cat("Ecología de comunidades\n")
cat("========================================\n")

# ---------------------------------------------------------
# Capítulo 7 - Diversidad taxonómica
# ---------------------------------------------------------

cat("\nEjecutando Capítulo 7...\n")
source("cap7-diversidad-taxonomica/R/01_casoA_TD_alfa_y_Hill.R")
source("cap7-diversidad-taxonomica/R/02_casoB_TD_beta_y_recambio.R")

# ---------------------------------------------------------
# Capítulo 8 - Diversidad funcional y filogenética
# ---------------------------------------------------------

cat("\nEjecutando Capítulo 8...\n")
source("cap8-diversidad-funcional-filogenetica/R/01_casoA_FD_PD_alfa.R")
source("cap8-diversidad-funcional-filogenetica/R/02_casoB_PD_beta_y_alineacion.R")
source("cap8-diversidad-funcional-filogenetica/R/03_casoC_FD_beta.R")

cat("\n✔ Unidad III ejecutada correctamente\n")