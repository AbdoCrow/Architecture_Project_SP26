LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY flags_reg IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        UPDATE_FLAGS : IN STD_LOGIC;
        flag_wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY flags_reg;

ARCHITECTURE rtl OF flags_reg IS
signal flags_reg : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk, reset,flag_wb, UPDATE_FLAGS)
    BEGIN
        IF reset = '1' THEN
            flags_reg <= (OTHERS => '0');
        ELSIF falling_edge(clk) THEN
            IF UPDATE_FLAGS = '1' THEN
                flags_reg <= flag_wb;
            END IF;
        END IF;
    END PROCESS;
    flags_out <= flags_reg;
END ARCHITECTURE rtl;