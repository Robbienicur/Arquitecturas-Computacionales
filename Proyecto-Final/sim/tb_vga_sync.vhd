library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench de vga_sync: corre 4 lineas horizontales para verificar
-- avance de h_cnt, polaridad de hs y delimitacion de la zona visible.
entity tb_vga_sync is
end entity tb_vga_sync;

architecture sim of tb_vga_sync is

    constant CLK_PERIOD : time := 20 ns;   -- 50 MHz

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal hs      : std_logic;
    signal vs      : std_logic;
    signal visible : std_logic;
    signal px      : std_logic_vector(9 downto 0);
    signal py      : std_logic_vector(9 downto 0);

begin

    clk <= not clk after CLK_PERIOD/2;

    u_dut: entity work.vga_sync
        port map (
            clk     => clk,
            rst     => rst,
            hs      => hs,
            vs      => vs,
            visible => visible,
            px      => px,
            py      => py
        );

    process
    begin
        rst <= '1';
        wait for 5 * CLK_PERIOD;
        rst <= '0';

        -- 4 lineas = 3200 pixeles = 6400 ciclos de reloj a 50 MHz
        wait for 6400 * CLK_PERIOD;

        report "Simulacion terminada: revisar hs, vs, visible, px y py";
        wait;
    end process;

end architecture sim;
