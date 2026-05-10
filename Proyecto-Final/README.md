# RV-Snake — Procesador RISC-V single-cycle ejecutando Snake sobre DE10-Lite

Proyecto final del curso **P26-LIS2022-1 Arquitecturas Computacionales** (UDLAP, Primavera 2026).

Una CPU RISC-V (subconjunto RV32I) implementada en VHDL, ejecutando un programa de Snake desde una ROM interna. La CPU lee los switches de la DE10-Lite para mover la serpiente y publica el estado del juego en una region memory-mapped que un periferico VGA hecho a mano lee directamente y pinta en un monitor conectado a la tarjeta. **No hay PC, no hay UART, no hay software de visualizacion**: la tarjeta y el monitor son todo.

El procesador reusa los bloques que se construyeron a lo largo del semestre (ALU de la Practica 2, patron de ROM/RAM sincronas de la Practica 3, FSMs estilo Practica 4 para el generador de timing VGA).

## Demo

| | |
|---|---|
| **Tarjeta** | Terasic DE10-Lite (Intel MAX 10 - 10M50DAF484C7G) |
| **Reloj** | 50 MHz (oscilador de la tarjeta) |
| **Salida** | VGA 640x480 @ 60 Hz directo a monitor (cable VGA o adaptador VGA-HDMI) |
| **Score** | Mostrado en HEX1+HEX0 (hex de 8 bits) y reflejado en LEDR(3:0) |
| **Controles** | SW(0)=Arriba, SW(1)=Derecha, SW(2)=Abajo, SW(3)=Izquierda |
| **Reset** | SW(9) hacia arriba o KEY(0) presionado |

## Arquitectura

```
       +-------------------+
       |   DE10-Lite FPGA  |
       |                   |
       |  +-------------+  |        VGA        +-----------+
 SW -->|  | RV32I       |  |   ----->          |           |
       |  | single-cycle|  |   12 bits R/G/B   |  Monitor  |
 KEY-->|  | CPU + MMIO  |--|   + HSYNC/VSYNC   |  640x480  |
       |  |             |  |   ----->          |           |
       |  +------+------+  |                   +-----------+
       |         |         |
       |         v         |
       |  +-------------+  |
       |  | vga_sync +  |  |
       |  | renderer    |  |
       |  +-------------+  |
       |                   |
       |  HEX1, HEX0  <- score (hex 00..FF)
       |  LEDR(3:0)   <- score (low nibble)
       +-------------------+
```

La CPU es un single-cycle clasico con los modulos:

- `pc.vhd` — Program Counter (registro de 32 bits).
- `instr_rom.vhd` — ROM con el programa Snake hand-encodeado.
- `register_file.vhd` — banco de 32 registros de 32 bits.
- `imm_gen.vhd` — generador de inmediatos (formatos I, S, B, U, J).
- `control_unit.vhd` — decodifica opcode/funct3/funct7.
- `alu32.vhd` — ALU de 16 operaciones (reusada de la Practica 2).
- `mmio.vhd` — RAM de datos + decoder de I/O memory-mapped + registros del juego.

Periferia de salida nueva (especifica de la DE10-Lite):

- `vga_sync.vhd` — generador de timing 640x480 @ 60 Hz (FSM con contadores, estilo Practica 4).
- `vga_renderer.vhd` — lee head_x/y, food_x/y de la MMIO y pinta el tablero 8x8.
- `seven_seg.vhd` — decoder hex -> 7 segmentos para los displays HEX1 y HEX0.

`snake_top.vhd` es el top estructural que conecta todo.

### Mapa de memoria

| Rango | Acceso | Periferico |
|-------|--------|-----------|
| `0x0000_0000 .. 0x0000_03FF` | R | ROM de instrucciones (256 entradas) |
| `0x1000_0000 .. 0x1000_03FF` | R/W | RAM de datos (256 palabras) |
| `0x2000_0000` | R | switches direccionales SW(3:0) |
| `0x2000_0008` | W | LEDs (low 4 bits) |
| `0x3000_0000` | W | head_x (3 bits) |
| `0x3000_0004` | W | head_y (3 bits) |
| `0x3000_0008` | W | food_x (3 bits) |
| `0x3000_000C` | W | food_y (3 bits) |
| `0x3000_0010` | W | score (8 bits, mostrado en HEX1+HEX0) |

### Instrucciones soportadas

R-type: `ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT`
I-type: `ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI, SRAI, LW, JALR`
S-type: `SW`
B-type: `BEQ, BNE`
U-type: `LUI`
J-type: `JAL`

Es el subconjunto justo necesario para correr el programa Snake.

## Estructura del repo

```
RV-Snake/
├── src/                    # Codigo VHDL del procesador y los perifericos
│   ├── pc.vhd
│   ├── register_file.vhd
│   ├── imm_gen.vhd
│   ├── control_unit.vhd
│   ├── alu32.vhd           # copia de Practica 2
│   ├── mmio.vhd
│   ├── instr_rom.vhd       # programa Snake en hex
│   ├── data_ram.vhd        # RAM generica (auxiliar, no se instancia)
│   ├── vga_sync.vhd        # generador de timing VGA 640x480@60
│   ├── vga_renderer.vhd    # pinta el tablero 8x8
│   ├── seven_seg.vhd       # decoder hex a 7 segmentos
│   └── snake_top.vhd       # top estructural
├── asm/
│   └── snake.S             # programa Snake en assembly comentado
├── quartus/                # proyecto Quartus para la version final
│   ├── de10_lite.qpf
│   └── de10_lite.qsf
├── test/                   # proyecto Quartus de barras VGA (Hito 1)
│   ├── vga_test_top.vhd
│   ├── vga_test.qpf
│   └── vga_test.qsf
├── sim/                    # bancos de pruebas para Active-HDL
│   ├── tb_snake_top.vhd
│   └── tb_vga_sync.vhd
└── README.md
```

## Como correrlo

### 1. Validar la cadena VGA (Hito 1)

Antes de meter toda la CPU conviene confirmar que la salida VGA y el cable al monitor funcionan. El proyecto `test/vga_test.qpf` compila solo `vga_sync.vhd` y `vga_test_top.vhd` y muestra 8 barras de color en la pantalla.

1. Abrir Quartus Prime Lite, `File -> Open Project`, seleccionar `test/vga_test.qpf`.
2. Click derecho sobre `vga_test_top` en la jerarquia, "Set as Top-Level Entity".
3. `Processing -> Start Compilation`.
4. Conectar la DE10-Lite por USB y un monitor por VGA.
5. `Tools -> Programmer`, agregar `test/vga_test.sof` (o `test/output_files/vga_test.sof` segun la version de Quartus) y "Start".
6. Si en el monitor aparecen 8 barras estables (blanco, amarillo, cian, verde, magenta, rojo, azul, negro), el hardware esta listo. Si LEDR(0) parpadea, el reloj corre.

### 2. Generar el bitstream del proyecto completo

1. `File -> Open Project`, seleccionar `quartus/de10_lite.qpf`.
2. Verificar que `snake_top` es el top entity.
3. `Processing -> Start Compilation`.
4. Programar `quartus/de10_lite.sof` con el Programmer.

### 3. Jugar

1. Conectar el monitor por VGA.
2. Asegurarse que SW(9) este abajo (sin reset). KEY(0) tampoco presionado.
3. Mover SW(0..3) para cambiar la direccion de la serpiente:
   - SW(0) = Arriba
   - SW(1) = Derecha
   - SW(2) = Abajo
   - SW(3) = Izquierda
4. Cuando la cabeza pasa sobre la comida (cuadro rojo), el score sube en HEX1+HEX0.

### 4. Simulacion (Active-HDL)

- `sim/tb_vga_sync.vhd` — verifica el generador de timing VGA en aislamiento. Compilar `src/vga_sync.vhd` y este testbench.
- `sim/tb_snake_top.vhd` — corre todo el sistema unos pocos ms para ver arranque, primer paso del loop y publicacion del estado en la VRAM. Cargar todos los `src/*.vhd` y este testbench.

## Programa Snake

El juego se ejecuta en una matriz de 8x8 celdas. La cabeza se mueve un paso en la direccion seleccionada por los switches, hace wrap-around al llegar a un borde, y cuando coincide con la posicion de la comida se incrementa el score y la comida cambia de posicion. El delay entre frames es de ~210 ms.

Despues de cada paso, la CPU escribe el nuevo estado en la region MMIO 0x3000_xxxx con cinco instrucciones `sw`. El renderizador VGA lee esos registros directamente desde el hardware y los usa para decidir el color de cada pixel del cuadro siguiente.

El codigo fuente comentado del programa Snake (en RV32I) esta en `asm/snake.S`, y su version hand-encodeada a hex esta dentro de `src/instr_rom.vhd`.
