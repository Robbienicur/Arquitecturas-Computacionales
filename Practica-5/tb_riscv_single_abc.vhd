library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_riscv_single_abc is
end entity tb_riscv_single_abc;

architecture full of tb_riscv_single_abc is

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
        report "===============================================";
        report " Testbench RISC-V single-cycle (subset ABC)";
        report " ROM:";
        report "   mul x4, x1, x2   -> x4 = 5  * 10 = 50";
        report "   add x4, x4, x3   -> x4 = 50 +  2 = 52";
        report "   jal x0, 0        -> loop";
        report " Esperado en Y: 0x00000034 (52)";
        report "===============================================";

        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        report "[t=" & time'image(now) & "] reset liberado";

        for i in 1 to 6 loop
            wait until rising_edge(clk);
            wait for 1 ns;
            report "[ciclo " & integer'image(i) & "] Y = 0x" & to_hstring(Y);
        end loop;

        wait for 2 * CLK_PERIOD;
        report "Fin de la simulacion";
        sim_done <= true;
        wait;
    end process;

    monitor: process
    begin
        wait until Y = EXPECTED;
        report "[CHECK PASS] Y alcanzo el valor esperado 0x00000034 en t = "
               & time'image(now);
        wait;
    end process;

end architecture full;
