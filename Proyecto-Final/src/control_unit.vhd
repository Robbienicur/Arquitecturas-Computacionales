library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Unidad de control RV32I. Decodifica opcode/funct3/funct7 y genera las
-- senales de control del datapath (write-enables, mux selects, alu_op).
entity control_unit is
port (
    opcode    : in  std_logic_vector(6 downto 0);
    funct3    : in  std_logic_vector(2 downto 0);
    funct7    : in  std_logic_vector(6 downto 0);

    reg_w     : out std_logic;
    mem_r     : out std_logic;
    mem_w     : out std_logic;
    alu_src_b : out std_logic;
    wb_sel    : out std_logic_vector(1 downto 0);
    branch    : out std_logic;
    jump      : out std_logic;
    jalr      : out std_logic;
    imm_src   : out std_logic_vector(2 downto 0);
    alu_op    : out std_logic_vector(3 downto 0)
);
end entity control_unit;

architecture simple of control_unit is

    constant OP_R      : std_logic_vector(6 downto 0) := "0110011";
    constant OP_I      : std_logic_vector(6 downto 0) := "0010011";
    constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";
    constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";
    constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";
    constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";

    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0001";
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0011";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "1000";
    constant ALU_LUI  : std_logic_vector(3 downto 0) := "1101";

begin

    process(opcode, funct3, funct7)
    begin
        -- Valores por defecto
        reg_w     <= '0';
        mem_r     <= '0';
        mem_w     <= '0';
        alu_src_b <= '0';
        wb_sel    <= "00";
        branch    <= '0';
        jump      <= '0';
        jalr      <= '0';
        imm_src   <= "000";
        alu_op    <= ALU_ADD;

        if opcode = OP_R then
            -- Tipo R
            reg_w     <= '1';
            alu_src_b <= '0';
            wb_sel    <= "00";
            if funct3 = "000" and funct7 = "0100000" then
                alu_op <= ALU_SUB;
            elsif funct3 = "000" then
                alu_op <= ALU_ADD;
            elsif funct3 = "111" then
                alu_op <= ALU_AND;
            elsif funct3 = "110" then
                alu_op <= ALU_OR;
            elsif funct3 = "100" then
                alu_op <= ALU_XOR;
            elsif funct3 = "001" then
                alu_op <= ALU_SLL;
            elsif funct3 = "101" and funct7 = "0100000" then
                alu_op <= ALU_SRA;
            elsif funct3 = "101" then
                alu_op <= ALU_SRL;
            elsif funct3 = "010" then
                alu_op <= ALU_SLT;
            end if;

        elsif opcode = OP_I then
            -- Tipo I aritmetico
            reg_w     <= '1';
            alu_src_b <= '1';
            wb_sel    <= "00";
            imm_src   <= "000";
            if funct3 = "000" then
                alu_op <= ALU_ADD;
            elsif funct3 = "111" then
                alu_op <= ALU_AND;
            elsif funct3 = "110" then
                alu_op <= ALU_OR;
            elsif funct3 = "100" then
                alu_op <= ALU_XOR;
            elsif funct3 = "001" then
                alu_op  <= ALU_SLL;
                imm_src <= "101";
            elsif funct3 = "101" and funct7 = "0100000" then
                alu_op  <= ALU_SRA;
                imm_src <= "101";
            elsif funct3 = "101" then
                alu_op  <= ALU_SRL;
                imm_src <= "101";
            elsif funct3 = "010" then
                alu_op <= ALU_SLT;
            end if;

        elsif opcode = OP_LOAD then
            -- LW
            reg_w     <= '1';
            mem_r     <= '1';
            alu_src_b <= '1';
            wb_sel    <= "01";
            imm_src   <= "000";
            alu_op    <= ALU_ADD;

        elsif opcode = OP_STORE then
            -- SW
            mem_w     <= '1';
            alu_src_b <= '1';
            imm_src   <= "001";
            alu_op    <= ALU_ADD;

        elsif opcode = OP_BRANCH then
            -- BEQ/BNE
            branch    <= '1';
            imm_src   <= "010";
            alu_op    <= ALU_SUB;

        elsif opcode = OP_LUI then
            -- LUI
            reg_w     <= '1';
            alu_src_b <= '1';
            wb_sel    <= "00";
            imm_src   <= "011";
            alu_op    <= ALU_LUI;

        elsif opcode = OP_JAL then
            -- JAL
            reg_w   <= '1';
            jump    <= '1';
            jalr    <= '0';
            wb_sel  <= "10";
            imm_src <= "100";

        elsif opcode = OP_JALR then
            -- JALR
            reg_w   <= '1';
            jump    <= '1';
            jalr    <= '1';
            wb_sel  <= "10";
            imm_src <= "000";
        end if;

    end process;

end architecture simple;
