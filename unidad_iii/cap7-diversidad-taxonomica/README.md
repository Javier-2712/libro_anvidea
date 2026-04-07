# 🌿 Capítulo 7 — Diversidad taxonómica

Este capítulo desarrolla herramientas para analizar la biodiversidad desde una perspectiva taxonómica, integrando enfoques clásicos y modernos.

---

## 🎯 Contenido

Incluye:

- Diversidad alfa:
  - Riqueza (q = 0)
  - Diversidad de Shannon (q = 1)
  - Diversidad de Simpson (q = 2)

- Curvas rango–abundancia (RAD)

- Diversidad beta:
  - Índice de Jaccard
  - Diferenciación entre ensamblajes

- Contribuciones locales a la diversidad beta (LCBD)

---

## 📁 Estructura

```text
cap7-diversidad-taxonomica/
│
├── R/
│   ├── 00_setup.R
│   ├── 01_casoA_TD_alfa_y_Hill.R
│   ├── 02_casoB_TD_beta_y_recambio.R
│   └── 03_funciones_auxiliares.R
│
├── data/
│   └── raw/
│       └── datos.c7.xlsx
│
├── outputs/
│   ├── figuras/
│   └── tablas/
│
├── README.md
└── NOTAS_MIGRACION.md
```

---

## 🔬 Enfoque metodológico

Este capítulo combina:

- enfoques clásicos de diversidad (Whittaker)
- números efectivos de Hill (q = 0, 1, 2)
- métricas de beta diversidad
- análisis de contribución local (LCBD)

---

## 📖 Relación con el siguiente capítulo

Los resultados obtenidos aquí se extienden en el Capítulo 8, donde la diversidad se analiza incorporando:

- rasgos funcionales (FD)
- relaciones evolutivas (PD)