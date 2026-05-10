library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Renderizador del tablero Snake. Tablero 480x480 centrado en una pantalla
-- 640x480, dividido en 8x8 celdas de 60 px. Color RGB444 con prioridad
-- cabeza > cola > comida > fondo del tablero > margen.
entity vga_renderer is
port (
    visible : in  std_logic;
    px      : in  std_logic_vector(9 downto 0);
    py      : in  std_logic_vector(9 downto 0);

    head_x  : in  std_logic_vector(2 downto 0);
    head_y  : in  std_logic_vector(2 downto 0);
    tail_x  : in  std_logic_vector(2 downto 0);
    tail_y  : in  std_logic_vector(2 downto 0);
    food_x  : in  std_logic_vector(2 downto 0);
    food_y  : in  std_logic_vector(2 downto 0);

    r_out   : out std_logic_vector(3 downto 0);
    g_out   : out std_logic_vector(3 downto 0);
    b_out   : out std_logic_vector(3 downto 0)
);
end entity vga_renderer;

architecture rtl of vga_renderer is

    signal px_int   : integer range 0 to 1023;
    signal py_int   : integer range 0 to 1023;
    signal in_board : std_logic;
    signal cell_x   : std_logic_vector(2 downto 0);
    signal cell_y   : std_logic_vector(2 downto 0);

begin

    px_int <= to_integer(unsigned(px));
    py_int <= to_integer(unsigned(py));

    -- Tablero centrado en x=[80, 560)
    in_board <= '1' when (px_int >= 80) and (px_int < 560) else '0';

    -- Mapeo pixel -> celda en X (cadena de comparaciones evita un divisor)
    process(px_int)
    begin
        if    px_int < 140 then cell_x <= "000";
        elsif px_int < 200 then cell_x <= "001";
        elsif px_int < 260 then cell_x <= "010";
        elsif px_int < 320 then cell_x <= "011";
        elsif px_int < 380 then cell_x <= "100";
        elsif px_int < 440 then cell_x <= "101";
        elsif px_int < 500 then cell_x <= "110";
        else                    cell_x <= "111";
        end if;
    end process;

    -- Mapeo pixel -> celda en Y
    process(py_int)
    begin
        if    py_int <  60 then cell_y <= "000";
        elsif py_int < 120 then cell_y <= "001";
        elsif py_int < 180 then cell_y <= "010";
        elsif py_int < 240 then cell_y <= "011";
        elsif py_int < 300 then cell_y <= "100";
        elsif py_int < 360 then cell_y <= "101";
        elsif py_int < 420 then cell_y <= "110";
        else                    cell_y <= "111";
        end if;
    end process;

    process(visible, in_board, cell_x, cell_y,
            head_x, head_y, tail_x, tail_y, food_x, food_y)
    begin
        r_out <= (others => '0');
        g_out <= (others => '0');
        b_out <= (others => '0');

        if visible = '1' then
            if in_board = '1' then
                if cell_x = head_x and cell_y = head_y then
                    g_out <= x"F";        -- cabeza
                elsif cell_x = tail_x and cell_y = tail_y then
                    g_out <= x"7";        -- cola
                elsif cell_x = food_x and cell_y = food_y then
                    r_out <= x"F";        -- comida
                else
                    r_out <= x"2";        -- celda vacia (gris oscuro)
                    g_out <= x"2";
                    b_out <= x"2";
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
