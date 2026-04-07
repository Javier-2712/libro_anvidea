# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 01_casoA_FD_PD_alfa.R
# Propósito: desarrollar diversidad funcional alfa por sitio
#            y comparaciones FD/PD por ensamblajes zonales
# =========================================================

source("R/00_setup.R")
source("R/04_funciones_auxiliares.R")
source("R/06_Rao.R")

# ---------------------------------------------------------
# 1. Cargar datos y verificar archivos base
# ---------------------------------------------------------

arbol_alfa_path <- file.path(data_dir, "arbol_filo_alfa.rds")

if (!dir.exists(data_dir)) stop("No se encontró el directorio de datos: ", data_dir)
if (!file.exists(arbol_alfa_path)) stop("No se encontró el archivo: ", arbol_alfa_path)

taxas <- leer_tax_c8(data_dir)
rasgos <- leer_rasgos_c8(data_dir)
arbol_filo_alfa <- readRDS(arbol_alfa_path)

if (is.null(taxas) || nrow(taxas) == 0) {
  stop("La tabla biológica 'taxas' está vacía o no pudo leerse correctamente.")
}

if (is.null(rasgos) || nrow(rasgos) == 0) {
  stop("La tabla de rasgos está vacía o no pudo leerse correctamente.")
}

# ---------------------------------------------------------
# 2. Preparar matrices biológicas y de rasgos
# ---------------------------------------------------------

biol1 <- preparar_biol_abrev(taxas)
if (is.null(biol1) || nrow(biol1) == 0 || ncol(biol1) == 0) {
  stop("La matriz biológica por sitio quedó vacía tras la preparación.")
}

guardar_tabla_excel(as.data.frame(utils::head(biol1, 10)), "tabla_01_biol1_abundancias_abrev.xlsx")

rasgos_fd <- preparar_rasgos_fd(rasgos)
if (is.null(rasgos_fd) || nrow(rasgos_fd) == 0) {
  stop("La tabla de rasgos preparada quedó vacía.")
}

guardar_tabla_excel(as.data.frame(utils::head(rasgos_fd, 10)), "tabla_02_rasgos_preparados.xlsx")

# Matriz sitio x especie para FD::dbFD y functcomp.
# En esta primera fase se trabaja a escala local (alfa) por sitio.
abund_site <- biol1

# Mantener solo especies presentes en la tabla de rasgos.
especies_fd <- intersect(colnames(abund_site), rasgos_fd$Abrev)
if (length(especies_fd) < 2) {
  stop("Hay menos de dos especies en común entre abundancias y rasgos para el análisis FD alfa.")
}

abund_site <- abund_site[, especies_fd, drop = FALSE]
rasgos_abrev <- alinear_matriz_rasgos_abrev(rasgos_fd)
rasgos_abrev <- rasgos_abrev[especies_fd, , drop = FALSE]

if (!identical(colnames(abund_site), rownames(rasgos_abrev))) {
  stop("La matriz de abundancias por sitio y la matriz de rasgos abreviados no quedaron alineadas.")
}

# Eliminar sitios sin abundancia total, ya que impiden cálculos robustos de FD.
sitios_validos <- rowSums(abund_site, na.rm = TRUE) > 0
if (!all(sitios_validos)) {
  abund_site <- abund_site[sitios_validos, , drop = FALSE]
}

if (nrow(abund_site) == 0) {
  stop("No quedaron sitios con abundancia positiva para el análisis FD alfa.")
}

# ---------------------------------------------------------
# 3. CWM y métricas clásicas de diversidad funcional alfa
# ---------------------------------------------------------

# Los CWM resumen el rasgo promedio ponderado por abundancia en cada sitio.
cwm <- FD::functcomp(rasgos_abrev, as.matrix(abund_site), CWM.type = "all")
guardar_tabla_excel(as.data.frame(cwm), "tabla_03_CWM_por_sitio.xlsx")

riqueza_sp_sitio <- colSums(t(abund_site) > 0)
riqueza_por_sitio <- rowSums(abund_site > 0, na.rm = TRUE)

if (any(riqueza_por_sitio < 3)) {
  warning(
    "Hay sitios con menos de 3 especies. FRic, FEve o FDiv pueden resultar inestables o no estimables en algunos casos."
  )
}

fd_alpha <- FD::dbFD(
  x = rasgos_abrev,
  a = as.matrix(abund_site),
  calc.FRic = TRUE,
  corr = "cailliez",
  stand.x = TRUE,
  w.abun = TRUE,
  messages = FALSE
)

tabla_fd_indices <- data.frame(
  Sitio = rownames(abund_site),
  Riqueza_especies = riqueza_por_sitio,
  FRic = fd_alpha$FRic,
  FEve = fd_alpha$FEve,
  FDiv = fd_alpha$FDiv,
  FDis = fd_alpha$FDis,
  RaoQ = fd_alpha$RaoQ,
  row.names = NULL
)

guardar_tabla_excel(tabla_fd_indices, "tabla_04_indices_FD_alpha.xlsx")

p_fric <- ggplot2::ggplot(
  tabla_fd_indices,
  ggplot2::aes(x = stats::reorder(Sitio, FRic), y = FRic)
) +
  ggplot2::geom_col(fill = "#4A79C5") +
  ggplot2::coord_flip() +
  ggplot2::labs(
    x = "Sitio",
    y = "FRic",
    title = "Riqueza funcional (FRic) por sitio"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_fric, "fig_01_FRic_por_sitio.png", width = 8, height = 7)

p_fdis <- ggplot2::ggplot(
  tabla_fd_indices,
  ggplot2::aes(x = stats::reorder(Sitio, FDis), y = FDis)
) +
  ggplot2::geom_col(fill = "#2A9D8F") +
  ggplot2::coord_flip() +
  ggplot2::labs(
    x = "Sitio",
    y = "FDis",
    title = "Dispersión funcional (FDis) por sitio"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_fdis, "fig_02_FDis_por_sitio.png", width = 8, height = 7)

# ---------------------------------------------------------
# 4. Agregar por zonas para análisis comparativos de ensamblajes
# ---------------------------------------------------------

# A partir de este punto el análisis cambia de escala:
# ya no se trabaja a nivel alfa por sitio, sino con ensamblajes
# agregados por zona para comparar patrones regionales FD/PD.
biol_zona <- preparar_biol_zona(taxas)
if (is.null(biol_zona) || nrow(biol_zona) == 0 || ncol(biol_zona) == 0) {
  stop("La matriz de abundancia agregada por zona quedó vacía.")
}

# Eliminar zonas sin abundancia total.
zonas_validas <- rowSums(biol_zona, na.rm = TRUE) > 0
if (!all(zonas_validas)) {
  biol_zona <- biol_zona[zonas_validas, , drop = FALSE]
}

if (nrow(biol_zona) == 0) {
  stop("No quedaron zonas con abundancia positiva para los análisis comparativos.")
}

guardar_tabla_excel(as.data.frame(biol_zona), "tabla_05_abundancia_por_zona.xlsx")

# ---------------------------------------------------------
# 5. Distancias funcionales y filogenéticas
# ---------------------------------------------------------

# Para comparar FD y PD entre zonas se restringen ambas dimensiones
# al conjunto común de especies que poseen rasgos y posición en el árbol.
rasgos_lat <- matriz_fd(rasgos_fd)

if (is.null(rasgos_lat) || nrow(rasgos_lat) == 0) {
  stop("La matriz funcional con nombres científicos quedó vacía.")
}

sp_rasgos <- rownames(rasgos_lat)
sp_abund  <- colnames(biol_zona)
sp_arbol  <- arbol_filo_alfa$tip.label

sp_comunes <- Reduce(intersect, list(sp_abund, sp_rasgos, sp_arbol))

if (length(sp_comunes) < 3) {
  stop(
    "Hay menos de 3 especies comunes entre abundancias zonales, rasgos y árbol filogenético. " ,
    "No es posible realizar comparaciones FD/PD de forma robusta."
  )
}

rasgos_zona <- rasgos_lat[sp_comunes, , drop = FALSE]
biol_zona_comp <- biol_zona[, sp_comunes, drop = FALSE]
arbol_PD <- ape::keep.tip(arbol_filo_alfa, sp_comunes)

if (!identical(colnames(biol_zona_comp), rownames(rasgos_zona))) {
  stop("La matriz zonal de abundancias y la matriz de rasgos no quedaron alineadas en el mismo orden.")
}

if (!identical(colnames(biol_zona_comp), arbol_PD$tip.label)) {
  # Reordenar explícitamente según el árbol para evitar errores silenciosos.
  biol_zona_comp <- biol_zona_comp[, arbol_PD$tip.label, drop = FALSE]
  rasgos_zona <- rasgos_zona[arbol_PD$tip.label, , drop = FALSE]
}

if (!identical(colnames(biol_zona_comp), rownames(rasgos_zona)) ||
    !identical(colnames(biol_zona_comp), arbol_PD$tip.label)) {
  stop("No fue posible alinear exactamente abundancias, rasgos y árbol filogenético.")
}

fd_dist <- as.matrix(FD::gowdis(rasgos_zona))
pd_dist <- ape::cophenetic.phylo(arbol_PD)

if (!identical(rownames(fd_dist), colnames(biol_zona_comp))) {
  stop("La matriz de distancias funcionales no coincide con el orden de especies de la matriz zonal.")
}

if (!identical(rownames(pd_dist), colnames(biol_zona_comp))) {
  stop("La matriz de distancias filogenéticas no coincide con el orden de especies de la matriz zonal.")
}

# ---------------------------------------------------------
# 6. Descomposición de Rao para FD y PD
# ---------------------------------------------------------

# Rao resume diversidad basada en disimilitudes; no es equivalente
# a dbFD ni a iNEXT.3D, sino una descomposición complementaria.
rao_out <- Rao(
  sample = as.data.frame(biol_zona_comp),
  dfunc = fd_dist,
  dphyl = pd_dist,
  weight = FALSE,
  Jost = FALSE,
  structure = NULL
)

tabla_rao_fd <- resumen_rao(rao_out$FD, "FD")
tabla_rao_pd <- resumen_rao(rao_out$PD, "PD")

guardar_tabla_excel(tabla_rao_fd, "tabla_06_Rao_FD_resumen.xlsx")
guardar_tabla_excel(tabla_rao_pd, "tabla_07_Rao_PD_resumen.xlsx")

# ---------------------------------------------------------
# 7. iNEXT.3D para FD
# ---------------------------------------------------------

# En iNEXT.3D la diversidad funcional se estandariza por cobertura
# para hacer comparaciones entre ensamblajes zonales con distinto esfuerzo.
res_fd_3d <- iNEXT.3D::iNEXT3D(
  data = t(biol_zona_comp),
  diversity = "FD",
  datatype = "abundance",
  q = c(0, 1, 2),
  FDdistM = fd_dist,
  FDtype = "AUC",
  FDcut_number = 10
)

guardar_tabla_excel(as.data.frame(res_fd_3d$DataInfo), "tabla_08_iNEXT3D_FD_datainfo.xlsx")
guardar_tabla_excel(as.data.frame(res_fd_3d$AsyEst), "tabla_09_iNEXT3D_FD_asyest.xlsx")

p_fd_cov <- iNEXT.3D::ggiNEXT3D(res_fd_3d, type = 3, facet.var = "Assemblage") +
  ggplot2::labs(
    x = "Cobertura",
    y = "Diversidad funcional",
    title = "iNEXT.3D funcional basado en cobertura"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_fd_cov, "fig_03_iNEXT3D_FD_coverage.png", width = 8, height = 5)

# ---------------------------------------------------------
# 8. iNEXT.3D para PD
# ---------------------------------------------------------

# Para facilitar la comparación entre dimensiones, PD se calcula sobre
# el mismo conjunto común de especies usado en FD y Rao.
res_pd_3d <- iNEXT.3D::iNEXT3D(
  data = t(biol_zona_comp),
  diversity = "PD",
  datatype = "abundance",
  q = c(0, 1, 2),
  PDtree = arbol_PD,
  PDtype = "meanPD"
)

guardar_tabla_excel(as.data.frame(res_pd_3d$DataInfo), "tabla_10_iNEXT3D_PD_datainfo.xlsx")
guardar_tabla_excel(as.data.frame(res_pd_3d$AsyEst), "tabla_11_iNEXT3D_PD_asyest.xlsx")

p_pd_cov <- iNEXT.3D::ggiNEXT3D(res_pd_3d, type = 3, facet.var = "Assemblage") +
  ggplot2::labs(
    x = "Cobertura",
    y = "Diversidad filogenética",
    title = "iNEXT.3D filogenético basado en cobertura"
  ) +
  ggplot2::theme_bw()

guardar_figura(p_pd_cov, "fig_04_iNEXT3D_PD_coverage.png", width = 8, height = 5)

message(
  "Caso A completado. Se generaron salidas alfa por sitio y comparaciones FD/PD por ensamblajes zonales. ",
  "Revise outputs/figuras y outputs/tablas."
)
