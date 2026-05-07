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
    -- Combinational logic to determine if a jump should be taken based on the input flags and branch condition.
    process(flags_in, COND_BRANCH, JMP_FLAG_SEL)
    begin
        if COND_BRANCH = '1' then
            case JMP_FLAG_SEL is
                when JMP_FLAG_Z =>  -- JZ: Jump if zero flag is set
                    branch_result <= flags_in(ZERO_FLAG_BIT); 
                when JMP_FLAG_N =>  -- JN: Jump if negative flag is set
                    branch_result <= flags_in(NEGATIVE_FLAG_BIT); 
                when JMP_FLAG_C =>  -- JC: Jump if carry flag is set
                    branch_result <= flags_in(CARRY_FLAG_BIT);
                when others =>
                    branch_result <= '0';  -- Default case, should not jump
            end case;
        else
            branch_result <= '0';  -- Not a conditional branch, so do not jump
        end if;
    end process;    
END ARCHITECTURE rtl;