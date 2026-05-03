library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity moore_101 is
port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    input_bit : in  std_logic;
    flag      : out std_logic
);
end entity moore_101;

architecture behavioral of moore_101 is

    type state_type is (S0, S1, S2, S3);
    signal current_state, next_state : state_type;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= S0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, input_bit)
    begin
        next_state <= current_state;
        flag       <= '0';
        case current_state is
            when S0 =>
                if input_bit = '1' then
                    next_state <= S1;
                else
                    next_state <= S0;
                end if;
            when S1 =>
                if input_bit = '0' then
                    next_state <= S2;
                else
                    next_state <= S1;
                end if;
            when S2 =>
                if input_bit = '1' then
                    next_state <= S3;
                else
                    next_state <= S0;
                end if;
            when S3 =>
                flag <= '1';
                if input_bit = '0' then
                    next_state <= S2;
                else
                    next_state <= S1;
                end if;
            when others =>
                next_state <= S0;
        end case;
    end process;

end architecture behavioral;
