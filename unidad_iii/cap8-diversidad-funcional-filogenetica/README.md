# 🌳 Capítulo 8 — Diversidad funcional y filogenética

Este capítulo extiende el análisis de la biodiversidad más allá de la identidad de las especies, incorporando sus **rasgos ecológicos** y su **historia evolutiva**.

---

## 🎯 Contenido

Incluye:

- Diversidad funcional (FD):
  - CWM (Community Weighted Means)
  - índices funcionales (FRic, FEve, FDiv, FDis, RaoQ)

- Diversidad filogenética (PD):
  - distancias evolutivas
  - métricas basadas en árboles

- Descomposición de diversidad:
  - α, β y γ mediante entropía de Rao

- Rarefacción y extrapolación:
  - iNEXT.3D (FD y PD)
  - iNEXTbeta3D (diversidad beta)

- Alineación entre:
  - matrices de abundancia
  - rasgos funcionales
  - árboles filogenéticos

---

## 📁 Estructura

```text
cap8-diversidad-funcional-filogenetica/
│
├── R/
│   ├── 00_setup.R
│   ├── 01_casoA_FD_PD_alfa.R
│   ├── 02_casoB_PD_beta_y_alineacion.R
│   ├── 03_casoC_FD_beta.R
│   ├── 04_funciones_auxiliares.R
│   ├── 05_alineador.R
│   └── 06_Rao.R
│
├── data/
│   └── raw/
│       ├── datos.c8.xlsx
│       ├── arbol_filo_alfa.rds
│       └── arbol_filo_beta.rds
│
├── outputs/
│   ├── figuras/
│   └── tablas/
│
├── README.md
└── NOTAS_MIGRACION.md
```
