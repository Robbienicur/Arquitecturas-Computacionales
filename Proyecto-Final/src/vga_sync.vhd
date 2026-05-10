library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generador de timing VGA 640x480 @ 60 Hz desde un reloj de 50 MHz
-- (pix clock de 25 MHz via toggle de pix_en). Salidas hs/vs en polaridad
-- negativa, visible alta dentro del area de dibujo, px/py con la coordenada.
entity vga_sync is
port (
    clk     : in  std_logic;                       -- 50 MHz
    rst     : in  std_logic;
    hs      : out std_logic;
    vs      : out std_logic;
    visible : out std_logic;
    px      : out std_logic_vector(9 downto 0);    -- 0..639
    py      : out std_logic_vector(9 downto 0)     -- 0..479
);
end entity vga_sync;

architecture rtl of vga_sync is

    -- Tiempos VGA 640x480 @ 60 Hz (en pixeles)
    constant H_VISIBLE : integer := 640;
    constant H_FRONT   : integer := 16;
    constant H_SYNC    : integer := 96;
    constant H_BACK    : integer := 48;
    constant H_TOTAL   : integer := 800;

    constant V_VISIBLE : integer := 480;
    constant V_FRONT   : integer := 10;
    constant V_SYNC    : integer := 2;
    constant V_BACK    : integer := 33;
    constant V_TOTAL   : integer := 525;

    signal pix_en : std_logic := '0';
    signal h_cnt  : integer range 0 to H_TOTAL-1 := 0;
    signal v_cnt  : integer range 0 to V_TOTAL-1 := 0;

begin

    -- Pixel enable: toggle a 50 MHz para obtener 25 MHz efectivos sin PLL.
    process(clk, rst)
    begin
        if rst = '1' then
            pix_en <= '0';
        elsif rising_edge(clk) then
            pix_en <= not pix_en;
        end if;
    end process;

    -- Contadores horizontal y vertical
    process(clk, rst)
    begin
        if rst = '1' then
            h_cnt <= 0;
            v_cnt <= 0;
        elsif rising_edge(clk) then
            if pix_en = '1' then
                if h_cnt = H_TOTAL-1 then
                    h_cnt <= 0;
                    if v_cnt = V_TOTAL-1 then
                        v_cnt <= 0;
                    else
                        v_cnt <= v_cnt + 1;
                    end if;
                else
                    h_cnt <= h_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- HSYNC/VSYNC en bajo durante el pulso de sync
    hs <= '0' when (h_cnt >= H_VISIBLE + H_FRONT) and
                   (h_cnt <  H_VISIBLE + H_FRONT + H_SYNC)
          else '1';

    vs <= '0' when (v_cnt >= V_VISIBLE + V_FRONT) and
                   (v_cnt <  V_VISIBLE + V_FRONT + V_SYNC)
          else '1';

    visible <= '1' when (h_cnt < H_VISIBLE) and (v_cnt < V_VISIBLE) else '0';
    px <= std_logic_vector(to_unsigned(h_cnt, 10));
    py <= std_logic_vector(to_unsigned(v_cnt, 10));

end architecture rtl;
