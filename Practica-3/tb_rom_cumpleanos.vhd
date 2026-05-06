library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_rom_cumpleanos is
end entity tb_rom_cumpleanos;

architecture simple of tb_rom_cumpleanos is

constant addr_width : integer := 4;
constant data_width : integer := 16;
constant CLK_PERIOD : time := 10 ns;

signal clk      : std_logic := '0';
signal addr     : std_logic_vector(addr_width-1 downto 0) := (others => '0');
signal data_out : std_logic_vector(data_width-1 downto 0);

begin

uut: entity work.rom_cumpleanos
generic map (addr_width => addr_width, data_width => data_width)
port map (
    clk      => clk,
    addr     => addr,
    data_out => data_out
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
        addr <= std_logic_vector(to_unsigned(i, addr_width));
        wait for CLK_PERIOD;
    end loop;

    addr <= (others => '0');
    wait for 2*CLK_PERIOD;
    wait;
end process;

end architecture simple;
