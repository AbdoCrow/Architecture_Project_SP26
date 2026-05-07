LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interrupt_handler_tb IS
END ENTITY;

ARCHITECTURE tb OF interrupt_handler_tb IS

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    CONSTANT CLK_PERIOD : time := 10 ns;

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL reset       : STD_LOGIC := '0';
    SIGNAL INT_STARTED   : STD_LOGIC := '0';
    SIGNAL INT_REQUEST   : STD_LOGIC := '0';
    SIGNAL HW_INT_SIGNAL     : STD_LOGIC := '0';
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.interrupt_handler
        PORT MAP (
            clk => clk,
            reset => reset,
            HW_INT_SIGNAL => HW_INT_SIGNAL,
            INT_STARTED => INT_STARTED,
            INT_REQUEST => INT_REQUEST
        );

    --------------------------------------------------------------------
    -- Clock Generation
    --------------------------------------------------------------------
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR CLK_PERIOD / 2;

            clk <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
    END PROCESS;

    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS

        -- Helper procedure for checkiing read data
        PROCEDURE check_INT_REQUEST(expected : STD_LOGIC) IS
        BEGIN
            ASSERT INT_REQUEST = expected
                REPORT "INT_REQUEST value mismatch: expected " & STD_LOGIC'image(expected) &
                       ", got " & STD_LOGIC'image(INT_REQUEST)
                SEVERITY error;
        END PROCEDURE;  
    BEGIN


        -- Test 0: Check reset functionality
        reset <= '1';
        WAIT FOR CLK_PERIOD;
        check_INT_REQUEST('0');

        reset <= '0';

        -- Test 1: Check that INT_REQUEST goes high when HW_INT_SIGNAL is asserted
        HW_INT_SIGNAL <= '1';
        INT_STARTED <= '0';
        WAIT FOR CLK_PERIOD;
        check_INT_REQUEST('1');

        -- Test 2: Check that INT_REQUEST goes low when INT_STARTED is asserted
        INT_STARTED <= '1';
        HW_INT_SIGNAL <= '0';
        WAIT FOR CLK_PERIOD;
        check_INT_REQUEST('0');

        -- Test 3: Check that INT_REQUEST goes high again if HW_INT_SIGNAL is still asserted
        HW_INT_SIGNAL <= '1';
        INT_STARTED <= '0';
        WAIT FOR CLK_PERIOD;
        check_INT_REQUEST('1');

        -- Test 4: Check that INT_REQUEST remains queued until INT_STARTED is asserted
        HW_INT_SIGNAL <= '0';
        INT_STARTED <= '0';
        wait FOR CLK_PERIOD;
        check_INT_REQUEST('1'); -- Should still be high until INT_STARTED remains

        -- Test 5: Check that INT_REQUEST goes low when INT_STARTED is asserted
        INT_STARTED <= '1';
        HW_INT_SIGNAL <= '0';
        WAIT FOR CLK_PERIOD;
        check_INT_REQUEST('0');

        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;