library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top estructural del proyecto RV-Snake para la DE10-Lite. Conecta el
-- datapath RV32I (PC, ROM, RF, ALU, control, MMIO) con los perifericos
-- vga_sync, vga_renderer y los displays 7-seg para el score.
entity snake_top is
port (
    MAX10_CLK1_50 : in  std_logic;

    -- KEY activos en bajo, SW activos en alto
    KEY : in  std_logic_vector(1 downto 0);
    SW  : in  std_logic_vector(9 downto 0);

    LEDR : out std_logic_vector(9 downto 0);
    HEX0 : out std_logic_vector(7 downto 0);
    HEX1 : out std_logic_vector(7 downto 0);
    HEX2 : out std_logic_vector(7 downto 0);
    HEX3 : out std_logic_vector(7 downto 0);
    HEX4 : out std_logic_vector(7 downto 0);
    HEX5 : out std_logic_vector(7 downto 0);

    VGA_R  : out std_logic_vector(3 downto 0);
    VGA_G  : out std_logic_vector(3 downto 0);
    VGA_B  : out std_logic_vector(3 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic
);
end entity snake_top;

architecture structural of snake_top is

    signal clk : std_logic;
    signal rst : std_logic;

    -- Datapath de la CPU
    signal pc_q, pc_d, pc_plus4    : std_logic_vector(31 downto 0);
    signal instr                   : std_logic_vector(31 downto 0);
    signal rs1_data, rs2_data      : std_logic_vector(31 downto 0);
    signal imm                     : std_logic_vector(31 downto 0);
    signal alu_b                   : std_logic_vector(31 downto 0);
    signal alu_res                 : std_logic_vector(31 downto 0);
    signal alu_zero                : std_logic;
    signal alu_carry, alu_ovf, alu_sign : std_logic;
    signal mem_rdata               : std_logic_vector(31 downto 0);
    signal wb_data                 : std_logic_vector(31 downto 0);
    signal br_take                 : std_logic;
    signal pc_branch, pc_jal, pc_jalr : std_logic_vector(31 downto 0);

    -- Control
    signal reg_w, mem_r, mem_w     : std_logic;
    signal alu_src_b               : std_logic;
    signal wb_sel                  : std_logic_vector(1 downto 0);
    signal branch, jump, jalr      : std_logic;
    signal imm_src                 : std_logic_vector(2 downto 0);
    signal alu_op                  : std_logic_vector(3 downto 0);

    -- Estado del juego MMIO -> perifericos
    signal head_x, head_y          : std_logic_vector(2 downto 0);
    signal tail_x, tail_y          : std_logic_vector(2 downto 0);
    signal food_x, food_y          : std_logic_vector(2 downto 0);
    signal score                   : std_logic_vector(7 downto 0);

    signal led_lo                  : std_logic_vector(3 downto 0);

    -- VGA
    signal visible : std_logic;
    signal px      : std_logic_vector(9 downto 0);
    signal py      : std_logic_vector(9 downto 0);

    -- Heartbeat ~1.5 Hz en LEDR(9) para confirmar que el reloj esta vivo
    signal heartbeat : unsigned(25 downto 0) := (others => '0');

begin

    clk <= MAX10_CLK1_50;

    -- SW(9) o KEY(0) activan reset
    rst <= SW(9) or (not KEY(0));

    process(clk, rst)
    begin
        if rst = '1' then
            heartbeat <= (others => '0');
        elsif rising_edge(clk) then
            heartbeat <= heartbeat + 1;
        end if;
    end process;

    LEDR(3 downto 0) <= led_lo;
    LEDR(8 downto 4) <= (others => '0');
    LEDR(9)          <= heartbeat(25);

    -- HEX5..HEX2 apagados (segmentos activos en bajo)
    HEX2 <= (others => '1');
    HEX3 <= (others => '1');
    HEX4 <= (others => '1');
    HEX5 <= (others => '1');

    -- CPU

    u_pc: entity work.pc
        port map (
            clk => clk,
            rst => rst,
            d   => pc_d,
            q   => pc_q
        );

    pc_plus4 <= std_logic_vector(unsigned(pc_q) + 4);

    u_rom: entity work.instr_rom
        port map (
            addr  => pc_q,
            instr => instr
        );

    u_ctrl: entity work.control_unit
        port map (
            opcode    => instr(6 downto 0),
            funct3    => instr(14 downto 12),
            funct7    => instr(31 downto 25),
            reg_w     => reg_w,
            mem_r     => mem_r,
            mem_w     => mem_w,
            alu_src_b => alu_src_b,
            wb_sel    => wb_sel,
            branch    => branch,
            jump      => jump,
            jalr      => jalr,
            imm_src   => imm_src,
            alu_op    => alu_op
        );

    u_rf: entity work.register_file
        port map (
            clk => clk,
            we  => reg_w,
            rs1 => instr(19 downto 15),
            rs2 => instr(24 downto 20),
            rd  => instr(11 downto 7),
            wd  => wb_data,
            rd1 => rs1_data,
            rd2 => rs2_data
        );

    u_imm: entity work.imm_gen
        port map (
            instr   => instr,
            imm_src => imm_src,
            imm_out => imm
        );

    alu_b <= imm when alu_src_b = '1' else rs2_data;

    u_alu: entity work.alu32
        generic map (
            data_width => 32
        )
        port map (
            opa       => rs1_data,
            opb       => alu_b,
            alu_ctrl  => alu_op,
            result    => alu_res,
            carry_out => alu_carry,
            overflow  => alu_ovf,
            zero      => alu_zero,
            sign      => alu_sign
        );

    u_mmio: entity work.mmio
        port map (
            clk        => clk,
            rst        => rst,
            addr       => alu_res,
            data_in    => rs2_data,
            mem_r      => mem_r,
            mem_w      => mem_w,
            data_out   => mem_rdata,
            dir_in     => SW(3 downto 0),
            led_out    => led_lo,
            head_x_out => head_x,
            head_y_out => head_y,
            tail_x_out => tail_x,
            tail_y_out => tail_y,
            food_x_out => food_x,
            food_y_out => food_y,
            score_out  => score
        );

    -- Write-back mux
    process(wb_sel, alu_res, mem_rdata, pc_plus4)
    begin
        if wb_sel = "00" then
            wb_data <= alu_res;
        elsif wb_sel = "01" then
            wb_data <= mem_rdata;
        elsif wb_sel = "10" then
            wb_data <= pc_plus4;
        else
            wb_data <= alu_res;
        end if;
    end process;

    -- Branches (BEQ/BNE)
    process(branch, instr, alu_zero)
    begin
        br_take <= '0';
        if branch = '1' then
            if instr(14 downto 12) = "000" then
                br_take <= alu_zero;       -- BEQ
            elsif instr(14 downto 12) = "001" then
                br_take <= not alu_zero;   -- BNE
            end if;
        end if;
    end process;

    pc_branch <= std_logic_vector(unsigned(pc_q) + unsigned(imm));
    pc_jal    <= std_logic_vector(unsigned(pc_q) + unsigned(imm));
    pc_jalr   <= std_logic_vector((unsigned(rs1_data) + unsigned(imm))) and x"FFFFFFFE";

    process(jump, jalr, branch, br_take, pc_plus4, pc_branch, pc_jal, pc_jalr)
    begin
        if jump = '1' and jalr = '1' then
            pc_d <= pc_jalr;
        elsif jump = '1' then
            pc_d <= pc_jal;
        elsif branch = '1' and br_take = '1' then
            pc_d <= pc_branch;
        else
            pc_d <= pc_plus4;
        end if;
    end process;

    -- VGA

    u_vga_sync: entity work.vga_sync
        port map (
            clk     => clk,
            rst     => rst,
            hs      => VGA_HS,
            vs      => VGA_VS,
            visible => visible,
            px      => px,
            py      => py
        );

    u_vga_render: entity work.vga_renderer
        port map (
            visible => visible,
            px      => px,
            py      => py,
            head_x  => head_x,
            head_y  => head_y,
            tail_x  => tail_x,
            tail_y  => tail_y,
            food_x  => food_x,
            food_y  => food_y,
            r_out   => VGA_R,
            g_out   => VGA_G,
            b_out   => VGA_B
        );

    -- Displays de score

    u_hex0: entity work.seven_seg
        port map (
            nibble => score(3 downto 0),
            segs   => HEX0
        );

    u_hex1: entity work.seven_seg
        port map (
            nibble => score(7 downto 4),
            segs   => HEX1
        );

end architecture structural;
