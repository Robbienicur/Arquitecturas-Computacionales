library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_single_abc is
    Port (
        clk, rst : in  STD_LOGIC;
        Y        : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity riscv_single_abc;

architecture structural of riscv_single_abc is
    signal pc_out, pc_next, instr, rd1, rd2, alu_res, wb_data : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_w    : STD_LOGIC;
    signal alu_ctrl : STD_LOGIC_VECTOR(3 downto 0);
begin
    pc_next <= std_logic_vector(unsigned(pc_out) + 4);

    U1: entity work.PC port map(clk, rst, pc_next, pc_out);
    U2: entity work.rom port map(pc_out, instr);
    U3: entity work.control_unit port map(instr(6 downto 0), instr(31 downto 25), reg_w, alu_ctrl);
    U4: entity work.Register_File port map(clk, reg_w, instr(19 downto 15), instr(24 downto 20), instr(11 downto 7), wb_data, rd1, rd2);
    U5: entity work.ALU port map(rd1, rd2, alu_ctrl, alu_res);

    wb_data <= alu_res;
    Y       <= wb_data;
end structural;
