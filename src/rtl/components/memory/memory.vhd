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
        MEMORY_WRITE_EN : IN STD_LOGIC;
        --debug 
        memory_location_zero_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY memory;

ARCHITECTURE rtl OF memory IS
type memory_array_type is array (0 to MEMORY_SIZE - 1) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
signal memory_array : memory_array_type := (others => (others => '0'));
BEGIN
    memory_location_zero_out <= memory_array(0); -- For debugging purposes, always output the value at address 0
    process(clk)
    begin
        if RESET = '1' then
            mem_data_out <= memory_array(0); -- Output the first memory location on reset
        elsif rising_edge(clk) then
            if MEMORY_WRITE_EN = '1' then
                -- Write data to memory
                memory_array(to_integer(unsigned(mem_addr))) <= mem_data_in;
            end if;
            if MEMORY_READ_EN = '1' then
                -- Read data from memory 
                mem_data_out <= memory_array(to_integer(unsigned(mem_addr)));
            else
                mem_data_out <= (others => '0');
            end if;
        end if;
    end process;
END ARCHITECTURE rtl;