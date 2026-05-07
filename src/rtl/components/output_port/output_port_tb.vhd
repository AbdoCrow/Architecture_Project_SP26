LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY output_port_tb IS
END ENTITY;

ARCHITECTURE tb OF output_port_tb IS

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    CONSTANT CLK_PERIOD : time := 10 ns;

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL enable      : STD_LOGIC := '0';
    SIGNAL output_port_in       : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL output_port_out      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL reset       : STD_LOGIC := '0';
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.output_port
        PORT MAP (
            clk => clk,
            enable => enable,
            output_port_in => output_port_in,
            output_port_out => output_port_out,
            reset => reset
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
        PROCEDURE check_output_port(expected : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            ASSERT output_port_out = expected
                REPORT "Output port value mismatch: expected " & integer'image(to_integer(unsigned(expected))) &
                       ", got " & integer'image(to_integer(unsigned(output_port_out)))
                SEVERITY error;
        END PROCEDURE;
    BEGIN


        -- Test 0: Check reset functionality
        reset <= '1';
        WAIT FOR CLK_PERIOD;
        reset <= '0';
        check_output_port(X"00000000");
        -- Test 1: Check that Output port holds value when enable is low
        output_port_in <= X"00100003";
        enable <= '0';
        WAIT FOR CLK_PERIOD;
        check_output_port(X"00100003");

        -- Test 2: Check that Output port updates when enable is high
        output_port_in <= X"12345678";
        enable <= '1';
        WAIT FOR CLK_PERIOD;
        check_output_port(X"12345678");

        -- Test 3: Check that Output port holds value when enable goes low again
        enable <= '0';
        WAIT FOR CLK_PERIOD;
        check_output_port(X"12345678");

        -- Test 4: Check another update with enable high
        output_port_in <= X"DEADBEEF";
        enable <= '1';
        WAIT FOR CLK_PERIOD;
        check_output_port(X"DEADBEEF");

        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;