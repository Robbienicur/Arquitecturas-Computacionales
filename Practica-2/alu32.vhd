library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu32 is
generic (
    data_width : integer := 32
);
port (
    opa      : in  std_logic_vector(data_width-1 downto 0);
    opb      : in  std_logic_vector(data_width-1 downto 0);
    alu_ctrl : in  std_logic_vector(3 downto 0);

    result    : out std_logic_vector(data_width-1 downto 0);
    carry_out : out std_logic;
    overflow  : out std_logic;
    zero      : out std_logic;
    sign      : out std_logic
);
end alu32;

architecture simple of alu32 is

constant ALU_ADD   : std_logic_vector(3 downto 0) := "0000";
constant ALU_SUB   : std_logic_vector(3 downto 0) := "0001";
constant ALU_AND   : std_logic_vector(3 downto 0) := "0010";
constant ALU_OR    : std_logic_vector(3 downto 0) := "0011";
constant ALU_XOR   : std_logic_vector(3 downto 0) := "0100";
constant ALU_SLL   : std_logic_vector(3 downto 0) := "0101";
constant ALU_SRL   : std_logic_vector(3 downto 0) := "0110";
constant ALU_SRA   : std_logic_vector(3 downto 0) := "0111";
constant ALU_SLT   : std_logic_vector(3 downto 0) := "1000";
constant ALU_SLTU  : std_logic_vector(3 downto 0) := "1001";
constant ALU_SLLI  : std_logic_vector(3 downto 0) := "1010";
constant ALU_SRLI  : std_logic_vector(3 downto 0) := "1011";
constant ALU_SRAI  : std_logic_vector(3 downto 0) := "1100";
constant ALU_LUI   : std_logic_vector(3 downto 0) := "1101";
constant ALU_AUIPC : std_logic_vector(3 downto 0) := "1110";
constant ALU_NOR   : std_logic_vector(3 downto 0) := "1111";

begin

process(opa, opb, alu_ctrl)
    variable shamt   : integer range 0 to 31;
    variable r_v     : std_logic_vector(data_width-1 downto 0);
    variable sum_ext : unsigned(data_width downto 0);
    variable sub_ext : unsigned(data_width downto 0);
begin
    shamt := to_integer(unsigned(opb(4 downto 0)));

    r_v := (others => '0');
    carry_out <= '0';
    overflow  <= '0';

    case alu_ctrl is

        when ALU_ADD =>
            sum_ext := unsigned('0' & opa) + unsigned('0' & opb);
            r_v := std_logic_vector(sum_ext(data_width-1 downto 0));
            carry_out <= sum_ext(data_width);
            if (opa(31) = opb(31)) and (r_v(31) /= opa(31)) then
                overflow <= '1';
            else
                overflow <= '0';
            end if;

        when ALU_SUB =>
            sub_ext := unsigned('0' & opa) - unsigned('0' & opb);
            r_v := std_logic_vector(sub_ext(data_width-1 downto 0));
            carry_out <= sub_ext(data_width);
            if (opa(31) /= opb(31)) and (r_v(31) /= opa(31)) then
                overflow <= '1';
            else
                overflow <= '0';
            end if;

        when ALU_AND =>
            r_v := opa and opb;

        when ALU_OR =>
            r_v := opa or opb;

        when ALU_XOR =>
            r_v := opa xor opb;

        when ALU_SLL =>
            r_v := std_logic_vector(shift_left(unsigned(opa), shamt));

        when ALU_SRL =>
            r_v := std_logic_vector(shift_right(unsigned(opa), shamt));

        when ALU_SRA =>
            r_v := std_logic_vector(shift_right(signed(opa), shamt));

        when ALU_SLT =>
            if signed(opa) < signed(opb) then
                r_v := (0 => '1', others => '0');
            else
                r_v := (others => '0');
            end if;

        when ALU_SLTU =>
            if unsigned(opa) < unsigned(opb) then
                r_v := (0 => '1', others => '0');
            else
                r_v := (others => '0');
            end if;

        when ALU_SLLI =>
            r_v := std_logic_vector(shift_left(unsigned(opa), shamt));

        when ALU_SRLI =>
            r_v := std_logic_vector(shift_right(unsigned(opa), shamt));

        when ALU_SRAI =>
            r_v := std_logic_vector(shift_right(signed(opa), shamt));

        when ALU_LUI =>
            r_v := std_logic_vector(shift_left(unsigned(opb), 12));

        when ALU_AUIPC =>
            r_v := std_logic_vector(unsigned(opa) + shift_left(unsigned(opb), 12));

        when ALU_NOR =>
            r_v := opa nor opb;

        when others =>
            r_v := (others => '0');

    end case;

    result <= r_v;

    if r_v = (r_v'range => '0') then
        zero <= '1';
    else
        zero <= '0';
    end if;

    sign <= r_v(data_width-1);

end process;

end simple;
