library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is Port
            (
            op : in STD_LOGIC_VECTOR(6 downto 0);
            f7 : in STD_LOGIC_VECTOR(6 downto 0);
            reg_w : out STD_LOGIC;
            alu_c : out STD_LOGIC_VECTOR(3 downto 0)
);
end entity control_unit;

architecture Arch of control_unit is
begin
    process(op, f7)
    begin
            reg_w <= '0';
            alu_c <= "0000";

            if op = "0110011" then
                    reg_w <= '1';
                    if f7 = "0000001" then
                            alu_c <= "0001";
                    else
                            alu_c <= "0000";
                    end if;
            end if;
    end process;
end arch;
