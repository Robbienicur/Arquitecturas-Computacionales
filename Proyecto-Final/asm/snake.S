# Snake en RV32I para la DE10-Lite. La CPU mueve la serpiente en una matriz
# 8x8 leyendo SW(3:0) y publica el estado en 0x3000_xxxx para que el
# renderizador VGA lo dibuje. Cada instruccion esta hand-encodeada en
# instr_rom.vhd con la misma direccion que aqui.

0x00:   lui  x28, 0x20000              # x28 = MMIO base
0x04:   addi x10, x0, 4                # head_x = 4
0x08:   addi x11, x0, 4                # head_y = 4
0x0C:   addi x15, x0, 1                # dir = 1 (RIGHT)
0x10:   addi x12, x0, 6                # food_x = 6
0x14:   addi x13, x0, 2                # food_y = 2
0x18:   addi x14, x0, 0                # score = 0

main_loop:
0x1C:   lw   x17, 0(x28)               # x17 = SW(3:0)

# SW(0) -> dir = UP (0)
0x20:   andi x18, x17, 1
0x24:   beq  x18, x0, +8
0x28:   addi x15, x0, 0

# SW(1) -> dir = RIGHT (1)
0x2C:   andi x18, x17, 2
0x30:   beq  x18, x0, +8
0x34:   addi x15, x0, 1

# SW(2) -> dir = DOWN (2)
0x38:   andi x18, x17, 4
0x3C:   beq  x18, x0, +8
0x40:   addi x15, x0, 2

# SW(3) -> dir = LEFT (3)
0x44:   andi x18, x17, 8
0x48:   beq  x18, x0, +8
0x4C:   addi x15, x0, 3

# Mover la cabeza segun dir
# UP
0x50:   bne  x15, x0, +12
0x54:   addi x11, x11, -1
0x58:   jal  x0, after_move

# RIGHT
0x5C:   addi x19, x0, 1
0x60:   bne  x15, x19, +12
0x64:   addi x10, x10, 1
0x68:   jal  x0, after_move

# DOWN
0x6C:   addi x19, x0, 2
0x70:   bne  x15, x19, +12
0x74:   addi x11, x11, 1
0x78:   jal  x0, after_move

# LEFT (default cuando dir == 3)
0x7C:   addi x10, x10, -1

after_move:
0x80:   andi x10, x10, 7               # head_x &= 7
0x84:   andi x11, x11, 7               # head_y &= 7

0x88:   bne  x10, x12, no_eat
0x8C:   bne  x11, x13, no_eat

# Comio: subir score y reubicar comida
0x90:   addi x14, x14, 1               # score++
0x94:   addi x12, x12, 3
0x98:   andi x12, x12, 7
0x9C:   addi x13, x13, 5
0xA0:   andi x13, x13, 7

no_eat:
0xA4:   lui  x29, 0x30000              # x29 = VRAM base
0xA8:   sw   x10, 0(x29)               # head_x
0xAC:   sw   x11, 4(x29)               # head_y
0xB0:   sw   x12, 8(x29)               # food_x
0xB4:   sw   x13, 12(x29)              # food_y
0xB8:   sw   x14, 16(x29)              # score

# Score en LEDs (4 bits bajos)
0xBC:   andi x22, x14, 15
0xC0:   sw   x22, 8(x28)

# Delay (~210 ms a 50 MHz)
0xC4:   lui  x22, 0x500
delay:
0xC8:   addi x22, x22, -1
0xCC:   bne  x22, x0, -4

0xD0:   jal  x0, main_loop
