LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sp_unit_tb IS
END ENTITY;

ARCHITECTURE tb OF sp_unit_tb IS

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    CONSTANT CLK_PERIOD : time := 10 ns;
    CONSTANT STACK_START_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000FFF";

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL RESET       : STD_LOGIC := '0';
    SIGNAL SP_EN       : STD_LOGIC := '0';
    SIGNAL SP_OP       : STD_LOGIC := '0';
    SIGNAL HLT         : STD_LOGIC := '0';

    SIGNAL sp          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sp_plus_1   : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.sp_unit
        GENERIC MAP (
            STACK_START_ADDR => STACK_START_ADDR
        )
        PORT MAP (
            clk         => clk,
            RESET       => RESET,
            SP_EN       => SP_EN,
            SP_OP       => SP_OP,
            HLT         => HLT,
            sp          => sp,
            sp_plus_1   => sp_plus_1
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

        -- Helper procedure for checking SP value
        PROCEDURE check_sp(expected : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            ASSERT sp = expected
                REPORT "SP mismatch. Expected: "
                    & integer'image(to_integer(unsigned(expected)))
                    & " Got: "
                    & integer'image(to_integer(unsigned(sp)))
                SEVERITY error;
        END PROCEDURE;
        PROCEDURE check_sp_plus_1(expected : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            ASSERT sp_plus_1 = expected
                REPORT "SP+1 mismatch. Expected: "
                    & integer'image(to_integer(unsigned(expected)))
                    & " Got: "
                    & integer'image(to_integer(unsigned(sp_plus_1)))
                SEVERITY error;
        END PROCEDURE;

    BEGIN

        ----------------------------------------------------------------
        -- RESET TEST
        ----------------------------------------------------------------
        REPORT "Starting RESET test";

        reset <= '1';
        WAIT FOR CLK_PERIOD;

        check_sp(STACK_START_ADDR);

        reset <= '0';
        WAIT FOR CLK_PERIOD;

        ----------------------------------------------------------------
        -- PUSH TEST (SP decrements)
        ----------------------------------------------------------------
        REPORT "Starting PUSH test";

        SP_EN <= '1';
        SP_OP <= '0';  -- push => decrement SP

        WAIT FOR CLK_PERIOD;

        check_sp(X"00000FFE");
        check_sp_plus_1(X"00000FFF");

        WAIT FOR CLK_PERIOD;

        check_sp(X"00000FFD");
        check_sp_plus_1(X"00000FFE");

        WAIT FOR CLK_PERIOD;

        check_sp(X"00000FFC");
        check_sp_plus_1(X"00000FFD");

        ----------------------------------------------------------------
        -- POP TEST (SP increments)
        ----------------------------------------------------------------
        REPORT "Starting POP test";

        SP_OP <= '1';  -- pop => increment SP

        WAIT FOR CLK_PERIOD;

        check_sp(X"00000FFD");
        check_sp_plus_1(X"00000FFE");

        WAIT FOR CLK_PERIOD;

        check_sp(X"00000FFE");
        check_sp_plus_1(X"00000FFF");

        ----------------------------------------------------------------
        -- DISABLED TEST (SP_EN = 0)
        ----------------------------------------------------------------
        REPORT "Starting DISABLED test";

        SP_EN <= '0';

        WAIT FOR CLK_PERIOD;

        check_sp(X"00000FFE");
        check_sp_plus_1(X"00000FFF");

        ----------------------------------------------------------------
        -- HALTING TEST (HLT = 1)
        ----------------------------------------------------------------

        REPORT "Checking for HLT signal to disable SP updates";

        HLT <= '1';
        SP_EN <= '1';
        SP_OP <= '0';  -- Attempt to push

        WAIT FOR CLK_PERIOD;
        check_sp(X"00000FFE");  -- SP should not change due to HLT
        check_sp_plus_1(X"00000FFF");  -- sp+1 should still reflect current SP + 1

        WAIT FOR CLK_PERIOD;
        check_sp(X"00000FFE");  -- SP should still not change
        check_sp_plus_1(X"00000FFF");  -- sp+1 should still reflect current SP + 1

        SP_OP <= '1';  -- Attempt to pop
        WAIT FOR CLK_PERIOD;
        check_sp(X"00000FFE");  -- SP should still not change
        check_sp_plus_1(X"00000FFF");  -- sp+1 should still reflect current SP + 1

        RESET <= '1';  -- Reset should still work even if HLT is active
        WAIT FOR CLK_PERIOD;
        check_sp(STACK_START_ADDR);  -- SP should reset to initial value

        REPORT "All tests passed successfully";
        WAIT;
        
        ----------------------------------------------------------------
        -- END SIMULATION
        ----------------------------------------------------------------


    END PROCESS;

END ARCHITECTURE;