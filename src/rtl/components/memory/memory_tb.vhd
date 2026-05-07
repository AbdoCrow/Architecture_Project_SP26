LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_tb IS
END ENTITY;

ARCHITECTURE tb OF memory_tb IS

    --------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------
    CONSTANT CLK_PERIOD : time := 10 ns;

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL MEMORY_WRITE_EN : STD_LOGIC := '0';
    SIGNAL MEMORY_READ_EN : STD_LOGIC := '0';
    SIGNAL mem_addr    : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RESET       : STD_LOGIC := '0';
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.memory
        PORT MAP (
            clk => clk,
            RESET => RESET,
            mem_addr => mem_addr,
            mem_data_in => mem_data_in,
            mem_data_out => mem_data_out,
            MEMORY_READ_EN => MEMORY_READ_EN,
            MEMORY_WRITE_EN => MEMORY_WRITE_EN
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
        PROCEDURE check_read_data(expected : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            ASSERT mem_data_out = expected
                REPORT "Read data mismatch: expected " & integer'image(to_integer(unsigned(expected))) &
                       ", got " & integer'image(to_integer(unsigned(mem_data_out)))
                SEVERITY error;
        END PROCEDURE;
    BEGIN
        REPORT "Starting write/read test";
        -- Write to memory
        mem_addr <= X"000";
        mem_data_in <= X"DEADBEEF";
        MEMORY_WRITE_EN <= '1';
        MEMORY_READ_EN <= '0';
        RESET <= '0';
        WAIT FOR CLK_PERIOD;
        -- Read from memory
        MEMORY_WRITE_EN <= '0';
        MEMORY_READ_EN <= '1';
        mem_addr <= X"000";
        WAIT FOR CLK_PERIOD;
        check_read_data(X"DEADBEEF");

        mem_addr <= X"001";
        mem_data_in <= X"CAFEBABE";
        MEMORY_WRITE_EN <= '1';
        MEMORY_READ_EN <= '0';
        WAIT FOR CLK_PERIOD;

        mem_addr <= X"001";
        MEMORY_WRITE_EN <= '0';
        MEMORY_READ_EN <= '1';
        WAIT FOR CLK_PERIOD;
        check_read_data(X"CAFEBABE");

        mem_addr <= X"000";
        MEMORY_WRITE_EN <= '1';
        MEMORY_READ_EN <= '0';
        mem_data_in <= X"12345678";
        WAIT FOR CLK_PERIOD;

        mem_addr <= X"000";
        MEMORY_WRITE_EN <= '0';
        MEMORY_READ_EN <= '1';
        WAIT FOR CLK_PERIOD;
        check_read_data(X"12345678");

        mem_addr <= X"001";
        MEMORY_WRITE_EN <= '0';
        MEMORY_READ_EN <= '1';
        WAIT FOR CLK_PERIOD;
        check_read_data(X"CAFEBABE");

        REPORT "All tests passed!";
        WAIT;
    END PROCESS;

END ARCHITECTURE;