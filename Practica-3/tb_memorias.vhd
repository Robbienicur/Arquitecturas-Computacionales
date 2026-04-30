library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_memorias is
end entity tb_memorias;

architecture simple of tb_memorias is

constant addr_width : integer := 4;
constant CLK_PERIOD : time := 10 ns;

signal clk : std_logic := '0';

signal cump_addr     : std_logic_vector(addr_width-1 downto 0) := (others => '0');
signal cump_data_out : std_logic_vector(15 downto 0);

signal ram_we       : std_logic := '0';
signal ram_addr     : std_logic_vector(addr_width-1 downto 0) := (others => '0');
signal ram_data_in  : std_logic_vector(31 downto 0) := (others => '0');
signal ram_data_out : std_logic_vector(31 downto 0);

begin

uut_cumpleanos: entity work.rom_cumpleanos
generic map (addr_width => addr_width, data_width => 16)
port map (
    clk      => clk,
    addr     => cump_addr,
    data_out => cump_data_out
);

uut_ram_fechas: entity work.ram_fechas
generic map (addr_width => addr_width, data_width => 32)
port map (
    clk      => clk,
    we       => ram_we,
    addr     => ram_addr,
    data_in  => ram_data_in,
    data_out => ram_data_out
);

clk_process: process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

stim: process
begin
    wait for CLK_PERIOD;

    for i in 0 to 15 loop
        cump_addr <= std_logic_vector(to_unsigned(i, addr_width));
        wait for CLK_PERIOD;
    end loop;
    cump_addr <= (others => '0');

    ram_we <= '1';
    ram_addr <= "0000";
    ram_data_in <= x"15052003";
    wait for CLK_PERIOD;

    ram_addr <= "0001";
    ram_data_in <= x"22082002";
    wait for CLK_PERIOD;

    ram_addr <= "0101";
    ram_data_in <= x"07122003";
    wait for CLK_PERIOD;

    ram_addr <= "1010";
    ram_data_in <= x"14112002";
    wait for CLK_PERIOD;

    ram_addr <= "1111";
    ram_data_in <= x"30012004";
    wait for CLK_PERIOD;

    ram_we <= '0';
    ram_data_in <= (others => '0');

    for i in 0 to 15 loop
        ram_addr <= std_logic_vector(to_unsigned(i, addr_width));
        wait for CLK_PERIOD;
    end loop;
    ram_addr <= (others => '0');

    wait for 2*CLK_PERIOD;
    wait;
end process;

end architecture simple;
