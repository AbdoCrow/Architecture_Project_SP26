LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY ex1_ex2_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        FLUSH : IN STD_LOGIC;

        LOAD_FLAGS_IN : IN STD_LOGIC;
        PC_WRITE_EN_IN : IN STD_LOGIC;
        MEM_WRITE_SEL_IN : IN mem_write_sel_t;
        COND_BRANCH_IN : IN STD_LOGIC;
        HLT_IN : IN STD_LOGIC;
        MEMW_IN : IN STD_LOGIC;
        MEMR_IN : IN STD_LOGIC;
        UPDATE_FLAGS_IN : IN STD_LOGIC;
        MEM_ADDRESS_SEL_IN : IN mem_address_sel_t;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_IN : IN STD_LOGIC;
        JMP_FLAG_SEL_IN : IN jmp_flag_sel_t;

        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;
        alu_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_in : IN reg_idx_t;
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        LOAD_FLAGS_OUT : OUT STD_LOGIC;
        PC_WRITE_EN_OUT : OUT STD_LOGIC;
        MEM_WRITE_SEL_OUT : OUT mem_write_sel_t;
        COND_BRANCH_OUT : OUT STD_LOGIC;
        HLT_OUT : OUT STD_LOGIC;
        MEMW_OUT : OUT STD_LOGIC;
        MEMR_OUT : OUT STD_LOGIC;
        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        MEM_ADDRESS_SEL_OUT : OUT mem_address_sel_t;
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        REG_WB_EN_OUT : OUT STD_LOGIC;
        JMP_FLAG_SEL_OUT : OUT jmp_flag_sel_t;

        corrected_ccr_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        branch_prediction_out : OUT STD_LOGIC;
        alu_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_out : OUT reg_idx_t;
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY ex1_ex2_register;

ARCHITECTURE rtl OF ex1_ex2_register IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;