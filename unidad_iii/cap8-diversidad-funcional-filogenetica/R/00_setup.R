# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# ---------------------------------------------------------
# Archivo : 00_setup.R
# Propósito: cargar paquetes, definir rutas y preparar
#             el entorno de trabajo del capítulo 8
# =========================================================

cat("========================================\n")
cat("ANVIDEA - Capítulo 8\n")
cat("Diversidad funcional y filogenética\n")
cat("========================================\n\n")

# ---------------------------------------------------------
# 1. Verificación de estructura mínima
# ---------------------------------------------------------

if (!dir.exists("data/raw")) {
  stop(
    "No se encontró la carpeta 'data/raw'.\n",
    "Ejecute este script desde la raíz del capítulo 8."
  )
}

if (!dir.exists("R")) {
  stop(
    "No se encontró la carpeta 'R'.\n",
    "Ejecute este script desde la raíz del capítulo 8."
  )
}

# ---------------------------------------------------------
# 2. Rutas principales
# ---------------------------------------------------------

root_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
data_dir <- file.path(root_dir, "data", "raw")
out_dir  <- file.path(root_dir, "outputs")
fig_dir  <- file.path(out_dir, "figuras")
tab_dir  <- file.path(out_dir, "tablas")
rep_dir  <- file.path(out_dir, "reportes")

archivo_datos <- file.path(data_dir, "datos.c8.xlsx")

# ---------------------------------------------------------
# 3. Crear carpetas de salida
# ---------------------------------------------------------

for (d in c(out_dir, fig_dir, tab_dir, rep_dir)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# ---------------------------------------------------------
# 4. Paquetes requeridos
# ---------------------------------------------------------

required_pkgs <- c(
  "tidyverse", "readxl", "writexl", "kableExtra",
  "FD", "ape", "taxize", "vegan", "ggrepel",
  "RColorBrewer", "factoextra", "iNEXT.3D",
  "iNEXT.beta3D", "ade4"
)

missing_pkgs <- required_pkgs[
  !vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_pkgs) > 0) {
  stop(
    "Faltan paquetes requeridos para el capítulo 8: ",
    paste(missing_pkgs, collapse = ", "),
    "\nInstálalos antes de continuar."
  )
}

invisible(lapply(required_pkgs, library, character.only = TRUE))

# ---------------------------------------------------------
# 5. Verificar archivos base
# ---------------------------------------------------------

archivos_base <- c(
  "datos.c8.xlsx",
  "arbol_filo_alfa.rds",
  "arbol_filo_beta.rds"
)

faltantes_base <- archivos_base[!file.exists(file.path(data_dir, archivos_base))]

if (length(faltantes_base) > 0) {
  warning(
    "No se encontraron algunos archivos base en data/raw/: ",
    paste(faltantes_base, collapse = ", ")
  )
}

# ---------------------------------------------------------
# 6. Utilidades de guardado
# ---------------------------------------------------------

guardar_figura <- function(plot_obj, nombre, width = 8, height = 6, dpi = 300) {
  ruta <- file.path(fig_dir, nombre)
  ggplot2::ggsave(
    filename = ruta,
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi
  )
  invisible(ruta)
}

guardar_xlsx <- function(obj, ruta) {
  writexl::write_xlsx(as.data.frame(obj), path = ruta)
  invisible(ruta)
}

guardar_tabla_excel <- function(obj, nombre) {
  ruta <- file.path(tab_dir, nombre)
  writexl::write_xlsx(as.data.frame(obj), path = ruta)
  invisible(ruta)
}

guardar_rds <- function(obj, nombre) {
  ruta <- file.path(rep_dir, nombre)
  saveRDS(obj, ruta)
  invisible(ruta)
}

# ---------------------------------------------------------
# 7. Mensaje final
# ---------------------------------------------------------

cat("Entorno del Capítulo 8 configurado correctamente.\n")
cat("Directorio raíz  :", root_dir, "\n")
cat("Directorio datos :", data_dir, "\n")
cat("Directorio salida:", out_dir, "\n\n")
