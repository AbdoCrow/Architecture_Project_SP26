library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
USE work.isa_defs_pkg.ALL;

entity memory_stage_tb is
end entity memory_stage_tb;

architecture testbench of memory_stage_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    signal LOAD_FLAGS_IN : std_logic := '0';
    signal PC_WRITE_EN_IN : std_logic := '0';
    signal MEM_WRITE_SEL_IN : mem_write_sel_t := (others => '0');
    signal MEMW_IN : std_logic := '0';
    signal MEMR_IN : std_logic := '0';
    signal UPDATE_FLAGS_IN : std_logic := '0';
    signal MEM_ADDRESS_SEL_IN : mem_address_sel_t := (others => '0');
    signal OUTPUT_PORT_EN_IN : std_logic := '0';
    signal REG_WB_EN_IN : std_logic := '0';

    signal corrected_ccr_flags_in : std_logic_vector(2 downto 0) := (others => '0');
    signal alu_flags_in : std_logic_vector(2 downto 0) := (others => '0');
    signal alu_result_in : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_adr_in : std_logic_vector(31 downto 0) := (others => '0');
    signal interrupt_adr_in : std_logic_vector(1 downto 0) := (others => '0');
    signal reg_write_address_in : reg_idx_t := (others => '0');
    signal next_pc_in : std_logic_vector(31 downto 0) := (others => '0');

    signal UPDATE_FLAGS_OUT : std_logic;
    signal OUTPUT_PORT_EN_OUT : std_logic;
    signal REG_WB_EN_OUT : std_logic;

    signal flag_wb_out : std_logic_vector(2 downto 0);
    signal wb_data_out : std_logic_vector(31 downto 0);
    signal reg_write_address_out : reg_idx_t;
    signal pc_write_en_out : std_logic;
    signal pc_write_data_out : std_logic_vector(31 downto 0);

    -- ADDED FROM OMAR
    signal PC_in : std_logic_vector(31 downto 0) := (others => '0');
    signal FETCH_MEM_SEL : std_logic := '0';
    signal HLT : std_logic := '0';
    signal loaded_pc : std_logic_vector(31 downto 0);
    signal fetched_instr : std_logic_vector(31 downto 0);

    component memory_stage
        port (
            clk : in std_logic;
            reset : in std_logic;

            LOAD_FLAGS_IN : in std_logic;
            PC_WRITE_EN_IN : in std_logic;
            MEM_WRITE_SEL_IN : in mem_write_sel_t;
            MEMW_IN : in std_logic;
            MEMR_IN : in std_logic;
            UPDATE_FLAGS_IN : in std_logic;
            MEM_ADDRESS_SEL_IN : in mem_address_sel_t;
            OUTPUT_PORT_EN_IN : in std_logic;
            REG_WB_EN_IN : in std_logic;

            corrected_ccr_flags_in : in std_logic_vector(2 downto 0);
            alu_flags_in : in std_logic_vector(2 downto 0);
            alu_result_in : in std_logic_vector(31 downto 0);
            mem_adr_in : in std_logic_vector(31 downto 0);
            interrupt_adr_in : in std_logic_vector(1 downto 0);
            reg_write_address_in : in reg_idx_t;
            next_pc_in : in std_logic_vector(31 downto 0);

            UPDATE_FLAGS_OUT : out std_logic;
            OUTPUT_PORT_EN_OUT : out std_logic;
            REG_WB_EN_OUT : out std_logic;

            flag_wb_out : out std_logic_vector(2 downto 0);
            wb_data_out : out std_logic_vector(31 downto 0);
            reg_write_address_out : out reg_idx_t;
            pc_write_en_out : out std_logic;
            pc_write_data_out : out std_logic_vector(31 downto 0);

            -- ADDED FROM OMAR
            PC_in : in std_logic_vector(31 downto 0);
            FETCH_MEM_SEL : in std_logic;
            HLT : in std_logic;
            loaded_pc : out std_logic_vector(31 downto 0);
            fetched_instr : out std_logic_vector(31 downto 0)
        );
    end component memory_stage;
begin
    uut: memory_stage
        port map (
            clk => clk,
            reset => reset,

            LOAD_FLAGS_IN => LOAD_FLAGS_IN,
            PC_WRITE_EN_IN => PC_WRITE_EN_IN,
            MEM_WRITE_SEL_IN => MEM_WRITE_SEL_IN,
            MEMW_IN => MEMW_IN,
            MEMR_IN => MEMR_IN,
            UPDATE_FLAGS_IN => UPDATE_FLAGS_IN,
            MEM_ADDRESS_SEL_IN => MEM_ADDRESS_SEL_IN,
            OUTPUT_PORT_EN_IN => OUTPUT_PORT_EN_IN,
            REG_WB_EN_IN => REG_WB_EN_IN,

            corrected_ccr_flags_in => corrected_ccr_flags_in,
            alu_flags_in => alu_flags_in,
            alu_result_in => alu_result_in,
            mem_adr_in => mem_adr_in,
            interrupt_adr_in => interrupt_adr_in,
            reg_write_address_in => reg_write_address_in,
            next_pc_in => next_pc_in,

            UPDATE_FLAGS_OUT => UPDATE_FLAGS_OUT,
            OUTPUT_PORT_EN_OUT => OUTPUT_PORT_EN_OUT,
            REG_WB_EN_OUT => REG_WB_EN_OUT,

            flag_wb_out => flag_wb_out,
            wb_data_out => wb_data_out,
            reg_write_address_out => reg_write_address_out,
            pc_write_en_out => pc_write_en_out,
            pc_write_data_out => pc_write_data_out,

            -- ADDED FROM OMAR
            PC_in => PC_in,
            FETCH_MEM_SEL => FETCH_MEM_SEL,
            HLT => HLT,
            loaded_pc => loaded_pc,
            fetched_instr => fetched_instr
        );
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 100 ps;
            clk <= '1';
            wait for 100 ps;
        end loop;
    end process clk_process;
    stimulus_process : process
        procedure wait_rise is
        begin
            wait until rising_edge(clk);
            wait for 10 ps;
        end procedure;
    begin
        -- Reset
        reset <= '1';
        LOAD_FLAGS_IN <= '0';
        PC_WRITE_EN_IN <= '0';
        MEM_WRITE_SEL_IN <= (others => '0');
        MEMW_IN <= '0';
        MEMR_IN <= '0';
        UPDATE_FLAGS_IN <= '0';
        MEM_ADDRESS_SEL_IN <= (others => '0');
        OUTPUT_PORT_EN_IN <= '0';
        REG_WB_EN_IN <= '0';
        corrected_ccr_flags_in <= (others => '0');
        alu_flags_in <= (others => '0');
        alu_result_in <= (others => '0');
        mem_adr_in <= (others => '0');
        interrupt_adr_in <= (others => '0');
        reg_write_address_in <= (others => '0');
        next_pc_in <= (others => '0');
        PC_in <= (others => '0');
        FETCH_MEM_SEL <= '1';
        HLT <= '0';

        wait_rise;
        reset <= '0';
        wait_rise;

        -- Test 1: memory write then read back through MEMR path
        MEM_WRITE_SEL_IN <= "00"; -- write alu_result_in
        mem_adr_in <= x"00000010";
        alu_result_in <= x"DEADBEEF";
        MEMW_IN <= '1';
        MEMR_IN <= '0';
        FETCH_MEM_SEL <= '1';
        wait_rise;
        MEMW_IN <= '0';

        MEMR_IN <= '1';
        wait for 10 ps;
        assert wb_data_out = x"DEADBEEF"
            report "MEM readback failed at address 0x10" severity error;
        MEMR_IN <= '0';

        -- Test 2: wb_data_out bypass when MEMR_IN = '0'
        alu_result_in <= x"12345678";
        wait for 10 ps;
        assert wb_data_out = x"12345678"
            report "WB bypass failed when MEMR_IN=0" severity error;

        -- Test 3: flag_wb_out source select
        alu_flags_in <= "101";
        LOAD_FLAGS_IN <= '0';
        wait for 10 ps;
        assert flag_wb_out = "101"
            report "Flag passthrough failed when LOAD_FLAGS_IN=0" severity error;

        LOAD_FLAGS_IN <= '1';
        MEM_WRITE_SEL_IN <= "10"; -- write corrected_ccr_flags_in
        corrected_ccr_flags_in <= "011";
        mem_adr_in <= x"00000014";
        MEMW_IN <= '1';
        wait_rise;
        MEMW_IN <= '0';
        MEMR_IN <= '1';
        wait for 10 ps;
        assert flag_wb_out = "011"
            report "Flag load from memory failed when LOAD_FLAGS_IN=1" severity error;
        MEMR_IN <= '0';

        -- Test 4: fetch path (FETCH_MEM_SEL = 0) reads memory at PC_in
        mem_adr_in <= x"00000020";
        alu_result_in <= x"A5A5A5A5";
        MEM_WRITE_SEL_IN <= "00";
        FETCH_MEM_SEL <= '1';
        MEMW_IN <= '1';
        wait_rise;
        MEMW_IN <= '0';

        PC_in <= x"00000020";
        FETCH_MEM_SEL <= '0';
        wait for 10 ps;
        assert fetched_instr = x"A5A5A5A5"
            report "Fetch path failed to read memory at PC_in" severity error;
        assert loaded_pc = x"A5A5A5A5"
            report "Loaded PC failed to reflect fetch memory data" severity error;

        -- Test 5: control signal pass-through
        UPDATE_FLAGS_IN <= '1';
        OUTPUT_PORT_EN_IN <= '1';
        REG_WB_EN_IN <= '1';
        wait for 10 ps;
        assert UPDATE_FLAGS_OUT = '1'
            report "UPDATE_FLAGS_OUT passthrough failed" severity error;
        assert OUTPUT_PORT_EN_OUT = '1'
            report "OUTPUT_PORT_EN_OUT passthrough failed" severity error;
        assert REG_WB_EN_OUT = '1'
            report "REG_WB_EN_OUT passthrough failed" severity error;

        -- End simulation
        wait;
    end process stimulus_process;
end architecture testbench;