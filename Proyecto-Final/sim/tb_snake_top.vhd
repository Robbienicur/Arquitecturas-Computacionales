library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench de snake_top: arranca el reloj, libera el reset y mueve
-- los switches para verificar arranque, primera escritura a VRAM y un
-- pulso de VSYNC en los primeros ~5 ms.
entity tb_snake_top is
end entity tb_snake_top;

architecture sim of tb_snake_top is

    constant CLK_PERIOD : time := 20 ns;   -- 50 MHz

    signal clk    : std_logic := '0';
    signal key    : std_logic_vector(1 downto 0) := "11";
    signal sw     : std_logic_vector(9 downto 0) := (others => '0');

    signal ledr   : std_logic_vector(9 downto 0);
    signal hex0   : std_logic_vector(7 downto 0);
    signal hex1   : std_logic_vector(7 downto 0);
    signal hex2   : std_logic_vector(7 downto 0);
    signal hex3   : std_logic_vector(7 downto 0);
    signal hex4   : std_logic_vector(7 downto 0);
    signal hex5   : std_logic_vector(7 downto 0);

    signal vga_r  : std_logic_vector(3 downto 0);
    signal vga_g  : std_logic_vector(3 downto 0);
    signal vga_b  : std_logic_vector(3 downto 0);
    signal vga_hs : std_logic;
    signal vga_vs : std_logic;

begin

    uut: entity work.snake_top
        port map (
            MAX10_CLK1_50 => clk,
            KEY           => key,
            SW            => sw,
            LEDR          => ledr,
            HEX0          => hex0,
            HEX1          => hex1,
            HEX2          => hex2,
            HEX3          => hex3,
            HEX4          => hex4,
            HEX5          => hex5,
            VGA_R         => vga_r,
            VGA_G         => vga_g,
            VGA_B         => vga_b,
            VGA_HS        => vga_hs,
            VGA_VS        => vga_vs
        );

    clk <= not clk after CLK_PERIOD/2;

    stim: process
    begin
        -- Reset
        sw(9) <= '1';
        wait for 4*CLK_PERIOD;
        sw(9) <= '0';

        wait for 100 us;

        -- SW(0) = UP
        sw(0) <= '1';
        wait for 500 us;
        sw(0) <= '0';

        -- SW(3) = LEFT
        sw(3) <= '1';
        wait for 500 us;
        sw(3) <= '0';

        wait for 4 ms;

        report "Simulacion terminada: revisar waveform";
        wait;
    end process;

end architecture sim;
