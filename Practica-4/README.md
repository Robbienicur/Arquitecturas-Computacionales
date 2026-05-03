# Práctica 4 — Máquinas de Estado Finito (Control Unit)

Diseño y simulación en VHDL de tres máquinas de estado finito: dos detectores de la secuencia binaria `101` (uno tipo Mealy y otro tipo Moore) y una FSM para un semáforo de doble vía con cruce peatonal.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `mealy_101.vhd` | FSM tipo Mealy con tres estados que detecta la secuencia `101`. |
| `moore_101.vhd` | FSM tipo Moore con cuatro estados que detecta la misma secuencia. |
| `fsm_semaforo.vhd` | FSM de seis estados (codificación *one-hot*) que controla las luces del semáforo. |
| `imagenes/` | Capturas de las formas de onda obtenidas en Active-HDL. |
| `tex/` | Código fuente LaTeX del reporte. |

## Compilar el reporte

Desde la carpeta `tex/`:
```
pdflatex main.tex
pdflatex main.tex
```
