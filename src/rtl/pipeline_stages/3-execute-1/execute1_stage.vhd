LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY execute1_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        ALU_OP : IN alu_op_t;
        ALU_INPUT_SEL : IN alu_input_sel_t;
        UPDATE_FLAGS : IN STD_LOGIC;

        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_result_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        corrected_ccr_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- input port
        input_port_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- forwarding control
        RSRC1_SEL : IN fwd_sel_t;
        RSRC2_SEL : IN fwd_sel_t;
        FLAG_SRC_SEL : IN flag_src_sel_t;
        -- forwarding data
        read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_ex2_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_ex2_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_mem_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_mem_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_wb_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_wb_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        fwd_ex2_flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        fwd_mem_flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        flag_wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);


        --debug 
        CCR_monitor : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)



    );
END ENTITY execute1_stage;

ARCHITECTURE rtl OF execute1_stage IS
Signal uncorrected_ccr_flags : STD_LOGIC_VECTOR(2 DOWNTO 0);
Signal corrected_prev_flags : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL A : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL B1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL B : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    -- Should contain flag_reg and ALU
    -- control signals that will path through should not be registered here(for example next_pc will not be used here so it is not inside the stage)
WITH RSRC1_SEL SELECT
    A <= fwd_ex2_data_1 when FWD_FROM_EX1,
         fwd_ex2_data_2 when FWD_FROM_EX1_PORT2,
         fwd_mem_data_1 when FWD_FROM_EX2,
         fwd_mem_data_2 when FWD_FROM_EX2_PORT2,
         fwd_wb_data_1 when FWD_FROM_MEM,
         fwd_wb_data_2 when FWD_FROM_MEM_PORT2,
         read_data_1_in WHEN OTHERS;
WITH RSRC2_SEL SELECT
    B1 <= fwd_ex2_data_1 when FWD_FROM_EX1,
         fwd_ex2_data_2 when FWD_FROM_EX1_PORT2,
         fwd_mem_data_1 when FWD_FROM_EX2,
         fwd_mem_data_2 when FWD_FROM_EX2_PORT2,
         fwd_wb_data_1 when FWD_FROM_MEM,
         fwd_wb_data_2 when FWD_FROM_MEM_PORT2,
         read_data_2_in WHEN OTHERS;
WITH ALU_INPUT_SEL SELECT
    B <= (15 downto 0 => '0') & imm_offset_in when ALU_INPUT_IMMEDIATE, --sign extend immediate
         input_port_data_in when ALU_INPUT_IN_PORT,
         B1 when OTHERS;
WITH FLAG_SRC_SEL SELECT
    corrected_prev_flags <= fwd_ex2_flags when FLAG_FROM_EX1,
                            fwd_mem_flags when FLAG_FROM_EX2,
                            flag_wb when FLAG_FROM_MEM,
                            uncorrected_ccr_flags when others;

    CCR_monitor <= uncorrected_ccr_flags;
    corrected_ccr_flags_out <= corrected_prev_flags;
    base_reg_data_out <= B1;
    ALU_inst : entity work.ALU
    port map (
        A => A, 
        B => B,
        prev_flags => corrected_prev_flags,
        ALUOP => ALU_OP,
        Result1 => alu_result_1_out,
        Result2 => alu_result_2_out,
        output_flags => alu_flags_out
    );
CCR_inst : entity work.flags_reg
    port map (
        clk => clk,
        reset => reset,
        UPDATE_FLAGS => UPDATE_FLAGS,
        flag_wb => flag_wb,
        flags_out => uncorrected_ccr_flags
    );
    END ARCHITECTURE rtl;