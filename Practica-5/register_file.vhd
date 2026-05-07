library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port (
        clk : in  STD_LOGIC;
        we  : in  STD_LOGIC;
        rs1 : in  STD_LOGIC_VECTOR(4 downto 0);
        rs2 : in  STD_LOGIC_VECTOR(4 downto 0);
        rd  : in  STD_LOGIC_VECTOR(4 downto 0);
        wd  : in  STD_LOGIC_VECTOR(31 downto 0);
        rd1 : out STD_LOGIC_VECTOR(31 downto 0);
        rd2 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity Register_File;

architecture Behavioral of Register_File is
    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal rf : reg_array := (
        1      => x"00000005",   -- A
        2      => x"0000000A",   -- B
        3      => x"00000002",   -- C
        others => (others => '0')
    );
begin
    -- lectura combinacional, x0 siempre 0
    rd1 <= rf(to_integer(unsigned(rs1))) when rs1 /= "00000" else (others => '0');
    rd2 <= rf(to_integer(unsigned(rs2))) when rs2 /= "00000" else (others => '0');

    -- escritura sincrona
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and rd /= "00000" then
                rf(to_integer(unsigned(rd))) <= wd;
            end if;
        end if;
    end process;
end Behavioral;
