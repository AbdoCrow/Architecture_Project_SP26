LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux_8to1 IS
    GENERIC (WIDTH : INTEGER := 32);
    PORT (
        input_0 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_1 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_2 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_3 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_4 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_5 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_6 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_7 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
END ENTITY mux_8to1;

ARCHITECTURE rtl OF mux_8to1 IS
BEGIN
    -- TODO: implement 8:1 mux
    output <= input_0 when sel = "000" else
              input_1 when sel = "001" else
              input_2 when sel = "010" else
              input_3 when sel = "011" else
              input_4 when sel = "100" else
              input_5 when sel = "101" else
              input_6 when sel = "110" else
              input_7;
END ARCHITECTURE rtl;