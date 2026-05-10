library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Generador de inmediatos RV32I. Reordena y extiende por signo los campos
-- de la instruccion segun el formato seleccionado por imm_src
-- (000=I, 001=S, 010=B, 011=U, 100=J, 101=shamt).
entity imm_gen is
port (
    instr   : in  std_logic_vector(31 downto 0);
    imm_src : in  std_logic_vector(2 downto 0);
    imm_out : out std_logic_vector(31 downto 0)
);
end entity imm_gen;

architecture simple of imm_gen is

    signal imm : std_logic_vector(31 downto 0);
    signal sign : std_logic;

begin

    sign <= instr(31);

    process(instr, imm_src, sign)
        variable r : std_logic_vector(31 downto 0);
    begin
        r := (others => '0');

        case imm_src is

            -- Tipo I
            when "000" =>
                r(31 downto 12) := (others => sign);
                r(11 downto 0)  := instr(31 downto 20);

            -- Tipo S
            when "001" =>
                r(31 downto 12) := (others => sign);
                r(11 downto 5)  := instr(31 downto 25);
                r(4 downto 0)   := instr(11 downto 7);

            -- Tipo B
            when "010" =>
                r(31 downto 13) := (others => sign);
                r(12)           := instr(31);
                r(11)           := instr(7);
                r(10 downto 5)  := instr(30 downto 25);
                r(4 downto 1)   := instr(11 downto 8);
                r(0)            := '0';

            -- Tipo U: el desplazamiento final lo aplica ALU_LUI.
            when "011" =>
                r(19 downto 0)  := instr(31 downto 12);
                r(31 downto 20) := (others => '0');

            -- Tipo J
            when "100" =>
                r(31 downto 21) := (others => sign);
                r(20)           := instr(31);
                r(19 downto 12) := instr(19 downto 12);
                r(11)           := instr(20);
                r(10 downto 1)  := instr(30 downto 21);
                r(0)            := '0';

            -- shamt para SLLI/SRLI/SRAI
            when "101" =>
                r(4 downto 0) := instr(24 downto 20);

            when others =>
                r := (others => '0');

        end case;

        imm_out <= r;
    end process;

end architecture simple;
