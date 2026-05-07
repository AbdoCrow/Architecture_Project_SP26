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
        SWAP_2ND_CYCLE : IN STD_LOGIC;

        read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        fwd_ex2_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_mem_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_wb_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSRC1_SEL : IN fwd_sel_t;
        RSRC2_SEL : IN fwd_sel_t;

        alu_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        corrected_ccr_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY execute1_stage;

ARCHITECTURE rtl OF execute1_stage IS
BEGIN
    -- Definition-only skeleton.
    -- SWAP and interrupt micro-steps reuse generic ALU_OP values with control-path sequencing.
END ARCHITECTURE rtl;