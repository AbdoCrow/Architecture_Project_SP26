LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY execute2_stage IS
    PORT (
        COND_BRANCH_IN : IN STD_LOGIC;
        JMP_FLAG_SEL_IN : IN jmp_flag_sel_t;

        UPDATE_FLAGS_IN : IN STD_LOGIC;
        ALU_FLAGS_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        base_reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;
        
        branch_result_out : OUT STD_LOGIC;
        branch_prediction_out : OUT STD_LOGIC;
        correct_pc_value_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_adr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        interrupt_adr_out : OUT int_idx_t;
        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        ALU_FLAGS_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY execute2_stage;

ARCHITECTURE rtl OF execute2_stage IS
BEGIN
 
    -- control signals that will path through should not be registered here
jump_detection_unit: entity work.jump_detection_unit
    PORT MAP (
        flags_in  => corrected_ccr_flags_in,
        COND_BRANCH => COND_BRANCH_IN,
        JMP_FLAG_SEL => JMP_FLAG_SEL_IN,
        branch_result => branch_result_out
    );
    correct_pc_value_out <= next_pc_in when branch_prediction_in = '1' else  (15 downto 0 => '0') & imm_offset_in;
    mem_adr_out <= std_logic_vector(unsigned(base_reg_data_in) + unsigned((15 downto 0 => '0') & imm_offset_in));
    interrupt_adr_out <= imm_offset_in(1 downto 0);  
    branch_prediction_out <= branch_prediction_in;
    -- UPDATE_FLAGS_OUT <= UPDATE_FLAGS_IN;
    -- ALU_FLAGS_OUT <= ALU_FLAGS_IN;
    UPDATE_FLAGS_OUT <= UPDATE_FLAGS_IN OR COND_BRANCH_IN;
    ALU_FLAGS_OUT(ZERO_FLAG_BIT) <= ALU_FLAGS_IN(ZERO_FLAG_BIT) WHEN JMP_FLAG_SEL_IN /= JMP_FLAG_Z ELSE '0';
    ALU_FLAGS_OUT(NEGATIVE_FLAG_BIT) <= ALU_FLAGS_IN(NEGATIVE_FLAG_BIT) WHEN JMP_FLAG_SEL_IN /= JMP_FLAG_N ELSE '0';
    ALU_FLAGS_OUT(CARRY_FLAG_BIT) <= ALU_FLAGS_IN(CARRY_FLAG_BIT) WHEN JMP_FLAG_SEL_IN /= JMP_FLAG_C ELSE '0';

END ARCHITECTURE rtl;