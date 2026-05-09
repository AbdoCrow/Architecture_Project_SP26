LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY fetch_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        PC_WRITE_ENABLE : IN STD_LOGIC;
        FETCH_STALL : IN STD_LOGIC;
        MULTICYCLE_STALL : IN STD_LOGIC;
        MULTICYCLE_SEL : IN multicycle_sel_t;
        FLUSH : IN STD_LOGIC;

        CORRECT_PC : IN STD_LOGIC;
        correct_pc_value : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        fetched_instruction_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        loaded_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        DECODE_INT_TARGET_IDX : IN int_idx_t;

        COND_BRANCH : IN STD_LOGIC;
        BRANCH_TAKEN : IN STD_LOGIC;
        HLT : IN STD_LOGIC;
        FETCH_MEMORY_HAZARD : IN STD_LOGIC;
        ALLOW_HW_INT: IN STD_LOGIC;

        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_out : OUT STD_LOGIC
    );
END ENTITY fetch_stage;

ARCHITECTURE rtl OF fetch_stage IS
BEGIN
-- include pc reg, multicycle instruction unit and branch prediction unit
END ARCHITECTURE rtl;