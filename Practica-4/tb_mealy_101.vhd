library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mealy_101 is
end entity tb_mealy_101;

architecture simple of tb_mealy_101 is

constant CLK_PERIOD : time := 10 ns;

signal clk       : std_logic := '0';
signal rst       : std_logic := '1';
signal input_bit : std_logic := '0';
signal flag      : std_logic;

-- secuencia de prueba: 1,1,0,1,0,1,0,0,1
-- esperado: flag='1' cuando se complete "101" (con traslape)
type bit_vec is array (natural range <>) of std_logic;
constant seq : bit_vec := ('1','1','0','1','0','1','0','0','1');

begin

uut: entity work.mealy_101
port map (
    clk       => clk,
    rst       => rst,
    input_bit => input_bit,
    flag      => flag
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
    -- reset un ciclo
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    -- meto la secuencia bit por bit, uno cada flanco
    for i in seq'range loop
        input_bit <= seq(i);
        wait for CLK_PERIOD;
    end loop;

    input_bit <= '0';
    wait for 2*CLK_PERIOD;
    wait;
end process;

end architecture simple;
