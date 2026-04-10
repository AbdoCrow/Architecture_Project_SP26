LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY memory_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        mem_addr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        store_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY memory_stage;

ARCHITECTURE rtl OF memory_stage IS
BEGIN
    -- TODO: unified memory access stage for loads/stores/stack operations
END ARCHITECTURE rtl;