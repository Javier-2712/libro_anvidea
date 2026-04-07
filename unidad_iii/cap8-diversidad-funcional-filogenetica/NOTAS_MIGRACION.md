# Notas de migración

- Se retiraron bloques editoriales y de maquetación propios de Quarto.
- Se conservaron los flujos analíticos centrales del capítulo:
  - CWM y métricas clásicas de FD con `dbFD`
  - descomposición con Rao para FD y PD
  - iNEXT.3D para FD y PD
  - iNEXTbeta3D para PD y FD beta
- Se separaron las utilidades especializadas en dos módulos independientes:
  - `05_alineador.R`
  - `06_Rao.R`
- Las salidas se estandarizaron en `outputs/figuras` y `outputs/tablas`.
