LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux_4to1 IS
    GENERIC (WIDTH : INTEGER := 32);
    PORT (
        input_0 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_1 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_2 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_3 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
END ENTITY mux_4to1;

ARCHITECTURE rtl OF mux_4to1 IS
BEGIN
    output <= input_0 when sel = "00" else
              input_1 when sel = "01" else
              input_2 when sel = "10" else
              input_3;
END ARCHITECTURE rtl;