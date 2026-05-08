LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY hazard_control_unit_tb IS
END ENTITY;

ARCHITECTURE tb OF hazard_control_unit_tb IS
    CONSTANT CLK_PERIOD : time := 10 ns;
    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL MEMORY : STD_LOGIC := '0';
    SIGNAL FETCH_MEMORY_HAZARD : STD_LOGIC;
    SIGNAL read_reg_1 : reg_idx_t := (OTHERS => '0');
    SIGNAL read_reg_2 : reg_idx_t := (OTHERS => '0');
    SIGNAL ID_EX1_WRITE_ADDRESS : reg_idx_t := (OTHERS => '0');
    SIGNAL EX1_MEMR : STD_LOGIC := '0';
    SIGNAL EX1_EX2_WRITE_ADDRESS : reg_idx_t := (OTHERS => '0');
    SIGNAL EX2_MEMR : STD_LOGIC := '0';
    SIGNAL branch_prediction : STD_LOGIC := '0';
    SIGNAL branch_result : STD_LOGIC := '0';
    SIGNAL CORRECT_PC : STD_LOGIC;
    SIGNAL EX1_PC_WRITE : STD_LOGIC := '0';
    SIGNAL EX2_PC_WRITE : STD_LOGIC := '0';
    SIGNAL MEM_PC_WRITE : STD_LOGIC := '0';
    SIGNAL EX2_COND_BRANCH : STD_LOGIC := '0';
    SIGNAL EX1_COND_BRANCH : STD_LOGIC := '0';
    SIGNAL ID_COND_BRANCH : STD_LOGIC := '0';
    SIGNAL MULTICYCLE_STALL : STD_LOGIC := '0';
    SIGNAL HARDWARE_INTERRUPT : STD_LOGIC := '1';
    SIGNAL ALLOW_HW_INT : STD_LOGIC;
    SIGNAL STALL : STD_LOGIC;
    SIGNAL FLUSH : STD_LOGIC;
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.hazard_control_unit
        PORT MAP (
            MEMORY => MEMORY,
            FETCH_MEMORY_HAZARD => FETCH_MEMORY_HAZARD,
            read_reg_1 => read_reg_1,
            read_reg_2 => read_reg_2,
            ID_EX1_WRITE_ADDRESS => ID_EX1_WRITE_ADDRESS,
            EX1_MEMR => EX1_MEMR,
            EX1_EX2_WRITE_ADDRESS => EX1_EX2_WRITE_ADDRESS,
            EX2_MEMR => EX2_MEMR,
            branch_prediction => branch_prediction,
            branch_result => branch_result,
            CORRECT_PC => CORRECT_PC,
            EX1_PC_WRITE => EX1_PC_WRITE,
            EX2_PC_WRITE => EX2_PC_WRITE,
            MEM_PC_WRITE => MEM_PC_WRITE,
            EX2_COND_BRANCH => EX2_COND_BRANCH,
            EX1_COND_BRANCH => EX1_COND_BRANCH,
            ID_COND_BRANCH => ID_COND_BRANCH,
            MULTICYCLE_STALL => MULTICYCLE_STALL,
            HARDWARE_INTERRUPT => HARDWARE_INTERRUPT,
            ALLOW_HW_INT => ALLOW_HW_INT,
            STALL => STALL,
            FLUSH => FLUSH
        );

    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS
        PROCEDURE check_pc_correction(expectedCorrectPC : STD_LOGIC) IS
        BEGIN
            ASSERT CORRECT_PC = expectedCorrectPC
                REPORT "CORRECT_PC mismatch: expected " & STD_LOGIC'image(expectedCorrectPC) &
                       ", got " & STD_LOGIC'image(CORRECT_PC)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_stall(expectedStall : STD_LOGIC) IS
        BEGIN
            ASSERT STALL = expectedStall
                REPORT "STALL mismatch: expected " & STD_LOGIC'image(expectedStall) &
                       ", got " & STD_LOGIC'image(STALL)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_flush(expectedFlush : STD_LOGIC) IS
        BEGIN
            ASSERT FLUSH = expectedFlush
                REPORT "FLUSH mismatch: expected " & STD_LOGIC'image(expectedFlush) &
                       ", got " & STD_LOGIC'image(FLUSH)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_allow_hw_int(expectedAllowHWInt : STD_LOGIC) IS
        BEGIN
            ASSERT ALLOW_HW_INT = expectedAllowHWInt
                REPORT "ALLOW_HW_INT mismatch: expected " & STD_LOGIC'image(expectedAllowHWInt) &
                       ", got " & STD_LOGIC'image(ALLOW_HW_INT)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_fetch_memory_hazard(expectedFetchMemoryHazard : STD_LOGIC) IS
        BEGIN
            ASSERT FETCH_MEMORY_HAZARD = expectedFetchMemoryHazard
                REPORT "FETCH_MEMORY_HAZARD mismatch: expected " & STD_LOGIC'image(expectedFetchMemoryHazard) &
                       ", got " & STD_LOGIC'image(FETCH_MEMORY_HAZARD)
                SEVERITY ERROR;
        END PROCEDURE;
    BEGIN
        wait for 0 ns; -- Wait for global reset
        -- Test 1: No hazards
        check_pc_correction('0');
        check_stall('0');
        check_flush('0');
        check_allow_hw_int('1');
        check_fetch_memory_hazard('0');
        REPORT "Test 1 passed: No hazards" SEVERITY NOTE;

        -- Test 2: Structural hazard (memory)
        MEMORY <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('1');
        check_stall('0');
        check_flush('0');
        check_allow_hw_int('1');
        check_pc_correction('0');
        REPORT "Test 2 passed: Structural hazard (memory)" SEVERITY NOTE;

        -- Test 3: Load-use hazard from EX1
        read_reg_1 <= "001";
        ID_EX1_WRITE_ADDRESS <= "001";
        EX1_MEMR <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('1');
        check_stall('1');
        check_flush('0');
        check_allow_hw_int('1');
        check_pc_correction('0');
        REPORT "Test 3 passed: Load-use hazard from EX1" SEVERITY NOTE;

        -- Test 4: Load-use hazard from EX2
        read_reg_2 <= "010";
        EX1_MEMR <= '0';
        EX2_MEMR <= '1';
        EX1_EX2_WRITE_ADDRESS <= "010";
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('1');
        check_stall('1');
        check_flush('0');
        check_allow_hw_int('1');
        check_pc_correction('0');
        REPORT "Test 4 passed: Load-use hazard from EX2" SEVERITY NOTE;
        
        -- Test 5: Control hazard (branch misprediction / taken incorrectly)
        MEMORY <= '0';
        EX2_MEMR <= '0';
        
        branch_prediction <= '1';
        branch_result <= '0';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('1');
        check_allow_hw_int('1');
        check_pc_correction('1');
        REPORT "Test 5 passed: Control hazard (branch misprediction / taken incorrectly)" SEVERITY NOTE;

        -- Test 6: Control hazard (branch misprediction / not taken)
        branch_prediction <= '0';
        branch_result <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('1');
        check_allow_hw_int('1');
        check_pc_correction('1');
        REPORT "Test 6 passed: Control hazard (branch misprediction / not taken incorrectly)" SEVERITY NOTE;
        -- Test 7: Interrupt hazard (conditional branch in EX1)
        branch_prediction <= '0';
        branch_result <= '0';

        EX1_COND_BRANCH <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('0');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 7 passed: Interrupt hazard (conditional branch in EX1)" SEVERITY NOTE; 

        -- Test 8: Interrupt hazard (conditional branch in EX2)
        EX1_COND_BRANCH <= '0';
        EX2_COND_BRANCH <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('0');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 8 passed: Interrupt hazard (conditional branch in EX2)" SEVERITY NOTE;

        -- Test 9: Interrupt hazard (conditional branch in ID)
        EX2_COND_BRANCH <= '0';
        ID_COND_BRANCH <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('0');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 9 passed: Interrupt hazard (conditional branch in ID)" SEVERITY NOTE;

        -- Test 10: Interrupt hazard (multicycle stall in fetch)
        ID_COND_BRANCH <= '0';
        MULTICYCLE_STALL <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('0');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 10 passed: Interrupt hazard (multicycle stall in fetch)" SEVERITY NOTE;

        -- Test 11: Control Hazard (PC write in EX1)
        MULTICYCLE_STALL <= '0';
        HARDWARE_INTERRUPT <= '0';
        EX1_PC_WRITE <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('1');
        check_flush('0');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 11 passed: Control Hazard (PC write in EX1)" SEVERITY NOTE;

        -- Test 12: Control Hazard (PC write in EX2)
        EX1_PC_WRITE <= '0';
        EX2_PC_WRITE <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('1');
        check_flush('0');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 12 passed: Control Hazard (PC write in EX2)" SEVERITY NOTE;

        -- Test 13: Control Hazard (PC write in MEM)
        EX2_PC_WRITE <= '0';
        MEM_PC_WRITE <= '1';
        wait for CLK_PERIOD;
        check_fetch_memory_hazard('0');
        check_stall('0');
        check_flush('1');
        check_allow_hw_int('0');
        check_pc_correction('0');
        REPORT "Test 13 passed: Control Hazard (PC write in MEM)" SEVERITY NOTE;

        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;