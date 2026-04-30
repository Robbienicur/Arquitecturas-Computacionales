# Práctica 3 — Memorias ROM y RAM para la Tarjeta PYNQ Z1

Diseño y simulación en VHDL de dos memorias síncronas pensadas para el SoC Zynq 7000 de la tarjeta PYNQ Z1: una ROM de 16 bits con cumpleaños de compañeros del curso (formato BCD) y una RAM de 32 bits para almacenar fechas de nacimiento (formato DDMMYYYY). Ambas memorias siguen los patrones recomendados por Xilinx para inferir bloques BRAM.

El reporte discute además el uso de memorias ROM como almacén de programas RV32I, presentando la codificación de tres ejercicios de la Tarea 3: cálculo de `(a+b)*c`, factorial de cinco y detección de paridad.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `rom_cumpleanos.vhd` | ROM síncrona de 16 bits, 16 posiciones, con datos de cumpleaños BCD. |
| `ram_fechas.vhd` | RAM síncrona de un puerto, 32 bits, 16 posiciones. |
| `tb_memorias.vhd` | Banco de pruebas que ejercita ambas memorias. |
| `imagenes/` | Capturas de las formas de onda obtenidas en Active-HDL. |
| `Reporte_Practica3.pdf` | Reporte técnico de la práctica. |
| `tex/` | Código fuente LaTeX del reporte. |

## Compilar el reporte

Desde la carpeta `tex/`:
```
pdflatex main.tex
pdflatex main.tex
```
