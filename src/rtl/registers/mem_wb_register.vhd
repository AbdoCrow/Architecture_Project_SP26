LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mem_wb_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ccr_data_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rd_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ccr_data_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        rd_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_out : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
    );
END ENTITY mem_wb_register;

ARCHITECTURE rtl OF mem_wb_register IS
BEGIN
    -- TODO: MEM -> WB pipeline register implementation
END ARCHITECTURE rtl;