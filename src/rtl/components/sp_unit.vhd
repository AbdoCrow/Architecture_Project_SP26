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
        reset : IN STD_LOGIC;
        sp_write_en : IN STD_LOGIC;
        SP_OP : IN STD_LOGIC; --SP_OP in the schematic
        sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY sp_unit;

ARCHITECTURE rtl OF sp_unit IS
SIGNAL sp_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
-- TODO: implement stack pointer update policy
-- TODO: initialize SP to (2^12 - 1)
-- process(clk, reset)
--     begin
--         if reset = '1' then
--             sp_reg <= STACK_START_ADDR;
--         elsif rising_edge(clk) then
--             if sp_write_en = '1' then
--                 if SP_OP = '0' then
--                     sp_reg <= std_logic_vector(unsigned(sp_reg) - 4);
--                 else
--                     sp_reg <= std_logic_vector(unsigned(sp_reg) + 4);
--                 end if;
--             end if;
--         end if;
--     end process;
sp_reg <= std_logic_vector(unsigned(sp_reg) - 4) when (sp_write_en = '1' and SP_OP = '0') else
          std_logic_vector(unsigned(sp_reg) + 4) when (sp_write_en = '1' and SP_OP = '1') else
          STACK_START_ADDR when (reset = '1' AND sp_write_en = '1') else
          sp_reg;


    sp_out <= sp_reg;
END ARCHITECTURE rtl;