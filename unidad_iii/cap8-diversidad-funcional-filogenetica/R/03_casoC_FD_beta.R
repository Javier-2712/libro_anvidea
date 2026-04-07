# =========================================================
# ANVIDEA - Unidad III
# Capítulo 8 - Diversidad funcional y filogenética
# Archivo: 03_casoC_FD_beta_final.R
# Propósito: estimar diversidad beta funcional por pares de zonas
# =========================================================

source("R/00_setup.R")
source("R/04_funciones_auxiliares.R")

datos_path <- file.path(data_dir, "datos.c8.xlsx")
if (!file.exists(datos_path)) stop("No se encontró el archivo: ", datos_path)

taxas  <- leer_tax_c8(data_dir)
rasgos <- leer_rasgos_c8(data_dir)

# ---------------------------------------------------------
# 1. Preparar abundancias por zonas
# ---------------------------------------------------------

biol_zona <- preparar_biol_zona(taxas)
zona_esperadas <- c("M", "P", "RM")

if (!all(zona_esperadas %in% rownames(biol_zona))) {
  stop("Faltan zonas esperadas: ", paste(zona_esperadas, collapse = ", "))
}

biol_zone_sp <- t(as.matrix(biol_zona[zona_esperadas, , drop = FALSE]))

# ---------------------------------------------------------
# 2. Preparar rasgos funcionales
# ---------------------------------------------------------

rasgos_fd  <- preparar_rasgos_fd(rasgos)
rasgos_lat <- matriz_fd(rasgos_fd)

if (any(is.na(rasgos_lat))) {
  stop("Existen valores NA en la matriz de rasgos.")
}

spp_fd <- intersect(rownames(rasgos_lat), rownames(biol_zone_sp))
if (length(spp_fd) < 2) stop("Muy pocas especies en común.")

rasgos_lat  <- rasgos_lat[spp_fd, , drop = FALSE]
biol_zone_sp <- biol_zone_sp[spp_fd, , drop = FALSE]

# eliminar especies con abundancia cero
biol_zone_sp <- biol_zone_sp[rowSums(biol_zone_sp) > 0, , drop = FALSE]
rasgos_lat   <- rasgos_lat[rownames(biol_zone_sp), , drop = FALSE]

# ---------------------------------------------------------
# 3. Construir pares
# ---------------------------------------------------------

biol_FD_beta <- list(
  M_vs_P  = biol_zone_sp[, c("M","P")],
  M_vs_RM = biol_zone_sp[, c("M","RM")],
  P_vs_RM = biol_zone_sp[, c("P","RM")]
)

# ---------------------------------------------------------
# 4. Distancias funcionales
# ---------------------------------------------------------

biol.dist.beta <- as.matrix(FD::gowdis(rasgos_lat))

# ---------------------------------------------------------
# 5. iNEXTbeta3D coverage
# ---------------------------------------------------------

salida_fd_cov <- iNEXTbeta3D::iNEXTbeta3D(
  data = biol_FD_beta,
  diversity = "FD",
  datatype = "abundance",
  base = "coverage",
  nboot = 10,
  FDdistM = biol.dist.beta,
  FDtype = "AUC"
)

# ---------------------------------------------------------
# 6. iNEXTbeta3D size
# ---------------------------------------------------------

salida_fd_size <- iNEXTbeta3D::iNEXTbeta3D(
  data = biol_FD_beta,
  diversity = "FD",
  datatype = "abundance",
  base = "size",
  nboot = 10,
  FDdistM = biol.dist.beta,
  FDtype = "AUC"
)

message("Script FD beta final listo.")
