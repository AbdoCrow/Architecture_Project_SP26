library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


ENTITY memory IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32;
        ADDR_WIDTH : INTEGER := 12;
        MEMORY_SIZE : INTEGER := 4096
    );
    PORT (
        clk : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        mem_addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        mem_data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        mem_data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        MEMORY_READ_EN : IN STD_LOGIC;
        MEMORY_WRITE_EN : IN STD_LOGIC

    );
END ENTITY memory;

ARCHITECTURE rtl OF memory IS
type memory_array_type is array (0 to MEMORY_SIZE - 1) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
signal memory_array : memory_array_type := (others => (others => '0'));
BEGIN

    process(clk)
    begin
        if rising_edge(clk) then
            if MEMORY_WRITE_EN = '1' AND RESET = '0' then
                memory_array(to_integer(unsigned(mem_addr))) <= mem_data_in;
            end if;
        end if;
    end process;
    mem_data_out <= memory_array(0) WHEN RESET = '1' ELSE memory_array(to_integer(unsigned(mem_addr))) WHEN MEMORY_READ_EN = '1' ELSE (others => 'Z');
END ARCHITECTURE rtl;