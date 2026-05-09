LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY memory_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        LOAD_FLAGS_IN : IN STD_LOGIC;
        MEM_WRITE_SEL_IN : IN mem_write_sel_t;
        MEMW_IN : IN STD_LOGIC;
        MEMR_IN : IN STD_LOGIC;
        MEM_ADDRESS_SEL_IN : IN mem_address_sel_t;
        HLT : IN STD_LOGIC;

        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_adr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        interrupt_adr_in : IN int_idx_t;
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        mem_read_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        flag_wb_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        mem_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_write_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEMORY : OUT STD_LOGIC;
        sp_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY memory_stage;

ARCHITECTURE rtl OF memory_stage IS
SIGNAL SP_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SP_PLUS_1_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
sp_monitor <= SP_VALUE;
MEMORY <= MEMR_IN OR MEMW_IN;
wb_data_1_out <= mem_read_data_in when MEMR_IN = '1' else alu_result_1_in;
flag_wb_out <= mem_read_data_in(2 DOWNTO 0) when LOAD_FLAGS_IN = '1' else alu_flags_in;
mem_address <= mem_adr_in when MEM_ADDRESS_SEL_IN = MEM_ADDRESS_CALC else
               (29 downto 0 => '0') & interrupt_adr_in when MEM_ADDRESS_SEL_IN = MEM_ADDRESS_INT_VECTOR else
                SP_VALUE when MEM_ADDRESS_SEL_IN = MEM_ADDRESS_SP_PUSH else
                SP_PLUS_1_VALUE; -- I think this is wrong, should be SP_VALUE probably
mem_write_data_out <= alu_result_1_in WHEN MEM_WRITE_SEL_IN = MEM_WRITE_ALU_DATA ELSE
                     next_pc_in WHEN MEM_WRITE_SEL_IN = MEM_WRITE_PC_DATA ELSE
                     (28 downto 0 => '0') & corrected_ccr_flags_in;
sp_unit_inst: entity work.sp_unit
    port map (
        clk => clk,
        RESET => reset,
        SP_EN => MEM_ADDRESS_SEL_IN(1),
        SP_OP => MEM_ADDRESS_SEL_IN(0),
        HLT => HLT,
        sp => SP_VALUE,
        sp_plus_1 => SP_PLUS_1_VALUE
    );
END ARCHITECTURE rtl;