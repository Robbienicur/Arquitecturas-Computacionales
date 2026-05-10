library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ROM de instrucciones del programa Snake en RV32I (256 palabras de
-- 32 bits, indexada por el PC). El codigo fuente comentado vive en
-- asm/snake.S y se hand-encodeo a hex en este arreglo.
entity instr_rom is
generic (
    addr_width : integer := 8
);
port (
    addr  : in  std_logic_vector(31 downto 0);
    instr : out std_logic_vector(31 downto 0)
);
end entity instr_rom;

architecture simple of instr_rom is

    type rom_type is array (0 to (2**addr_width)-1)
        of std_logic_vector(31 downto 0);

    constant rom_data : rom_type := (
        -- Inicializacion
        0  => x"20000e37",   -- lui  x28, 0x20000      ; x28 = MMIO base
        1  => x"00400513",   -- addi x10, x0, 4        ; head_x = 4
        2  => x"00400593",   -- addi x11, x0, 4        ; head_y = 4
        3  => x"00100793",   -- addi x15, x0, 1        ; dir = 1 (RIGHT)
        4  => x"00600613",   -- addi x12, x0, 6        ; food_x = 6
        5  => x"00200693",   -- addi x13, x0, 2        ; food_y = 2
        6  => x"00000713",   -- addi x14, x0, 0        ; score = 0

        -- main_loop (PC=0x1C): leer SW(3:0) y actualizar dir
        7  => x"000e2883",   -- lw   x17, 0(x28)       ; x17 = switches

        -- SW(0) -> dir = UP (0)
        8  => x"0018f913",   -- andi x18, x17, 1
        9  => x"00090463",   -- beq  x18, x0, +8
        10 => x"00000793",   -- addi x15, x0, 0

        -- SW(1) -> dir = RIGHT (1)
        11 => x"0028f913",   -- andi x18, x17, 2
        12 => x"00090463",   -- beq  x18, x0, +8
        13 => x"00100793",   -- addi x15, x0, 1

        -- SW(2) -> dir = DOWN (2)
        14 => x"0048f913",   -- andi x18, x17, 4
        15 => x"00090463",   -- beq  x18, x0, +8
        16 => x"00200793",   -- addi x15, x0, 2

        -- SW(3) -> dir = LEFT (3)
        17 => x"0088f913",   -- andi x18, x17, 8
        18 => x"00090463",   -- beq  x18, x0, +8
        19 => x"00300793",   -- addi x15, x0, 3

        -- Mover la cabeza segun dir
        -- if dir == 0: head_y -= 1
        20 => x"00079663",   -- bne  x15, x0, +12
        21 => x"fff58593",   -- addi x11, x11, -1
        22 => x"0280006f",   -- jal  x0, after_move

        -- if dir == 1: head_x += 1
        23 => x"00100993",   -- addi x19, x0, 1
        24 => x"01379663",   -- bne  x15, x19, +12
        25 => x"00150513",   -- addi x10, x10, 1
        26 => x"0180006f",   -- jal  x0, after_move

        -- if dir == 2: head_y += 1
        27 => x"00200993",   -- addi x19, x0, 2
        28 => x"01379663",   -- bne  x15, x19, +12
        29 => x"00158593",   -- addi x11, x11, 1
        30 => x"0080006f",   -- jal  x0, after_move

        -- else (dir == 3): head_x -= 1
        31 => x"fff50513",   -- addi x10, x10, -1

        -- after_move (PC=0x80): wrap-around y comparacion con la comida
        32 => x"00757513",   -- andi x10, x10, 7       ; head_x &= 7
        33 => x"0075f593",   -- andi x11, x11, 7       ; head_y &= 7
        34 => x"00c51e63",   -- bne  x10, x12, no_eat
        35 => x"00d59c63",   -- bne  x11, x13, no_eat

        -- Comio: subir score y reubicar comida
        36 => x"00170713",   -- addi x14, x14, 1       ; score++
        37 => x"00360613",   -- addi x12, x12, 3       ; food_x += 3
        38 => x"00767613",   -- andi x12, x12, 7
        39 => x"00568693",   -- addi x13, x13, 5       ; food_y += 5
        40 => x"0076f693",   -- andi x13, x13, 7

        -- no_eat (PC=0xA4): publicar estado a la VRAM
        41 => x"30000eb7",   -- lui  x29, 0x30000      ; x29 = VRAM base
        42 => x"00aea023",   -- sw   x10, 0(x29)       ; head_x
        43 => x"00bea223",   -- sw   x11, 4(x29)       ; head_y
        44 => x"00cea423",   -- sw   x12, 8(x29)       ; food_x
        45 => x"00dea623",   -- sw   x13, 12(x29)      ; food_y
        46 => x"00eea823",   -- sw   x14, 16(x29)      ; score

        -- Score en LEDs (4 bits bajos)
        47 => x"00f77b13",   -- andi x22, x14, 15
        48 => x"016e2423",   -- sw   x22, 8(x28)

        -- Delay (~210 ms a 50 MHz)
        49 => x"00500b37",   -- lui  x22, 0x500
        50 => x"fffb0b13",   -- addi x22, x22, -1
        51 => x"fe0b1ee3",   -- bne  x22, x0, -4

        -- Volver al inicio del loop
        52 => x"f4dff06f",   -- jal  x0, main_loop

        others => x"00000013"  -- NOP (ADDI x0, x0, 0)
    );

    signal idx : integer range 0 to (2**addr_width)-1;

begin

    -- Direccion en bytes; las instrucciones son palabras de 4 bytes.
    idx <= to_integer(unsigned(addr(addr_width+1 downto 2)));
    instr <= rom_data(idx);

end architecture simple;
