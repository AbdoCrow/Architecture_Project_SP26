LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
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
        branch_prediction_out : OUT STD_LOGIC;  
        IF_COND_BRANCH : OUT STD_LOGIC
    );
END ENTITY fetch_stage;

ARCHITECTURE rtl OF fetch_stage IS
SIGNAL PC_ENABLE : STD_LOGIC;
SIGNAL NEXT_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
Signal fetch_cond_branch : STD_LOGIC;
Signal fetch_uncond_branch : STD_LOGIC;
SIGNAL generated_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
Signal branch_prediction : STD_LOGIC;
Signal PC_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PC_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL selected_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
-- include pc reg, multicycle instruction unit and branch prediction unit
pc_out <= PC_VALUE;
next_pc_out <= NEXT_PC;
branch_prediction_out <= branch_prediction;
fetch_cond_branch <= selected_instruction(BR_HINT_COND_BIT);
fetch_uncond_branch <= selected_instruction(BR_HINT_UNCOND_BIT);
PC_ENABLE <= NOT (FETCH_STALL OR MULTICYCLE_STALL OR FETCH_MEMORY_HAZARD  OR ALLOW_HW_INT OR HLT) OR CORRECT_PC OR PC_WRITE_ENABLE;
immediate <= (15 downto 0 => '0') & selected_instruction(15 DOWNTO 0);
instr_out <= selected_instruction;
NEXT_PC <= std_logic_vector((unsigned(PC_VALUE) + 1));
PC_IN <= correct_pc_value WHEN CORRECT_PC = '1' else
         loaded_pc_in WHEN PC_WRITE_ENABLE = '1' OR reset = '1' else
         immediate WHEN (fetch_cond_branch = '1' AND branch_prediction = '1') OR fetch_uncond_branch = '1' else
         NEXT_PC ;
selected_instruction <= generated_instruction WHEN MULTICYCLE_STALL = '1' AND FLUSH = '0' else
                        OPCODE_INT & (25 downto 0 => '0') & '1' WHEN ALLOW_HW_INT = '1' AND FLUSH = '0' AND MULTICYCLE_STALL = '0' else
                        fetched_instruction_in WHEN (NOT MULTICYCLE_STALL = '1' AND NOT FLUSH = '1' AND NOT FETCH_MEMORY_HAZARD = '1' AND NOT ALLOW_HW_INT = '1') else    
                        (OTHERS => '0'); -- NOP
IF_COND_BRANCH <= fetch_cond_branch;
pc_inst : entity work.pc_reg
    PORT MAP (
        clk => clk,
        enable => PC_ENABLE,
        pc_in => PC_IN,
        pc_out => PC_VALUE
    );
multicycle_unit : entity work.multicycle_instruction_unit
    PORT MAP (
        MULTICYCLE_SEL => MULTICYCLE_SEL,
        INT_TARGET_INDEX => DECODE_INT_TARGET_IDX,
        GENERATED_INSTRUCTION => generated_instruction
    );
branch_predictor : entity work.branch_prediction_unit
    PORT MAP (
        clk => clk,
        reset => reset,
        BRANCH_RESULT => BRANCH_TAKEN,
        COND_BRANCH => COND_BRANCH,
        BRANCH_TAKEN => branch_prediction
    );
END ARCHITECTURE rtl;