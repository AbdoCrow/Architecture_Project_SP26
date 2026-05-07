LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY jump_detection_unit IS
    PORT (
        flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        COND_BRANCH : IN STD_LOGIC;
        JMP_FLAG_SEL : IN jmp_flag_sel_t;
        branch_result : OUT STD_LOGIC
    );
END ENTITY jump_detection_unit;

ARCHITECTURE rtl OF jump_detection_unit IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;