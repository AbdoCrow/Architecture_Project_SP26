LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY output_port IS
    PORT (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        output_port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        output_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY output_port;

ARCHITECTURE rtl OF output_port IS
SIGNAL output_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
process(clk)
    BEGIN
        IF reset = '1' THEN
            output_reg <= (OTHERS => '0');
        ELSIF falling_edge(clk) THEN
            IF enable = '1' THEN
                output_reg <= output_port_in;
            ELSE 
                output_reg <= output_reg; -- Hold current value
            END IF;
        END IF;
    END PROCESS;
output_port_out <= output_reg;
END ARCHITECTURE rtl;