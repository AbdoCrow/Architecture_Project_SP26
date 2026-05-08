LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY multicycle_instruction_unit IS
    PORT (
        MULTICYCLE_SEL : IN multicycle_sel_t;
        INT_TARGET_INDEX : IN int_idx_t;
        GENERATED_INSTRUCTION : OUT std_logic_vector(31 downto 0)
    );
END ENTITY multicycle_instruction_unit;

ARCHITECTURE rtl OF multicycle_instruction_unit IS
BEGIN
    PROCESS(MULTICYCLE_SEL, INT_TARGET_INDEX)
    BEGIN
        CASE MULTICYCLE_SEL IS
            WHEN MULTICYCLE_RET_STEP =>
                GENERATED_INSTRUCTION <= OPCODE_RET & (27 downto 0 => '0'); -- OPCODE_RET with rest of bits 0
            WHEN MULTICYCLE_INT2 => 
                GENERATED_INSTRUCTION <= OPCODE_INT2 & (27 downto 2 => '0') & INT_TARGET_INDEX; -- OPCODE_INT2 + int_idx in bits [1:0]
            WHEN MULTICYCLE_INT3 => 
                GENERATED_INSTRUCTION <= OPCODE_INT3 & (27 downto 2 => '0') & INT_TARGET_INDEX; -- OPCODE_INT3 + int_idx in bits [1:0]
            WHEN OTHERS =>-- No multicycle operation; output is don't care (set to NOP)
                GENERATED_INSTRUCTION <= (OTHERS => '0');
        END CASE;
    END PROCESS;
END ARCHITECTURE rtl;