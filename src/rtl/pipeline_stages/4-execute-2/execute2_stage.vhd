LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY execute2_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        COND_BRANCH_IN : IN STD_LOGIC;
        JMP_FLAG_SEL_IN : IN jmp_flag_sel_t;


        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        base_reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;
        
        branch_result_out : OUT STD_LOGIC;
        branch_prediction_out : OUT STD_LOGIC;
        correct_pc_value_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_adr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        interrupt_adr_out : OUT int_idx_t
    );
END ENTITY execute2_stage;

ARCHITECTURE rtl OF execute2_stage IS
BEGIN
 
    -- control signals that will path through should not be registered here
END ARCHITECTURE rtl;