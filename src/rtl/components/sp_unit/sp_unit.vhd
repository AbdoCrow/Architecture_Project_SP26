library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


ENTITY sp_unit IS
    generic (
        STACK_START_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000FFF"
    );
    PORT (
        clk : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        SP_EN: IN STD_LOGIC; --SP_EN in the schematic
        SP_OP : IN STD_LOGIC; --SP_OP in the schematic
        HLT : IN STD_LOGIC;
        sp : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_plus_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY sp_unit;

ARCHITECTURE rtl OF sp_unit IS
SIGNAL sp_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL sp_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL sp_plus_1_wire : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
-- Common addition to prevent having two separate adders for sp+1 output and sp update when SP_OP = '1'
sp_plus_1_wire <= STD_LOGIC_VECTOR(UNSIGNED(sp_reg) + 1);


-- combinational logic to determine next value of sp_reg based on SP_EN and SP_OP
sp_next <= STD_LOGIC_VECTOR(UNSIGNED(sp_reg) - 1) WHEN (SP_EN = '1' AND SP_OP = '0' AND HLT = '0') ELSE
           sp_plus_1_wire WHEN (SP_EN = '1' AND SP_OP = '1' AND HLT = '0') ELSE
           sp_reg;
-- Output assignments
sp <= sp_reg;
sp_plus_1 <= sp_plus_1_wire;

-- Sequential logic to update sp_reg on clock edge or reset
PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            sp_reg <= STACK_START_ADDR;
        ELSIF RISING_EDGE(clk) THEN
                sp_reg <= sp_next;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;