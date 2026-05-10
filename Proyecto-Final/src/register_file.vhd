library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Banco de 32 registros de 32 bits con dos puertos de lectura asincrona
-- y un puerto de escritura sincrona. Escribir a x0 no tiene efecto.
entity register_file is
port (
    clk : in  std_logic;
    we  : in  std_logic;
    rs1 : in  std_logic_vector(4 downto 0);
    rs2 : in  std_logic_vector(4 downto 0);
    rd  : in  std_logic_vector(4 downto 0);
    wd  : in  std_logic_vector(31 downto 0);
    rd1 : out std_logic_vector(31 downto 0);
    rd2 : out std_logic_vector(31 downto 0)
);
end entity register_file;

architecture simple of register_file is

    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => x"00000000");

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and rd /= "00000" then
                regs(to_integer(unsigned(rd))) <= wd;
            end if;
        end if;
    end process;

    rd1 <= x"00000000" when rs1 = "00000"
           else regs(to_integer(unsigned(rs1)));

    rd2 <= x"00000000" when rs2 = "00000"
           else regs(to_integer(unsigned(rs2)));

end architecture simple;
