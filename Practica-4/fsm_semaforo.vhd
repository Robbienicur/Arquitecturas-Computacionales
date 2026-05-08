library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_semaforo is
port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    emergency : in  std_logic;
    luz1      : out std_logic_vector(2 downto 0);
    luz2      : out std_logic_vector(2 downto 0);
    luz3      : out std_logic_vector(1 downto 0);
    state     : out std_logic_vector(5 downto 0)
);
end entity fsm_semaforo;

architecture behavioral of fsm_semaforo is

    constant S0 : std_logic_vector(5 downto 0) := "000001";
    constant S1 : std_logic_vector(5 downto 0) := "000010";
    constant S2 : std_logic_vector(5 downto 0) := "000100";
    constant S3 : std_logic_vector(5 downto 0) := "001000";
    constant S4 : std_logic_vector(5 downto 0) := "010000";
    constant S5 : std_logic_vector(5 downto 0) := "100000";

    constant RED   : std_logic_vector(2 downto 0) := "001";
    constant AMBER : std_logic_vector(2 downto 0) := "010";
    constant GREEN : std_logic_vector(2 downto 0) := "100";

    constant P_RED   : std_logic_vector(1 downto 0) := "01";
    constant P_GREEN : std_logic_vector(1 downto 0) := "10";
    constant P_BLINK : std_logic_vector(1 downto 0) := "11";

    signal current_state : std_logic_vector(5 downto 0);
    signal next_state    : std_logic_vector(5 downto 0);
    signal counter       : unsigned(31 downto 0);
    signal timeout_value : unsigned(31 downto 0);

begin

    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= S0;
            counter       <= (others => '0');
        elsif rising_edge(clk) then
            if emergency = '1' then
                current_state <= S0;
                counter       <= (others => '0');
            else
                if counter >= timeout_value then
                    current_state <= next_state;
                    counter       <= (others => '0');
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    process(current_state)
    begin
        case current_state is
            when S0     => timeout_value <= to_unsigned(30 * 50_000_000, 32);
            when S1     => timeout_value <= to_unsigned(5  * 50_000_000, 32);
            when S2     => timeout_value <= to_unsigned(20 * 50_000_000, 32);
            when S3     => timeout_value <= to_unsigned(5  * 50_000_000, 32);
            when S4     => timeout_value <= to_unsigned(15 * 50_000_000, 32);
            when S5     => timeout_value <= to_unsigned(10 * 50_000_000, 32);
            when others => timeout_value <= to_unsigned(30 * 50_000_000, 32);
        end case;
    end process;

    process(current_state)
    begin
        case current_state is
            when S0     => next_state <= S1;
            when S1     => next_state <= S2;
            when S2     => next_state <= S3;
            when S3     => next_state <= S4;
            when S4     => next_state <= S5;
            when S5     => next_state <= S0;
            when others => next_state <= S0;
        end case;
    end process;

    process(emergency, current_state)
    begin
        if emergency = '1' then
            luz1 <= RED;
            luz2 <= RED;
            luz3 <= P_RED;
        else
            case current_state is
                when S0 =>
                    luz1 <= GREEN;
                    luz2 <= RED;
                    luz3 <= P_RED;
                when S1 =>
                    luz1 <= AMBER;
                    luz2 <= RED;
                    luz3 <= P_RED;
                when S2 =>
                    luz1 <= RED;
                    luz2 <= GREEN;
                    luz3 <= P_RED;
                when S3 =>
                    luz1 <= RED;
                    luz2 <= AMBER;
                    luz3 <= P_RED;
                when S4 =>
                    luz1 <= RED;
                    luz2 <= RED;
                    luz3 <= P_GREEN;
                when S5 =>
                    luz1 <= RED;
                    luz2 <= RED;
                    luz3 <= P_BLINK;
                when others =>
                    luz1 <= RED;
                    luz2 <= RED;
                    luz3 <= P_RED;
            end case;
        end if;
    end process;

    state <= current_state;

end architecture behavioral;
