LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file_tb IS
END ENTITY;

ARCHITECTURE tb OF register_file_tb IS

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
    SIGNAL WRITE_ENABLE_1 : STD_LOGIC := '0';
    SIGNAL write_addr_1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WRITE_ENABLE_2 : STD_LOGIC := '0';
    SIGNAL write_addr_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_addr_1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_addr_2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.register_file
        PORT MAP (
            clk => clk,
            RESET => RESET,
            WRITE_ENABLE_1 => WRITE_ENABLE_1,
            write_addr_1 => write_addr_1,
            write_data_1 => write_data_1,
            WRITE_ENABLE_2 => WRITE_ENABLE_2,
            write_addr_2 => write_addr_2,
            write_data_2 => write_data_2,
            read_addr_1 => read_addr_1,
            read_addr_2 => read_addr_2,
            read_data_1 => read_data_1,
            read_data_2 => read_data_2
        );

    --------------------------------------------------------------------
    -- Clock Generation
    --------------------------------------------------------------------
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
        -- drive on rising edge, as file writes on falling edge
            clk <= '1';
            WAIT FOR CLK_PERIOD / 2;

            clk <= '0';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
    END PROCESS;

    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS

        -- Helper procedure for checkiing read data
        PROCEDURE check_read_data(expected_1 : STD_LOGIC_VECTOR(31 DOWNTO 0); expected_2 : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            ASSERT read_data_1 = expected_1
                REPORT "Read data 1 mismatch: expected " & integer'image(to_integer(unsigned(expected_1))) &
                       ", got " & integer'image(to_integer(unsigned(read_data_1)))
                SEVERITY error;

            ASSERT read_data_2 = expected_2
                REPORT "Read data 2 mismatch: expected " & integer'image(to_integer(unsigned(expected_2))) &
                       ", got " & integer'image(to_integer(unsigned(read_data_2)))
                SEVERITY error;
        END PROCEDURE;
    BEGIN

        ----------------------------------------------------------------
        -- RESET TEST
        ----------------------------------------------------------------
        REPORT "Starting RESET test";

        reset <= '1';
        WAIT FOR CLK_PERIOD;

        check_read_data((OTHERS => '0'), (OTHERS => '0'));  -- All registers should be 0 after reset

        reset <= '0';
        WAIT FOR CLK_PERIOD;

        ----------------------------------------------------------------
        -- Write to all registers and read back
        ----------------------------------------------------------------
        REPORT "Starting write/read test";
        -- Write to all registers using both write ports and read in same cycle
        FOR i IN 0 TO 7 LOOP
            write_addr_1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3));
            read_addr_1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3));
            write_data_1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i + 100, 32));  -- Write unique data to each register
            WRITE_ENABLE_1 <= '1';

            write_addr_2 <= STD_LOGIC_VECTOR(TO_UNSIGNED((i + 4) MOD 8, 3));  -- Write to different registers with port 2
            read_addr_2 <= STD_LOGIC_VECTOR(TO_UNSIGNED((i + 4) MOD 8, 3));
            write_data_2 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i + 200, 32));
            WRITE_ENABLE_2 <= '1';
            WAIT FOR CLK_PERIOD;
            WRITE_ENABLE_1 <= '0';
            WRITE_ENABLE_2 <= '0';
            check_read_data(write_data_1, write_data_2);
            WAIT FOR CLK_PERIOD;
        END LOOP;

        REPORT "All tests passed!";
        WAIT;
    END PROCESS;

END ARCHITECTURE;