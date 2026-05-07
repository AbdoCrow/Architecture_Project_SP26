LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY pc_reg IS
    PORT (
        clk : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY pc_reg;

ARCHITECTURE rtl OF pc_reg IS
SIGNAL pc_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
process(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF enable = '1' THEN
                pc_reg <= pc_in;
            ELSE 
                pc_reg <= pc_reg; -- Hold current value
            END IF;
        END IF;
    END PROCESS;
pc_out <= pc_reg;
END ARCHITECTURE rtl;