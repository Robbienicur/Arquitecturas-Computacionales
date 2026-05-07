library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port (
        clk : in  STD_LOGIC;
        we  : in  STD_LOGIC;                       -- Write Enable
        rs1 : in  STD_LOGIC_VECTOR(4 downto 0);    -- Registro fuente 1
        rs2 : in  STD_LOGIC_VECTOR(4 downto 0);    -- Registro fuente 2
        rd  : in  STD_LOGIC_VECTOR(4 downto 0);    -- Registro destino
        wd  : in  STD_LOGIC_VECTOR(31 downto 0);   -- Datos a escribir (Write Data)
        rd1 : out STD_LOGIC_VECTOR(31 downto 0);   -- Salida dato 1
        rd2 : out STD_LOGIC_VECTOR(31 downto 0)    -- Salida dato 2
    );
end entity Register_File;

architecture Behavioral of Register_File is
type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
signal rf : reg_array := (
    1   => x"00000005", -- x1 = A (5)
    2   => x"0000000A", -- x2 = B (10)
    3   => x"00000002", -- x3 = C (2)
    others => (others => '0') -- El resto (incluyendo x0) inicia en 0
);
begin
    -- Lectura Asíncrona (Combinacional)
    -- Si rs1 o rs2 es 0, la salida debe ser 0 (estándar RISC-V)
    rd1 <= rf(to_integer(unsigned(rs1))) when (rs1 /= "00000") else (others => '0');
    rd2 <= rf(to_integer(unsigned(rs2))) when (rs2 /= "00000") else (others => '0');

    -- Escritura Síncrona (En el flanco de subida del reloj)
    process(clk)
    begin
        if rising_edge(clk) then
            -- Solo escribimos si 'we' está activo y el destino no es x0
            if (we = '1' and rd /= "00000") then
                rf(to_integer(unsigned(rd))) <= wd;
            end if;
        end if;
    end process;

end Behavioral;
