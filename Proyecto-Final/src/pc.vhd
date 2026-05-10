library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Program Counter: registro de 32 bits con reset asincrono.
entity pc is
port (
    clk : in  std_logic;
    rst : in  std_logic;
    d   : in  std_logic_vector(31 downto 0);
    q   : out std_logic_vector(31 downto 0)
);
end entity pc;

architecture simple of pc is
begin

    process(clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            q <= d;
        end if;
    end process;

end architecture simple;
