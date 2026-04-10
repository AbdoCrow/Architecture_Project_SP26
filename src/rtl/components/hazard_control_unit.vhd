LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY hazard_control_unit IS
    PORT (
        load_use_hazard : IN STD_LOGIC;
        structural_hazard : IN STD_LOGIC;
        control_mispredict : IN STD_LOGIC;
        swap_hazard : IN STD_LOGIC;
        stall_fetch : OUT STD_LOGIC;
        stall_decode : OUT STD_LOGIC;
        flush_decode : OUT STD_LOGIC;
        flush_ex1 : OUT STD_LOGIC;
        flush_ex2 : OUT STD_LOGIC;
        pc_enable : OUT STD_LOGIC
    );
END ENTITY hazard_control_unit;

ARCHITECTURE rtl OF hazard_control_unit IS
BEGIN
    -- TODO: implement stall/flush policy
END ARCHITECTURE rtl;