library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_riscv_single_abc is
end entity tb_riscv_single_abc;

architecture simple of tb_riscv_single_abc is

constant CLK_PERIOD : time := 100 ns;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal Y   : std_logic_vector(31 downto 0);

begin

uut: entity work.riscv_single_abc
port map (
    clk => clk,
    rst => rst,
    Y   => Y
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
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';
    wait for 6*CLK_PERIOD;
    wait;
end process;

end architecture simple;
