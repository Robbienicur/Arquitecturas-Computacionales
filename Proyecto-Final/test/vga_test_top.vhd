library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top de prueba que pinta 8 barras verticales fijas usando vga_sync.
-- Sirve para validar la cadena reloj -> sync -> pines VGA -> monitor
-- antes de integrar la CPU.
entity vga_test_top is
port (
    MAX10_CLK1_50 : in  std_logic;
    KEY : in  std_logic_vector(1 downto 0);   -- activos en bajo
    LEDR : out std_logic_vector(9 downto 0);

    VGA_R  : out std_logic_vector(3 downto 0);
    VGA_G  : out std_logic_vector(3 downto 0);
    VGA_B  : out std_logic_vector(3 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic
);
end entity vga_test_top;

architecture rtl of vga_test_top is

    signal rst       : std_logic;
    signal visible   : std_logic;
    signal px_slv    : std_logic_vector(9 downto 0);
    signal py_slv    : std_logic_vector(9 downto 0);
    signal px_int    : integer range 0 to 1023;

    -- Heartbeat ~1.5 Hz en LEDR(0)
    signal heartbeat : unsigned(25 downto 0) := (others => '0');

begin

    -- Reset activo en alto a partir de KEY[0]
    rst <= not KEY(0);

    process(MAX10_CLK1_50, rst)
    begin
        if rst = '1' then
            heartbeat <= (others => '0');
        elsif rising_edge(MAX10_CLK1_50) then
            heartbeat <= heartbeat + 1;
        end if;
    end process;

    LEDR(0)          <= heartbeat(25);
    LEDR(9 downto 1) <= (others => '0');

    u_sync: entity work.vga_sync
        port map (
            clk     => MAX10_CLK1_50,
            rst     => rst,
            hs      => VGA_HS,
            vs      => VGA_VS,
            visible => visible,
            px      => px_slv,
            py      => py_slv
        );

    px_int <= to_integer(unsigned(px_slv));

    -- 8 barras de 80 px (8*80 = 640). Fuera del area visible los canales
    -- deben quedar en cero, por eso el default al inicio del proceso.
    process(visible, px_int)
    begin
        VGA_R <= (others => '0');
        VGA_G <= (others => '0');
        VGA_B <= (others => '0');
        if visible = '1' then
            if    px_int <  80 then        -- blanco
                VGA_R <= x"F"; VGA_G <= x"F"; VGA_B <= x"F";
            elsif px_int < 160 then        -- amarillo
                VGA_R <= x"F"; VGA_G <= x"F"; VGA_B <= x"0";
            elsif px_int < 240 then        -- cian
                VGA_R <= x"0"; VGA_G <= x"F"; VGA_B <= x"F";
            elsif px_int < 320 then        -- verde
                VGA_R <= x"0"; VGA_G <= x"F"; VGA_B <= x"0";
            elsif px_int < 400 then        -- magenta
                VGA_R <= x"F"; VGA_G <= x"0"; VGA_B <= x"F";
            elsif px_int < 480 then        -- rojo
                VGA_R <= x"F"; VGA_G <= x"0"; VGA_B <= x"0";
            elsif px_int < 560 then        -- azul
                VGA_R <= x"0"; VGA_G <= x"0"; VGA_B <= x"F";
            else                           -- negro
                VGA_R <= x"0"; VGA_G <= x"0"; VGA_B <= x"0";
            end if;
        end if;
    end process;

end architecture rtl;
