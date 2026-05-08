LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux_2to1 IS
    GENERIC (WIDTH : INTEGER := 32);
    PORT (
        input_0 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_1 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        sel : IN STD_LOGIC;
        output : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
END ENTITY mux_2to1;

ARCHITECTURE rtl OF mux_2to1 IS
BEGIN
    output <= input_0 when sel = '0' else input_1;
END ARCHITECTURE rtl;