# =========================================================
# ANVIDEA - Capítulo 1
# Archivo: 03_funciones_auxiliares.R
# Propósito: funciones de apoyo para figuras, tablas y reportes
# Cargado automáticamente desde 00_setup.R
# =========================================================

# ---------------------------------------------------------
# 1. Verificar existencia de archivo
# ---------------------------------------------------------

verificar_archivo <- function(ruta_archivo) {
  if (!file.exists(ruta_archivo)) {
    stop(
      "No se encontró el archivo requerido:\n",
      ruta_archivo,
      "\nVerifique que exista en data/raw/."
    )
  }
}

# ---------------------------------------------------------
# 2. Detectar hoja fisicoquímica en Excel
# ---------------------------------------------------------

detectar_hoja <- function(archivo_excel, candidatos) {
  hojas       <- readxl::excel_sheets(archivo_excel)
  hojas_norm  <- tolower(iconv(hojas,      from = "", to = "ASCII//TRANSLIT"))
  cand_norm   <- tolower(iconv(candidatos, from = "", to = "ASCII//TRANSLIT"))
  idx <- match(cand_norm, hojas_norm)
  idx <- idx[!is.na(idx)]
  if (length(idx) == 0) {
    stop(
      "No se encontró ninguna hoja compatible.\n",
      "Hojas disponibles: ", paste(hojas, collapse = ", "), "\n",
      "Candidatos esperados: ", paste(candidatos, collapse = ", ")
    )
  }
  hojas[idx[1]]
}

# ---------------------------------------------------------
# 3. Estandarizar nombres de sitios
# ---------------------------------------------------------

std_sitio <- function(x) {
  x %>%
    as.character() %>%
    stringr::str_squish() %>%
    stringr::str_replace_all("\\s+", "")
}

# ---------------------------------------------------------
# 4. Guardar tablas en Excel
# ---------------------------------------------------------

guardar_xlsx <- function(df, ruta_archivo) {
  if (!grepl("\\.xlsx$", ruta_archivo, ignore.case = TRUE)) {
    ruta_archivo <- paste0(ruta_archivo, ".xlsx")
  }
  writexl::write_xlsx(df, path = ruta_archivo)
}

# ---------------------------------------------------------
# 5. Guardar figuras ggplot2
# ---------------------------------------------------------

exportar_figura <- function(plot, archivo, width = 8, height = 5, dpi = 300) {
  ggplot2::ggsave(
    filename = archivo,
    plot     = plot,
    width    = width,
    height   = height,
    dpi      = dpi,
    bg       = "white"
  )
}

# Alias homologado con cap2
guardar_figura <- exportar_figura

# ---------------------------------------------------------
# 6. Tabla HTML para reportes
# ---------------------------------------------------------

tabla_html <- function(df, caption = NULL, digits = 2, max_filas = NULL) {
  if (is.null(df) || !is.data.frame(df) || nrow(df) == 0) {
    return(htmltools::HTML("<p><em>Tabla no disponible.</em></p>"))
  }
  if (!is.null(max_filas)) df <- head(df, max_filas)
  kableExtra::kbl(df, caption = caption, digits = digits,
                  booktabs = TRUE, format = "html") %>%
    kableExtra::kable_classic(full_width = FALSE, html_font = "Cambria")
}

# ---------------------------------------------------------
# 7. Guardar y leer objetos RDS
# ---------------------------------------------------------

guardar_rds <- function(objeto, nombre_archivo) {
  ruta <- file.path(ruta_reportes, nombre_archivo)
  if (!grepl("\\.rds$", ruta, ignore.case = TRUE)) ruta <- paste0(ruta, ".rds")
  saveRDS(objeto, file = ruta)
}

leer_rds <- function(nombre_archivo) {
  ruta <- file.path(ruta_reportes, nombre_archivo)
  if (!grepl("\\.rds$", ruta, ignore.case = TRUE)) ruta <- paste0(ruta, ".rds")
  readRDS(ruta)
}
