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
    SIGNAL ALUOP : alu_op_t;
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
            ALUOP => ALUOP,
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
                REPORT "Result1 value mismatch: expected " & integer'image(to_integer(signed(result1_expected))) &
                       ", got " & integer'image(to_integer(signed(Result1)))
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
        ALUOP <= ALU_OP_ADD; -- ADD operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000008", x"00000003", "000"); -- Expect 8, no flags set
        REPORT "Test 1 passed: ADD operation" SEVERITY NOTE;

        -- Test 2: SUB operation with negative result
        A <= x"00000003"; -- 3
        B <= x"00000005"; -- 5
        prev_flags <= "000"; -- No flags set
        ALUOP <= ALU_OP_SUB; -- SUB operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"FFFFFFFE", x"00000005", "011"); -- Expect -2, negative and carry flags set
        REPORT "Test 2 passed: SUB operation with negative result" SEVERITY NOTE;

        -- Test 3: AND operation
        A <= x"0000000F"; -- 15
        B <= x"00000003"; -- 3
        prev_flags <= "000"; -- No flags set
        ALUOP <= ALU_OP_AND; -- AND operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000003", x"00000003", "000"); -- Expect 3, no flags set
        REPORT "Test 3 passed: AND operation" SEVERITY NOTE;

         -- Test 4: INC operation with overflow
        A <= x"FFFFFFFF"; -- -1
        B <= x"00000000"; -- 0 (ignored for INC)
        prev_flags <= "000"; -- No flags set
        ALUOP <= ALU_OP_INC_A; -- INC operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000000", x"00000000", "101"); -- Expect 0, zero and carry flags set
        REPORT "Test 4 passed: INC operation with overflow" SEVERITY NOTE;

         -- Test 5: NOT operation
        A <= x"0000000F"; -- 15
        B <= x"00000000"; -- 0 (ignored for NOT)
        prev_flags <= "000"; -- No flags set
        ALUOP <= ALU_OP_NOT_A; -- NOT operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"FFFFFFF0", x"00000000", "010"); -- Expect -16, negative flag set
        REPORT "Test 5 passed: NOT operation" SEVERITY NOTE;
        -- Test 6: PASS Operation
        A <= x"12345678"; -- Arbitrary value
        B <= x"55678910"; -- Arbitrary value
        prev_flags <= "000"; -- No flags set
        ALUOP <= ALU_OP_PASS; -- PASS operation
        WAIT FOR CLK_PERIOD; 
        check_alu_results(x"12345678", x"55678910", "000"); -- Expect A and B to be passed through, no flags set
        REPORT "Test 6 passed: PASS operation" SEVERITY NOTE;

        -- Test 7: NOP Operation
        A <= x"12345678"; -- Arbitrary value
        B <= x"55678910"; -- Arbitrary value
        prev_flags <= "000"; -- No flags set
        ALUOP <= ALU_OP_NOP; -- NOP operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000000", x"55678910", "000"); -- Expect no change, no flags set
        REPORT "Test 7 passed: NOP operation" SEVERITY NOTE;

        -- Test 8: SETC Operation
        A <= x"00000000"; -- 0 (ignored for SETC)
        B <= x"00000000"; -- 0 (ignored for SETC)
        prev_flags <= "100"; --  Zero flag set
        ALUOP <= ALU_OP_SETC; -- SETC operation
        WAIT FOR CLK_PERIOD;
        check_alu_results(x"00000000", x"00000000", "101"); -- Expect no change, carry flag set
        REPORT "Test 8 passed: SETC operation" SEVERITY NOTE;

        -- TODO: Add more tests for other ALU operations and edge cases
        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;