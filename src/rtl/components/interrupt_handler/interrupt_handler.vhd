LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY interrupt_handler IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        HW_INT_SIGNAL : IN STD_LOGIC;
        INT_STARTED: IN STD_LOGIC;
        INT_REQUEST : OUT STD_LOGIC
    );
END ENTITY interrupt_handler;

ARCHITECTURE rtl OF interrupt_handler IS
SIGNAL int_request_reg : STD_LOGIC := '0';
BEGIN
    PROCESS (clk)
    BEGIN
        IF reset = '1' THEN
            int_request_reg <= '0';
        ELSIF rising_edge(clk) THEN
            IF HW_INT_SIGNAL = '1' THEN
                int_request_reg <= '1';
            ELSIF INT_STARTED = '1' THEN
                int_request_reg <= '0';
            ELSE 
                int_request_reg <= int_request_reg; -- Hold current value
            END IF;
        END IF;
    END PROCESS;
    INT_REQUEST <= int_request_reg;
END ARCHITECTURE rtl;