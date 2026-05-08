library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_moore_101 is
end entity tb_moore_101;

architecture simple of tb_moore_101 is

constant CLK_PERIOD : time := 10 ns;

signal clk       : std_logic := '0';
signal rst       : std_logic := '1';
signal input_bit : std_logic := '0';
signal flag      : std_logic;

-- secuencia: 1,1,0,1,0,1,0,0,1
-- en moore flag sube un ciclo despues (cuando llega a S3)
type bit_vec is array (natural range <>) of std_logic;
constant seq : bit_vec := ('1','1','0','1','0','1','0','0','1');

begin

uut: entity work.moore_101
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
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    for i in seq'range loop
        input_bit <= seq(i);
        wait for CLK_PERIOD;
    end loop;

    input_bit <= '0';
    wait for 2*CLK_PERIOD;
    wait;
end process;

end architecture simple;
