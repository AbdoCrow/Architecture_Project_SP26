LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY branch_prediction_unit_tb IS
END ENTITY;

ARCHITECTURE tb OF branch_prediction_unit_tb IS

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    CONSTANT CLK_PERIOD : time := 10 ns;

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL RESET       : STD_LOGIC := '0';
    SIGNAL BRANCH_RESULT : STD_LOGIC := '0';
    SIGNAL COND_BRANCH : STD_LOGIC := '0';
    SIGNAL BRANCH_TAKEN : STD_LOGIC;


BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.branch_prediction_unit
        PORT MAP (
            clk => clk,
            RESET => RESET,
            BRANCH_RESULT => BRANCH_RESULT,
            COND_BRANCH => COND_BRANCH,
            BRANCH_TAKEN => BRANCH_TAKEN
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

        -- Helper procedure for checking predicted branch outcome
        PROCEDURE check_prediction(expected : STD_LOGIC) IS
        BEGIN
            ASSERT BRANCH_TAKEN = expected
                REPORT "Branch prediction mismatch: expected " & STD_LOGIC'image(expected) &
                       ", got " & STD_LOGIC'image(BRANCH_TAKEN)
                SEVERITY error;
        END PROCEDURE;
    BEGIN

        ----------------------------------------------------------------
        -- RESET TEST
        ----------------------------------------------------------------
        REPORT "Starting RESET test";

        reset <= '1';
        WAIT FOR CLK_PERIOD;


        reset <= '0';
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken after reset
        ----------------------------------------------------------------
        -- Branch Taken Test
        ----------------------------------------------------------------
        REPORT "Starting Branch Taken test";
        COND_BRANCH <= '1';
        BRANCH_RESULT <= '1'; -- Branch is taken
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- First time should predict not taken

        COND_BRANCH <= '1';
        BRANCH_RESULT <= '1'; -- Branch is taken
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Second time should predict not taken
     
        COND_BRANCH <= '1';
        BRANCH_RESULT <= '1'; -- Branch is taken
        WAIT FOR CLK_PERIOD;
        check_prediction('1'); -- Third time should predict taken

        ----------------------------------------------------------------
        -- Branch Not Taken Test
        ----------------------------------------------------------------

        REPORT "Starting Branch Not Taken test";
        COND_BRANCH <= '1';
        BRANCH_RESULT <= '0'; -- Branch is not taken
        WAIT FOR CLK_PERIOD;
        check_prediction('1'); -- Should predict taken

        COND_BRANCH <= '1';
        BRANCH_RESULT <= '0'; -- Branch is not taken
        WAIT FOR CLK_PERIOD;
        check_prediction('1'); -- Should predict taken

        COND_BRANCH <= '1';
        BRANCH_RESULT <= '0'; -- Branch is not taken
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken

        COND_BRANCH <= '1';
        BRANCH_RESULT <= '1'; -- Branch is taken
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken


        ----------------------------------------------------------------
        -- Invalid Branch Test (COND_BRANCH = 0)
        ----------------------------------------------------------------

        REPORT "Starting Invalid Branch test";
        COND_BRANCH <= '0'; -- Not a conditional branch
        BRANCH_RESULT <= '1'; -- Branch result should be ignored
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken (old state)

        COND_BRANCH <= '0'; -- Not a conditional branch
        BRANCH_RESULT <= '0'; -- Branch result should be ignored
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken (old state)

        COND_BRANCH <= '0'; -- Not a conditional branch
        BRANCH_RESULT <= '1'; -- Branch result should be ignored
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken (old state)

        COND_BRANCH <= '0'; -- Not a conditional branch
        BRANCH_RESULT <= '1'; -- Branch result should be ignored
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken (old state)

        COND_BRANCH <= '1'; 
        BRANCH_RESULT <= '1'; 
        WAIT FOR CLK_PERIOD;
        check_prediction('0'); -- Should predict not taken as it is weakly not taken 

        COND_BRANCH <= '1'; 
        BRANCH_RESULT <= '0'; 
        WAIT FOR CLK_PERIOD;
        check_prediction('1'); -- Should now predict taken as it is strongly taken 

        REPORT "All tests passed!";
        WAIT;
    END PROCESS;

END ARCHITECTURE;