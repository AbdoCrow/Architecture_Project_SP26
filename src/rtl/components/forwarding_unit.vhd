LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY forwarding_unit IS
    PORT (
        rs1_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rs2_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ex2_rd_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        mem_rd_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_rd_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ex2_we : IN STD_LOGIC;
        mem_we : IN STD_LOGIC;
        wb_we : IN STD_LOGIC;
        forward_a_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        forward_b_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        forward_store_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY forwarding_unit;

ARCHITECTURE rtl OF forwarding_unit IS
BEGIN
    -- TODO: implement forwarding decisions
END ARCHITECTURE rtl;