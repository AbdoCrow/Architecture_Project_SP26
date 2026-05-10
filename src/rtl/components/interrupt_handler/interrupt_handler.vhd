LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY interrupt_handler IS
    PORT (
        clk          : IN  STD_LOGIC;
        reset        : IN  STD_LOGIC;
        HW_INT_SIGNAL : IN  STD_LOGIC;
        INT_STARTED  : IN  STD_LOGIC;
        INT_REQUEST  : OUT STD_LOGIC
    );
END ENTITY interrupt_handler;

ARCHITECTURE rtl OF interrupt_handler IS

    SIGNAL counter       : unsigned(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL hw_int_prev   : STD_LOGIC := '0';
    SIGNAL rising_detect : STD_LOGIC;

BEGIN

    -- Edge detection: true for exactly one clock cycle on each rising edge of HW_INT_SIGNAL
    rising_detect <= HW_INT_SIGNAL AND NOT hw_int_prev;

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            counter     <= (OTHERS => '0');
            hw_int_prev <= '0';

        ELSIF rising_edge(clk) THEN
            hw_int_prev <= HW_INT_SIGNAL;

            IF rising_detect = '1' AND INT_STARTED = '1' THEN
                NULL;

            ELSIF rising_detect = '1' THEN
                IF counter < 32 THEN
                    counter <= counter + 1;
                END IF;

            ELSIF INT_STARTED = '1' THEN
                IF counter > 0 THEN
                    counter <= counter - 1;
                END IF;
            END IF;

        END IF;
    END PROCESS;

    -- Asserted whenever at least one interrupt is waiting
    INT_REQUEST <= '1' WHEN counter > 0 ELSE '0';

END ARCHITECTURE rtl;