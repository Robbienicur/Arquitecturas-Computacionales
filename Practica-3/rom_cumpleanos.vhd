library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_cumpleanos is
generic (
    addr_width : integer := 4;
    data_width : integer := 16
);
port (
    clk      : in  std_logic;
    addr     : in  std_logic_vector(addr_width-1 downto 0);
    data_out : out std_logic_vector(data_width-1 downto 0)
);
end entity rom_cumpleanos;

architecture simple of rom_cumpleanos is

    type rom_type is array (0 to (2**addr_width)-1)
        of std_logic_vector(data_width-1 downto 0);

    constant rom_data : rom_type := (
        0  => x"1505",
        1  => x"2208",
        2  => x"0712",
        3  => x"3001",
        4  => x"1411",
        5  => x"0904",
        6  => x"1806",
        7  => x"0211",
        8  => x"2503",
        9  => x"1207",
        10 => x"0509",
        11 => x"2802",
        12 => x"0000",
        13 => x"0000",
        14 => x"0000",
        15 => x"0000"
    );

    signal rom_aux : std_logic_vector(data_width-1 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            rom_aux <= rom_data(to_integer(unsigned(addr)));
        end if;
    end process;

    data_out <= rom_aux;

end architecture simple;
