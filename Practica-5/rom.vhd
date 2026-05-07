library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- programa: A*B + C   (con A=5, B=10, C=2 -> resultado = 52 = 0x34)

entity rom is
    Port (
        addr  : in  STD_LOGIC_VECTOR(31 downto 0);
        instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity rom;

architecture arch of rom is
    type rom_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal rom : rom_type := (
        0 => x"02208233", -- mul x4, x1, x2   -> x4 = A*B
        1 => x"00320233", -- add x4, x4, x3   -> x4 = (A*B) + C
        2 => x"0000006F", -- jal x0, 0  (loop)
        others => x"00000000"
    );
begin
    instr <= rom(to_integer(unsigned(addr(7 downto 2))));
end;
