LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux_16to1 IS
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
        input_8 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_9 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_10 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_11 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_12 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_13 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_14 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        input_15 : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
END ENTITY mux_16to1;

ARCHITECTURE rtl OF mux_16to1 IS
BEGIN
    output <= input_0 when sel = "0000" else
              input_1 when sel = "0001" else
              input_2 when sel = "0010" else
              input_3 when sel = "0011" else
              input_4 when sel = "0100" else
              input_5 when sel = "0101" else
              input_6 when sel = "0110" else
              input_7 when sel = "0111" else
              input_8 when sel = "1000" else
              input_9 when sel = "1001" else
              input_10 when sel = "1010" else
              input_11 when sel = "1011" else
              input_12 when sel = "1100" else
              input_13 when sel = "1101" else
              input_14 when sel = "1110" else
              input_15;
END ARCHITECTURE rtl;