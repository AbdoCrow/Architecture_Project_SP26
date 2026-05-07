LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY hazard_control_unit IS
    PORT (
        MEMORY : IN STD_LOGIC;

        read_reg_1 : IN reg_idx_t;
        read_reg_2 : IN reg_idx_t;
        ID_EX1_WRITE_ADDRESS : IN reg_idx_t;
        EX1_MEMR : IN STD_LOGIC;
        EX1_EX2_WRITE_ADDRESS : IN reg_idx_t;
        EX2_MEMR : IN STD_LOGIC;

        branch_prediction : IN STD_LOGIC;
        branch_result : IN STD_LOGIC;
        branch_target_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_on_not_taken : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        EX2_COND_BRANCH : IN STD_LOGIC;
        EX1_COND_BRANCH : IN STD_LOGIC;
        ID_COND_BRANCH : IN STD_LOGIC;

        MULTICYCLE_STALL : IN STD_LOGIC;
        HARDWARE_INTERRUPT : IN STD_LOGIC;

        EX1_PC_WRITE : IN STD_LOGIC;
        EX2_PC_WRITE : IN STD_LOGIC;
        MEM_PC_WRITE : IN STD_LOGIC;

        FETCH_MEMORY_HAZARD : OUT STD_LOGIC;
        CORRECT_PC : OUT STD_LOGIC;
        ALLOW_HW_INT : OUT STD_LOGIC;
        BUBBLE : OUT STD_LOGIC;
        STALL : OUT STD_LOGIC;
        FLUSH : OUT STD_LOGIC;
        correct_pc_value : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY hazard_control_unit;

ARCHITECTURE rtl OF hazard_control_unit IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;