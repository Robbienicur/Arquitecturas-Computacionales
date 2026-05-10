library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- RAM de datos de 256 palabras (1 KB) direccionada por palabra.
entity data_ram is
generic (
    addr_width : integer := 8;
    data_width : integer := 32
);
port (
    clk      : in  std_logic;
    we       : in  std_logic;
    addr     : in  std_logic_vector(addr_width-1 downto 0);
    data_in  : in  std_logic_vector(data_width-1 downto 0);
    data_out : out std_logic_vector(data_width-1 downto 0)
);
end entity data_ram;

architecture simple of data_ram is

    type ram_type is array (0 to (2**addr_width)-1)
        of std_logic_vector(data_width-1 downto 0);
    signal ram : ram_type := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr))) <= data_in;
            end if;
        end if;
    end process;

    data_out <= ram(to_integer(unsigned(addr)));

end architecture simple;
