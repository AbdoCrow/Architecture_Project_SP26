LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY jump_detection_unit_tb IS
END ENTITY;

ARCHITECTURE tb OF jump_detection_unit_tb IS
    CONSTANT CLK_PERIOD : time := 10 ns;
    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL flags_in : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL COND_BRANCH : STD_LOGIC;
    SIGNAL JMP_FLAG_SEL : jmp_flag_sel_t;
    SIGNAL branch_result : STD_LOGIC;
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.jump_detection_unit
        PORT MAP (
            flags_in => flags_in,
            COND_BRANCH => COND_BRANCH,
            JMP_FLAG_SEL => JMP_FLAG_SEL,
            branch_result => branch_result
        );

    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS
        -- Helper procedure for checkiing read data
        PROCEDURE check_jump_result(expected: STD_LOGIC) IS
        BEGIN
            ASSERT branch_result = expected
                REPORT "branch_result value mismatch: expected " & character'image(expected) &
                       ", got " & character'image(branch_result)
                SEVERITY error;
        END PROCEDURE;  
    BEGIN
        WAIT; -- Wait indefinitely after tests
        -- Test 1: JZ with zero flag set
        flags_in <= "001"; -- Zero flag set
        COND_BRANCH <= '1';
        JMP_FLAG_SEL <= JMP_FLAG_Z;
        check_jump_result('1'); -- Expect jump to be taken
        WAIT FOR CLK_PERIOD;
        -- Test 2: JZ with zero flag not set
        flags_in <= "000"; -- No flags set
        check_jump_result('0'); -- Expect jump not to be taken
        WAIT FOR CLK_PERIOD;
        -- Test 3: JN with negative flag set
        flags_in <= "010"; -- Negative flag set
        JMP_FLAG_SEL <= JMP_FLAG_N;
        check_jump_result('1'); -- Expect jump to be taken
        WAIT FOR CLK_PERIOD;
        -- Test 4: JN with negative flag not set
        flags_in <= "000"; -- No flags set
        check_jump_result('0'); -- Expect jump not to be taken
        WAIT FOR CLK_PERIOD;
        -- Test 5: JC with carry flag set
        flags_in <= "100"; -- Carry flag set
        JMP_FLAG_SEL <= JMP_FLAG_C;
        check_jump_result('1'); -- Expect jump to be taken
        WAIT FOR CLK_PERIOD;
        -- Test 6: JC with carry flag not set
        flags_in <= "000"; -- No flags set
        check_jump_result('0'); -- Expect jump not to be taken
        WAIT FOR CLK_PERIOD;
        -- Test 7: Not a conditional branch
        COND_BRANCH <= '0';
        check_jump_result('0'); -- Expect jump not to be taken regardless of flags
        WAIT FOR CLK_PERIOD;

        
    END PROCESS;
END ARCHITECTURE;