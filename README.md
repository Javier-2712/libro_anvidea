# ANVIDEA — Material reproducible

Repositorio oficial de materiales reproducibles asociados al libro:

**“Análisis y Visualización de Datos Ecológicos y Ambientales — ANVIDEA”**

Este repositorio está diseñado para que estudiantes, docentes e investigadores puedan:

- Reproducir los análisis presentados en el libro  
- Explorar los datos utilizados en los casos guiados  
- Ejecutar scripts organizados por unidades y capítulos  
- Adaptar los flujos de trabajo a sus propios datos  

---



## 📁 Estructura general

El repositorio se organiza en tres unidades:

- **Unidad I   — Análisis de datos ecológicos**
- **Unidad II  — Ecología de poblaciones**
- **Unidad III — Ecología de comunidades**

Cada unidad contiene:

- `README.md` → descripción de la unidad  
- `run_unidadX.R` → ejecución completa de la unidad  
- carpetas por capítulo  

Cada capítulo contiene:

- `README.md` → explicación del contenido  
- `R/` → scripts del análisis  
- `data/raw/` → datos de entrada  
- `outputs/figuras/` → gráficos generados  
- `outputs/tablas/` → tablas exportadas  

---

## ▶️ Cómo usar este material

Este repositorio contiene los materiales reproducibles del libro ANVIDEA.

Los códigos en R no se ejecutan directamente desde GitHub ni desde el portal web.

👉 Este material está diseñado para ser utilizado en un entorno local (RStudio o Quarto).

Para trabajar con el contenido:

1. Descarga el repositorio (ZIP) o clónalo  
2. Descomprímelo en tu computador  
3. Abre la carpeta en RStudio  
4. Ejecuta los scripts desde R  


### Opción 1 — Ejecutar el material por unidad

```r
source("unidad_i/run_unidad1.R")
source("unidad_ii/run_unidad2.R")
source("unidad_iii/run_unidad3.R")
```

### Opción 2 — Ejecutar el material por capítulo

Ubícate dentro del capítulo y ejecuta:

```r
source("R/00_setup.R")
source("R/01_casoA_*.R")
```

---

## 📊 Datos

Cada capítulo incluye sus propios datos en:

```text
data/raw/
```

Estos archivos deben mantenerse sin modificaciones para garantizar la reproducibilidad.

---

## 📤 Salidas

Los resultados generados por los scripts se almacenan en:

- `outputs/figuras/`
- `outputs/tablas/`

---

## 🌐 Portal web

Puedes explorar este material de forma estructurada en la página del proyecto:

👉 *[Ir a enlace ANVIDEA](https://javier-2712.github.io/libro_anvidea/)*

---

## 🧠 Enfoque pedagógico

El repositorio sigue la misma lógica del libro:

1. **Unidad I** → manipulación y exploración de datos  
2. **Unidad II** → dinámica y estructura poblacional  
3. **Unidad III** → diversidad y organización de comunidades  

---

## ⚠️ Recomendaciones

- Ejecutar los scripts en el orden sugerido  
- No modificar los nombres de archivos de datos  
- Verificar que los paquetes requeridos estén instalados  

---

## 👨‍🏫 Autores

**Javier Rodríguez-Barrios**  
**Kenedith Méndez**  
**Javier de la Hoz**

---

## 📄 Licencia

Este proyecto distingue entre el código y los contenidos académicos:

- 💻 Código en R: Licenciado bajo MIT License
- 📘 Contenidos del libro y material pedagógico: Licenciados bajo Creative Commons CC BY-NC 4.0

Esto permite la reutilización académica y docente del material, evitando su uso comercial sin autorización del autor.

---

## 🚀 Estado del proyecto

✔ Estructura base implementada  
✔ Scripts organizados por unidades  
✔ Material listo para uso educativo y reproducible  
