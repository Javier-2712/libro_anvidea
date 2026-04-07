# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 02_casoB_PD_beta_y_alineacion.R
# Propósito: alinear árbol y datos biológicos para estimar
#            diversidad beta filogenética entre zonas
# =========================================================

source("R/00_setup.R")
source("R/04_funciones_auxiliares.R")
source("R/05_alineador.R")

# ---------------------------------------------------------
# 1. Cargar datos y verificar insumos
# ---------------------------------------------------------

datos_path <- file.path(data_dir, "datos.c8.xlsx")
arbol_beta_path <- file.path(data_dir, "arbol_filo_beta.rds")

if (!file.exists(datos_path)) {
  stop("No se encontró el archivo de datos: ", datos_path)
}
if (!file.exists(arbol_beta_path)) {
  stop("No se encontró el árbol filogenético: ", arbol_beta_path)
}

taxas <- leer_tax_c8(data_dir)
tax1  <- leer_tax1_c8(data_dir)
arbol_beta <- readRDS(arbol_beta_path)

if (is.null(arbol_beta) || !inherits(arbol_beta, "phylo")) {
  stop("El objeto leído en arbol_filo_beta.rds no es un árbol 'phylo' válido.")
}

# Resolver de manera robusta el nombre de la columna de abreviaturas
col_abrev <- dplyr::case_when(
  "Abrev"  %in% names(tax1) ~ "Abrev",
  "Abbrev" %in% names(tax1) ~ "Abbrev",
  TRUE ~ ""
)

if (col_abrev == "") {
  stop("La tabla tax1 debe contener una columna de abreviaturas ('Abrev' o 'Abbrev').")
}
if (!("LatinName" %in% names(tax1))) {
  stop("La tabla tax1 debe contener la columna 'LatinName'.")
}

tax1_map <- tax1 %>% dplyr::select(dplyr::all_of(c(col_abrev, "LatinName")))

# ---------------------------------------------------------
# 2. Preparar matriz de abundancia por zonas
# ---------------------------------------------------------

# En este caso trabajamos a escala de ensamblajes zonales para comparar
# pares de zonas a lo largo del gradiente ecológico del río.
biol_zona <- preparar_biol_zona(taxas)

if (is.null(biol_zona) || nrow(biol_zona) == 0 || ncol(biol_zona) == 0) {
  stop("La matriz biol_zona está vacía o no pudo construirse correctamente.")
}

zonas_requeridas <- c("M", "P", "RM")
zonas_faltantes <- setdiff(zonas_requeridas, rownames(biol_zona))
if (length(zonas_faltantes) > 0) {
  stop("Faltan zonas requeridas en biol_zona: ", paste(zonas_faltantes, collapse = ", "))
}

# Excluir especie problemática si aparece. Se deja explícito porque su
# presencia puede romper la alineación taxonómica o filogenética.
especie_problem <- "Notropis aguirrepequenoi"
if (especie_problem %in% colnames(biol_zona)) {
  biol_zona <- biol_zona[, colnames(biol_zona) != especie_problem, drop = FALSE]
}

# Quitar especies con abundancia total cero, si existieran.
biol_zona <- biol_zona[, colSums(biol_zona, na.rm = TRUE) > 0, drop = FALSE]

if (ncol(biol_zona) < 2) {
  stop("Después del filtrado quedaron menos de dos especies en biol_zona.")
}

# Construir comparaciones pareadas (especies x zonas) para iNEXTbeta3D.
biol_PD_beta <- list(
  M_vs_P  = t(biol_zona[c("M", "P"),  , drop = FALSE]),
  M_vs_RM = t(biol_zona[c("M", "RM"), drop = FALSE]),
  P_vs_RM = t(biol_zona[c("P", "RM"), drop = FALSE])
)

# Validar estructura mínima de cada par.
for (nm in names(biol_PD_beta)) {
  obj <- biol_PD_beta[[nm]]
  if (is.null(obj) || nrow(obj) == 0 || ncol(obj) != 2) {
    stop("El par ", nm, " no tiene la estructura esperada de especies x 2 zonas.")
  }
  if (any(colSums(obj, na.rm = TRUE) == 0)) {
    stop("El par ", nm, " contiene una zona con abundancia total cero.")
  }
}

# ---------------------------------------------------------
# 3. Alinear automáticamente árbol y datos
# ---------------------------------------------------------

# La alineación es un paso central del caso: garantiza que las especies de
# las matrices biológicas correspondan exactamente a las puntas del árbol.
alineado <- alinear_beta(
  biol_PD_beta = biol_PD_beta,
  arbol_beta = arbol_beta,
  tax1 = tax1_map
)

if (is.null(alineado)) {
  stop("La función alinear_beta() devolvió NULL.")
}
if (is.null(alineado$pairs_aligned) || length(alineado$pairs_aligned) == 0) {
  stop("La alineación no devolvió pares biológicos válidos.")
}
if (is.null(alineado$tree_aligned) || !inherits(alineado$tree_aligned, "phylo")) {
  stop("La alineación no devolvió un árbol filogenético válido.")
}

reporte <- tibble::enframe(alineado$report, name = "Parametro", value = "Valor")
guardar_tabla_excel(reporte, "tabla_12_reporte_alineacion_PD_beta.xlsx")

biol_PD <- alineado$pairs_aligned
arbol_PD_beta <- alineado$tree_aligned

# Verificar coherencia entre el árbol alineado y cada par de matrices.
for (nm in names(biol_PD)) {
  mat <- biol_PD[[nm]]
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) != 2) {
    stop("El objeto alineado ", nm, " no tiene el formato esperado (especies x 2 zonas).")
  }

  spp_faltantes <- setdiff(rownames(mat), arbol_PD_beta$tip.label)
  if (length(spp_faltantes) > 0) {
    stop(
      "El par ", nm,
      " contiene especies ausentes del árbol alineado: ",
      paste(spp_faltantes, collapse = ", ")
    )
  }

  if (any(colSums(mat, na.rm = TRUE) == 0)) {
    stop("El par alineado ", nm, " contiene una zona con abundancia total cero.")
  }
}

# ---------------------------------------------------------
# 4. iNEXTbeta3D - coverage based
# ---------------------------------------------------------

# El enfoque coverage-based permite comparar diversidad beta bajo coberturas
# equivalentes, reduciendo el sesgo por diferencias de completitud muestral.
salida_pd_cov <- iNEXTbeta3D::iNEXTbeta3D(
  data = biol_PD,
  diversity = "PD",
  PDtree = arbol_PD_beta,
  datatype = "abundance",
  base = "coverage",
  nboot = 10,
  PDtype = "meanPD"
)

# Exportar resultados para todos los pares.
for (par in names(salida_pd_cov)) {
  res <- salida_pd_cov[[par]]

  if (!is.null(res$gamma)) {
    guardar_tabla_excel(
      as.data.frame(res$gamma),
      paste0("tabla_13_PD_beta_gamma_", par, "_coverage.xlsx")
    )
  }
  if (!is.null(res$alpha)) {
    guardar_tabla_excel(
      as.data.frame(res$alpha),
      paste0("tabla_14_PD_beta_alpha_", par, "_coverage.xlsx")
    )
  }
  if (!is.null(res$beta)) {
    guardar_tabla_excel(
      as.data.frame(res$beta),
      paste0("tabla_15_PD_beta_beta_", par, "_coverage.xlsx")
    )
  }
}

p_pd_beta_cov <- iNEXTbeta3D::ggiNEXTbeta3D(salida_pd_cov) +
  ggplot2::labs(
    x = "Cobertura de las muestras",
    y = "Diversidad filogenética",
    title = "iNEXTbeta3D filogenético coverage-based"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_pd_beta_cov, "fig_04_PD_beta_coverage.png", width = 8, height = 6)

# ---------------------------------------------------------
# 5. iNEXTbeta3D - size based
# ---------------------------------------------------------

# El enfoque size-based permite mostrar cómo cambian las estimaciones al
# estandarizar por número de individuos y no por cobertura.
salida_pd_size <- iNEXTbeta3D::iNEXTbeta3D(
  data = biol_PD,
  diversity = "PD",
  PDtree = arbol_PD_beta,
  datatype = "abundance",
  base = "size",
  nboot = 10,
  PDtype = "meanPD"
)

for (par in names(salida_pd_size)) {
  res <- salida_pd_size[[par]]

  if (!is.null(res$gamma)) {
    guardar_tabla_excel(
      as.data.frame(res$gamma),
      paste0("tabla_16_PD_beta_gamma_", par, "_size.xlsx")
    )
  }
  if (!is.null(res$alpha)) {
    guardar_tabla_excel(
      as.data.frame(res$alpha),
      paste0("tabla_17_PD_beta_alpha_", par, "_size.xlsx")
    )
  }
  if (!is.null(res$beta)) {
    guardar_tabla_excel(
      as.data.frame(res$beta),
      paste0("tabla_18_PD_beta_beta_", par, "_size.xlsx")
    )
  }
}

p_pd_beta_size <- iNEXTbeta3D::ggiNEXTbeta3D(salida_pd_size) +
  ggplot2::labs(
    x = "Número de individuos",
    y = "Diversidad filogenética",
    title = "iNEXTbeta3D filogenético size-based"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_pd_beta_size, "fig_05_PD_beta_size.png", width = 8, height = 6)

# ---------------------------------------------------------
# 6. Construir resumen largo para facilitar la interpretación
# ---------------------------------------------------------

extraer_componentes_beta <- function(obj_salida, base_label) {
  comps <- c("gamma", "alpha", "beta")
  out <- list()

  for (par in names(obj_salida)) {
    for (comp in comps) {
      tabla <- obj_salida[[par]][[comp]]
      if (!is.null(tabla)) {
        df <- as.data.frame(tabla)
        df$Par <- par
        df$Base <- base_label
        df$Componente <- comp
        out[[paste(par, comp, base_label, sep = "_")]] <- df
      }
    }
  }

  if (length(out) == 0) return(NULL)
  dplyr::bind_rows(out)
}

resumen_cov  <- extraer_componentes_beta(salida_pd_cov, "coverage")
resumen_size <- extraer_componentes_beta(salida_pd_size, "size")
resumen_beta_pd <- dplyr::bind_rows(resumen_cov, resumen_size)

if (!is.null(resumen_beta_pd) && nrow(resumen_beta_pd) > 0) {
  guardar_tabla_excel(
    resumen_beta_pd,
    "tabla_19_resumen_largo_PD_beta.xlsx"
  )
}

message("Caso B completado. Revise outputs/figuras y outputs/tablas.")
