LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY ALU_tb IS
END ENTITY;

ARCHITECTURE tb OF ALU_tb IS
    CONSTANT CLK_PERIOD : time := 10 ns;
    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL A, B : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL prev_flags,output_flags : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ALUOp : ALU_OP_TYPE;
    SIGNAL Result1, Result2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.ALU
        PORT MAP (
            A => A,
            B => B,
            prev_flags => prev_flags,
            output_flags => output_flags,
            ALUOp => ALUOp,
            Result1 => Result1,
            Result2 => Result2
        );


    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS
        -- Helper procedure for checkiing read data
        PROCEDURE check_alu_results(result1_expected: STD_LOGIC_VECTOR(31 DOWNTO 0); result2_expected: STD_LOGIC_VECTOR(31 DOWNTO 0); flags_expected: STD_LOGIC_VECTOR(2 DOWNTO 0)) IS
        BEGIN
            ASSERT Result1 = result1_expected
                REPORT "Result1 value mismatch: expected " & integer'image(to_integer(unsigned(result1_expected))) &
                       ", got " & integer'image(to_integer(unsigned(Result1)))
                SEVERITY error;
            ASSERT Result2 = result2_expected
                REPORT "Result2 value mismatch: expected " & integer'image(to_integer(unsigned(result2_expected))) &
                       ", got " & integer'image(to_integer(unsigned(Result2)))
                SEVERITY error;
            ASSERT output_flags = flags_expected
                REPORT "output_flags value mismatch: expected " & integer'image(to_integer(unsigned(flags_expected))) &
                       ", got " & integer'image(to_integer(unsigned(output_flags)))
                SEVERITY error;
        END PROCEDURE;  
    BEGIN
        -- Test 1: ADD operation
        A <= x"00000005"; -- 5
        B <= x"00000003"; -- 3
        prev_flags <= "000"; -- No flags set
        ALUOp <= ALU_OP_ADD; -- ADD operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000008", x"00000000", "000"); -- Expect 8, no flags set

        -- Test 2: SUB operation with negative result
        A <= x"00000003"; -- 3
        B <= x"00000005"; -- 5
        prev_flags <= "000"; -- No flags set
        ALUOp <= ALU_OP_SUB; -- SUB operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"FFFFFFFD", x"00000000", "001"); -- Expect -2, zero flag set

        -- Test 3: AND operation
        A <= x"0000000F"; -- 15
        B <= x"00000003"; -- 3
        prev_flags <= "000"; -- No flags set
        ALUOp <= ALU_OP_AND; -- AND operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000003", x"00000000", "001"); -- Expect 3, zero flag set
        
         -- Test 4: INC operation with overflow
        A <= x"FFFFFFFF"; -- -1
        B <= x"00000000"; -- 0 (ignored for INC)
        prev_flags <= "000"; -- No flags set
        ALUOp <= ALU_OP_INC_A; -- INC operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000000", x"00000000", "011"); -- Expect 0, zero and carry flags set

         -- Test 5: NOT operation
        A <= x"0000000F"; -- 15
        B <= x"00000000"; -- 0 (ignored for NOT)
        prev_flags <= "000"; -- No flags set
        ALUOp <= ALU_OP_NOT_A; -- NOT operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"FFFFFFF0", x"00000000", "111"); -- Expect -16, all flags set

        -- TODO: Add more tests for other ALU operations and edge cases
        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;