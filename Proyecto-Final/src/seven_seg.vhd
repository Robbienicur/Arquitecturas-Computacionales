library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Decoder hex a 7 segmentos para la DE10-Lite (segmentos activos en bajo).
-- bit 0..6 = segmentos a..g, bit 7 = punto decimal.
entity seven_seg is
port (
    nibble : in  std_logic_vector(3 downto 0);
    segs   : out std_logic_vector(7 downto 0)
);
end entity seven_seg;

architecture rtl of seven_seg is
begin

    process(nibble)
    begin
        segs(7) <= '1';   -- punto decimal apagado
        case nibble is
            when x"0" => segs(6 downto 0) <= "1000000";  -- 0
            when x"1" => segs(6 downto 0) <= "1111001";  -- 1
            when x"2" => segs(6 downto 0) <= "0100100";  -- 2
            when x"3" => segs(6 downto 0) <= "0110000";  -- 3
            when x"4" => segs(6 downto 0) <= "0011001";  -- 4
            when x"5" => segs(6 downto 0) <= "0010010";  -- 5
            when x"6" => segs(6 downto 0) <= "0000010";  -- 6
            when x"7" => segs(6 downto 0) <= "1111000";  -- 7
            when x"8" => segs(6 downto 0) <= "0000000";  -- 8
            when x"9" => segs(6 downto 0) <= "0010000";  -- 9
            when x"A" => segs(6 downto 0) <= "0001000";  -- A
            when x"B" => segs(6 downto 0) <= "0000011";  -- b
            when x"C" => segs(6 downto 0) <= "1000110";  -- C
            when x"D" => segs(6 downto 0) <= "0100001";  -- d
            when x"E" => segs(6 downto 0) <= "0000110";  -- E
            when x"F" => segs(6 downto 0) <= "0001110";  -- F
            when others => segs(6 downto 0) <= "1111111"; -- apagado
        end case;
    end process;

end architecture rtl;
