LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_reg_tb IS
END ENTITY;

ARCHITECTURE tb OF pc_reg_tb IS

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    CONSTANT CLK_PERIOD : time := 10 ns;

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL enable      : STD_LOGIC := '0';
    SIGNAL pc_in       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_out      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.pc_reg
        PORT MAP (
            clk => clk,
            enable => enable,
            pc_in => pc_in,
            pc_out => pc_out
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
        PROCEDURE check_pc(expected : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            ASSERT pc_out = expected
                REPORT "PC value mismatch: expected " & integer'image(to_integer(unsigned(expected))) &
                       ", got " & integer'image(to_integer(unsigned(pc_out)))
                SEVERITY error;
        END PROCEDURE;
    BEGIN
        -- Test 1: Check that PC holds value when enable is low
        pc_in <= X"00000000";
        enable <= '0';
        WAIT FOR CLK_PERIOD;
        check_pc(X"00000000");

        -- Test 2: Check that PC updates when enable is high
        pc_in <= X"12345678";
        enable <= '1';
        WAIT FOR CLK_PERIOD;
        check_pc(X"12345678");

        -- Test 3: Check that PC holds value when enable goes low again
        enable <= '0';
        WAIT FOR CLK_PERIOD;
        check_pc(X"12345678");

        -- Test 4: Check another update with enable high
        pc_in <= X"DEADBEEF";
        enable <= '1';
        WAIT FOR CLK_PERIOD;
        check_pc(X"DEADBEEF");

        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;