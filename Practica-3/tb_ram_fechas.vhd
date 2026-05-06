library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ram_fechas is
end entity tb_ram_fechas;

architecture simple of tb_ram_fechas is

constant addr_width : integer := 4;
constant data_width : integer := 32;
constant CLK_PERIOD : time := 10 ns;

signal clk      : std_logic := '0';
signal we       : std_logic := '0';
signal addr     : std_logic_vector(addr_width-1 downto 0) := (others => '0');
signal data_in  : std_logic_vector(data_width-1 downto 0) := (others => '0');
signal data_out : std_logic_vector(data_width-1 downto 0);

begin

uut: entity work.ram_fechas
generic map (addr_width => addr_width, data_width => data_width)
port map (
    clk      => clk,
    we       => we,
    addr     => addr,
    data_in  => data_in,
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

    we <= '1';
    addr    <= "0000";
    data_in <= x"15052003";
    wait for CLK_PERIOD;

    addr    <= "0001";
    data_in <= x"22082002";
    wait for CLK_PERIOD;

    addr    <= "0101";
    data_in <= x"07122003";
    wait for CLK_PERIOD;

    addr    <= "1010";
    data_in <= x"14112002";
    wait for CLK_PERIOD;

    addr    <= "1111";
    data_in <= x"30012004";
    wait for CLK_PERIOD;

    we      <= '0';
    data_in <= (others => '0');

    for i in 0 to 15 loop
        addr <= std_logic_vector(to_unsigned(i, addr_width));
        wait for CLK_PERIOD;
    end loop;

    addr <= (others => '0');
    wait for 2*CLK_PERIOD;
    wait;
end process;

end architecture simple;
