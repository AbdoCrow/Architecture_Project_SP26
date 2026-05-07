LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY fetch_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        PC_ENABLE : IN STD_LOGIC;
        FETCH_STALL : IN STD_LOGIC;
        MULTICYCLE_STALL : IN STD_LOGIC;
        FLUSH : IN STD_LOGIC;

        CORRECT_PC : IN STD_LOGIC;
        correct_pc_value : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        instruction_word_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        predictor_update_en : IN STD_LOGIC;
        predictor_update_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        predictor_update_taken : IN STD_LOGIC;

        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr_address_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_out : OUT STD_LOGIC;
        cond_branch_hint_out : OUT STD_LOGIC;
        uncond_branch_hint_out : OUT STD_LOGIC
    );
END ENTITY fetch_stage;

ARCHITECTURE rtl OF fetch_stage IS
BEGIN
    -- Definition-only skeleton.
    -- TODO: use instruction_word_in(BR_HINT_COND_BIT/BR_HINT_UNCOND_BIT) for early decode.
    -- TODO: connect dynamic branch predictor update and prediction outputs.
END ARCHITECTURE rtl;