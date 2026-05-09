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
        MEMORY : OUT STD_LOGIC
        -- ADDED FROM OMAR
        -- PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- FETCH_MEM_SEL : IN STD_LOGIC;
        -- loaded_pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- fetched_instr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        -- pc_write_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
END ENTITY memory_stage;

ARCHITECTURE rtl OF memory_stage IS
SIGNAL mem_addr : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL mem_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL mem_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MEMORY_READ_EN : STD_LOGIC;
SIGNAL MEMORY_WRITE_EN : STD_LOGIC;
SIGNAL mem_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL interrupt_addr_sign_extend : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL CCR_FLAGS_SIGN_EXTEND : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SP_PUSH : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SP_POP : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL sp_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL WB_DATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
-- Definition-only skeleton.
    CCR_FLAGS_SIGN_EXTEND <= (31 downto 3 => corrected_ccr_flags_in(2)) & corrected_ccr_flags_in;
    interrupt_addr_sign_extend <= (31 downto 2 => interrupt_adr_in(1)) & interrupt_adr_in;
    mem_component : ENTITY work.memory
        PORT MAP (
            clk => clk,
            mem_addr => mem_addr,
            mem_data_in => mem_data_in,
            mem_data_out => mem_data_out,
            MEMORY_READ_EN => MEMORY_READ_EN,
            MEMORY_WRITE_EN => MEMORY_WRITE_EN
        );
    mux_mem_addr : ENTITY work.mux_4to1
        GENERIC MAP (
            WIDTH => 32
        )
        PORT MAP (
            sel => MEM_ADDRESS_SEL_IN,
            input_0 => alu_result_1_in,
            input_1 => interrupt_addr_sign_extend,
            input_2 => SP_PUSH, 
            input_3 => SP_POP, 
            output => mem_address
        );
    mux_data_in : ENTITY work.mux_4to1
        GENERIC MAP (
            WIDTH => 32
        )
        PORT MAP (
            sel => MEM_WRITE_SEL_IN,
            input_0 => alu_result_1_in,
            input_1 => next_pc_in,
            input_2 => CCR_FLAGS_SIGN_EXTEND,
            input_3 => (others => '0'),
            output => mem_data_in
        );
    sp_unit_inst: entity work.sp_unit
     generic map(
        STACK_START_ADDR => X"00000FFF"
    )
     port map(
        clk => clk,
        reset => reset,
        sp_write_en => MEM_ADDRESS_SEL_IN(1),
        SP_OP => MEM_ADDRESS_SEL_IN(0),
        HLT => HLT,
        sp_out => sp_out
    );
    MEMORY_READ_EN <= MEMR_IN WHEN FETCH_MEM_SEL = '1' ELSE '1';
    MEMORY_WRITE_EN <= MEMW_IN WHEN FETCH_MEM_SEL = '1' ELSE '0';
    mem_addr <= PC_in(11 DOWNTO 0) WHEN FETCH_MEM_SEL = '0' ELSE
                mem_adr_in(11 DOWNTO 0) WHEN FETCH_MEM_SEL = '1';
    SP_POP <= sp_out;
    SP_PUSH <= STD_LOGIC_VECTOR(unsigned(sp_out) + 4);     

    WB_DATA <= alu_result_1_in WHEN MEMR_IN = '0' ELSE mem_data_out;
    flag_wb_out <= alu_flags_in WHEN LOAD_FLAGS_IN = '0' ELSE WB_DATA(2 DOWNTO 0);
    wb_data_1_out <= WB_DATA;

    loaded_pc <= mem_data_out;
    fetched_instr <= mem_data_out;
    --TODO :: SP UNIT missing to be implemented with fixes and revising for the code
END ARCHITECTURE rtl;