library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_riscv_single_abc is
end entity tb_riscv_single_abc;

architecture simple of tb_riscv_single_abc is

    constant CLK_PERIOD : time := 100 ns;
    constant EXPECTED   : std_logic_vector(31 downto 0) := x"00000034";  -- (5*10)+2 = 52

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal Y        : std_logic_vector(31 downto 0);
    signal sim_done : boolean   := false;

begin

    uut: entity work.riscv_single_abc
        port map (
            clk => clk,
            rst => rst,
            Y   => Y
        );

    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim: process
    begin
        report "=== Testbench RISC-V single-cycle (ABC) ===";
        report "Programa: x4 = (x1 * x2) + x3 = (5 * 10) + 2 = 52";
        report "Esperado en Y: 0x00000034";

        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        report "Reset liberado";

        -- dejar correr suficientes ciclos para que mul + add se ejecuten
        wait for 8 * CLK_PERIOD;

        report "Fin de la simulacion";
        sim_done <= true;
        wait;
    end process;

    -- monitor: dispara una nota la primera vez que Y alcanza el valor esperado
    monitor: process
    begin
        wait until Y = EXPECTED;
        report "[CHECK PASS] Y = 0x00000034 alcanzado en t = "
               & time'image(now);
        wait;
    end process;

end architecture simple;
