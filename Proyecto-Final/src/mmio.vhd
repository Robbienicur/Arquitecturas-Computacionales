library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Decodificador memory-mapped: rutea lw/sw entre RAM, switches/LEDs
-- y registros del juego segun el nibble alto de la direccion.
-- Tambien mantiene la cola de la serpiente guardando el head anterior.
entity mmio is
port (
    clk         : in  std_logic;
    rst         : in  std_logic;

    addr        : in  std_logic_vector(31 downto 0);
    data_in     : in  std_logic_vector(31 downto 0);
    mem_r       : in  std_logic;
    mem_w       : in  std_logic;
    data_out    : out std_logic_vector(31 downto 0);

    dir_in      : in  std_logic_vector(3 downto 0);  -- SW(3:0): UP/RIGHT/DOWN/LEFT
    led_out     : out std_logic_vector(3 downto 0);

    -- Estado del juego para vga_renderer y los displays 7-seg
    head_x_out  : out std_logic_vector(2 downto 0);
    head_y_out  : out std_logic_vector(2 downto 0);
    tail_x_out  : out std_logic_vector(2 downto 0);
    tail_y_out  : out std_logic_vector(2 downto 0);
    food_x_out  : out std_logic_vector(2 downto 0);
    food_y_out  : out std_logic_vector(2 downto 0);
    score_out   : out std_logic_vector(7 downto 0)
);
end entity mmio;

architecture simple of mmio is

    -- Offsets de los perifericos en 0x2000_xxxx
    constant IO_DIR : std_logic_vector(7 downto 0) := x"00";  -- switches
    constant IO_LED : std_logic_vector(7 downto 0) := x"08";

    -- Offsets del estado del juego en 0x3000_xxxx
    constant VR_HX  : std_logic_vector(7 downto 0) := x"00";
    constant VR_HY  : std_logic_vector(7 downto 0) := x"04";
    constant VR_FX  : std_logic_vector(7 downto 0) := x"08";
    constant VR_FY  : std_logic_vector(7 downto 0) := x"0C";
    constant VR_SC  : std_logic_vector(7 downto 0) := x"10";

    -- Estado inicial: debe coincidir con la inicializacion en asm/snake.S
    -- para que el primer frame ya sea coherente.
    constant INIT_HX : std_logic_vector(2 downto 0) := "100";  -- 4
    constant INIT_HY : std_logic_vector(2 downto 0) := "100";  -- 4
    constant INIT_FX : std_logic_vector(2 downto 0) := "110";  -- 6
    constant INIT_FY : std_logic_vector(2 downto 0) := "010";  -- 2

    signal is_ram   : std_logic;
    signal is_io    : std_logic;
    signal is_vram  : std_logic;
    signal off      : std_logic_vector(7 downto 0);
    signal ram_idx  : integer range 0 to 255;

    signal led_reg     : std_logic_vector(3 downto 0)  := (others => '0');
    signal head_x_reg  : std_logic_vector(2 downto 0)  := INIT_HX;
    signal head_y_reg  : std_logic_vector(2 downto 0)  := INIT_HY;
    signal prev_hx_reg : std_logic_vector(2 downto 0)  := INIT_HX;
    signal prev_hy_reg : std_logic_vector(2 downto 0)  := INIT_HY;
    signal food_x_reg  : std_logic_vector(2 downto 0)  := INIT_FX;
    signal food_y_reg  : std_logic_vector(2 downto 0)  := INIT_FY;
    signal score_reg   : std_logic_vector(7 downto 0)  := (others => '0');

    type ram_t is array (0 to 255) of std_logic_vector(31 downto 0);
    signal ram : ram_t := (others => (others => '0'));

begin

    -- Decodificacion por nibble alto
    is_ram  <= '1' when addr(31 downto 28) = x"1" else '0';
    is_io   <= '1' when addr(31 downto 28) = x"2" else '0';
    is_vram <= '1' when addr(31 downto 28) = x"3" else '0';
    off     <= addr(7 downto 0);
    ram_idx <= to_integer(unsigned(addr(9 downto 2)));

    led_out    <= led_reg;
    head_x_out <= head_x_reg;
    head_y_out <= head_y_reg;
    tail_x_out <= prev_hx_reg;
    tail_y_out <= prev_hy_reg;
    food_x_out <= food_x_reg;
    food_y_out <= food_y_reg;
    score_out  <= score_reg;

    -- Lectura combinacional: solo RAM y switches son leibles desde el bus.
    process(addr, is_ram, is_io, off, dir_in, ram, ram_idx)
    begin
        data_out <= (others => '0');
        if is_ram = '1' then
            data_out <= ram(ram_idx);
        elsif is_io = '1' then
            if off = IO_DIR then
                data_out(3 downto 0)  <= dir_in;
                data_out(31 downto 4) <= (others => '0');
            end if;
        end if;
    end process;

    -- Escritura sincrona. Al actualizar head_x/y se preserva el valor
    -- anterior en prev_hx/prev_hy para que el renderizador dibuje la cola.
    process(clk, rst)
    begin
        if rst = '1' then
            led_reg     <= (others => '0');
            head_x_reg  <= INIT_HX;
            head_y_reg  <= INIT_HY;
            prev_hx_reg <= INIT_HX;
            prev_hy_reg <= INIT_HY;
            food_x_reg  <= INIT_FX;
            food_y_reg  <= INIT_FY;
            score_reg   <= (others => '0');
        elsif rising_edge(clk) then
            if mem_w = '1' then
                if is_ram = '1' then
                    ram(ram_idx) <= data_in;
                elsif is_io = '1' then
                    if off = IO_LED then
                        led_reg <= data_in(3 downto 0);
                    end if;
                elsif is_vram = '1' then
                    case off is
                        when VR_HX =>
                            prev_hx_reg <= head_x_reg;
                            head_x_reg  <= data_in(2 downto 0);
                        when VR_HY =>
                            prev_hy_reg <= head_y_reg;
                            head_y_reg  <= data_in(2 downto 0);
                        when VR_FX =>
                            food_x_reg <= data_in(2 downto 0);
                        when VR_FY =>
                            food_y_reg <= data_in(2 downto 0);
                        when VR_SC =>
                            score_reg <= data_in(7 downto 0);
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;

end architecture simple;
