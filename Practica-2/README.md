# Práctica 2 — ALU RISC-V de 32 bits

Diseño y simulación en VHDL de una unidad aritmética lógica de 32 bits compatible con el subconjunto RV32I de RISC-V. Implementa dieciséis operaciones (ADD, SUB, AND, OR, XOR, NOR, SLL, SRL, SRA, SLLI, SRLI, SRAI, SLT, SLTU, LUI, AUIPC) y produce las cuatro banderas de estado: Zero, CarryOut, Overflow y Sign.

La verificación se realizó mediante un banco de pruebas con 23 vectores en Active-HDL, cubriendo todas las operaciones más casos borde (cero, valores extremos y desbordamientos).

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `alu32.vhd` | Implementación de la ALU. |
| `tb_alu32.vhd` | Banco de pruebas con 23 vectores. |
| `imagenes/` | Capturas de las formas de onda obtenidas en Active-HDL. |
| `Reporte_Practica2.pdf` | Reporte técnico de la práctica. |
| `tex/` | Código fuente LaTeX del reporte. |

## Compilar el reporte

Desde la carpeta `tex/`:
```
pdflatex main.tex
pdflatex main.tex
```
