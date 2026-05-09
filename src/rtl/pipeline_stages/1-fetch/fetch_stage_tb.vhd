LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY fetch_stage_tb IS
END ENTITY fetch_stage_tb;

ARCHITECTURE sim OF fetch_stage_tb IS

    -- ----------------------------------------------------------------
    -- DUT signals
    -- ----------------------------------------------------------------
    SIGNAL clk                   : STD_LOGIC := '0';
    SIGNAL reset                 : STD_LOGIC := '0';

    SIGNAL PC_WRITE_ENABLE       : STD_LOGIC := '0';
    SIGNAL FETCH_STALL           : STD_LOGIC := '0';
    SIGNAL MULTICYCLE_STALL      : STD_LOGIC := '0';
    SIGNAL MULTICYCLE_SEL        : multicycle_sel_t := (OTHERS => '0');
    SIGNAL FLUSH                 : STD_LOGIC := '0';

    SIGNAL CORRECT_PC            : STD_LOGIC := '0';
    SIGNAL correct_pc_value      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    SIGNAL fetched_instruction_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL loaded_pc_in           : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    SIGNAL DECODE_INT_TARGET_IDX : int_idx_t := (OTHERS => '0');

    SIGNAL COND_BRANCH           : STD_LOGIC := '0';
    SIGNAL BRANCH_TAKEN          : STD_LOGIC := '0';
    SIGNAL HLT                   : STD_LOGIC := '0';
    SIGNAL FETCH_MEMORY_HAZARD   : STD_LOGIC := '0';
    SIGNAL ALLOW_HW_INT          : STD_LOGIC := '0';

    SIGNAL pc_out                : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL next_pc_out           : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL instr_out             : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL branch_prediction_out : STD_LOGIC;

    -- ----------------------------------------------------------------
    -- Testbench helpers
    -- ----------------------------------------------------------------
    CONSTANT CLK_PERIOD : TIME := 10 ns;

BEGIN

    -- ----------------------------------------------------------------
    -- DUT instantiation
    -- ----------------------------------------------------------------
    DUT : ENTITY work.fetch_stage
        PORT MAP (
            clk                    => clk,
            reset                  => reset,
            PC_WRITE_ENABLE        => PC_WRITE_ENABLE,
            FETCH_STALL            => FETCH_STALL,
            MULTICYCLE_STALL       => MULTICYCLE_STALL,
            MULTICYCLE_SEL         => MULTICYCLE_SEL,
            FLUSH                  => FLUSH,
            CORRECT_PC             => CORRECT_PC,
            correct_pc_value       => correct_pc_value,
            fetched_instruction_in => fetched_instruction_in,
            loaded_pc_in           => loaded_pc_in,
            DECODE_INT_TARGET_IDX  => DECODE_INT_TARGET_IDX,
            COND_BRANCH            => COND_BRANCH,
            BRANCH_TAKEN           => BRANCH_TAKEN,
            HLT                    => HLT,
            FETCH_MEMORY_HAZARD    => FETCH_MEMORY_HAZARD,
            ALLOW_HW_INT           => ALLOW_HW_INT,
            pc_out                 => pc_out,
            next_pc_out            => next_pc_out,
            instr_out              => instr_out,
            branch_prediction_out  => branch_prediction_out
        );

    -- -------------------------------------------------------------------------
    -- Clock generator
    -- -------------------------------------------------------------------------
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR CLK_PERIOD / 2;
            clk <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
    END PROCESS;
END ARCHITECTURE sim;