LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY processor IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;
        in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        pc_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ccr_monitor : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        r0_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r1_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r2_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r3_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r4_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r5_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r6_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r7_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY processor;

ARCHITECTURE rtl OF processor IS
--datapath signals
signal fetch_next_pc,dec_next_pc, ex1_next_pc, ex2_next_pc, mem_next_pc :STD_LOGIC_VECTOR(31 DOWNTO 0);
signal dec_reg_write_address_1, dec_reg_write_address_2 : reg_idx_t;
signal ex1_reg_write_address_1, ex1_reg_write_address_2 : reg_idx_t;
signal ex2_reg_write_address_1, ex2_reg_write_address_2 : reg_idx_t;
signal mem_reg_write_address_1, mem_reg_write_address_2 : reg_idx_t;
signal wb_reg_write_address_1, wb_reg_write_address_2 : reg_idx_t;
signal fetch_instr,decode_instr : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

-- forward_unit_inst : ENTITY work.forwarding_unit
--     PORT MAP (

--     );
-- hazard_control_unit_inst : ENTITY work.hazard_control_unit
--     PORT MAP (
--     );
Interrupt_handler_inst : ENTITY work.interrupt_handler
    PORT MAP (
        clk => clk,
        reset => reset,
        HW_INT_SIGNAL => open,
        INT_STARTED => open,
        INT_REQUEST => open
    );
memory_inst: ENTITY work.memory
    PORT MAP (
        clk => clk,
        reset => reset,
        mem_addr => open,
        mem_data_in => open,
        mem_data_out => open,
        MEMORY_READ_EN => open,
        MEMORY_WRITE_EN => open
    );
fetch_stage_inst : ENTITY work.fetch_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        next_pc_out => fetch_next_pc,
        instr_out => fetch_instr,

        PC_WRITE_ENABLE => open,
        FETCH_STALL => open,
        MULTICYCLE_STALL => open,
        MULTICYCLE_SEL => open,
        FLUSH => open,

        CORRECT_PC => open,
        correct_pc_value => open,
        fetched_instruction_in => open,
        loaded_pc_in => open,   
        DECODE_INT_TARGET_IDX => open,
        COND_BRANCH => open,
        BRANCH_TAKEN => open,
        HLT => open,
        FETCH_MEMORY_HAZARD => open,
        ALLOW_HW_INT => open,
        pc_out => open,
        branch_prediction_out => open
        
    );

IF_ID_reg_inst : ENTITY work.if_id_register
    PORT MAP (  
        clk => clk,
        reset => reset,
        next_pc_in => fetch_next_pc,
        next_pc_out => dec_next_pc,
        instr_in => fetch_instr,
        instr_out => decode_instr
        
    );
decode_stage_inst : ENTITY work.decode_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        reg_write_address_1_out => dec_reg_write_address_1,
        reg_write_address_2_out => dec_reg_write_address_2,
        instr_in => decode_instr
    );
ID_EX1_reg_inst : ENTITY work.id_ex1_register 
    port map (
        clk => clk,
        reset => reset,
        next_pc_in => dec_next_pc,
        next_pc_out => ex1_next_pc,
        reg_write_address_1_in => dec_reg_write_address_1,
        reg_write_address_1_out => ex1_reg_write_address_1,
        reg_write_address_2_in => dec_reg_write_address_2,
        reg_write_address_2_out => ex1_reg_write_address_2
    );
EX1_Stage_inst : ENTITY work.execute1_stage
    PORT MAP (
        clk => clk,
        reset => reset
        
    );
EX1_EX2_reg_inst : ENTITY work.ex1_ex2_register
    PORT MAP (  
        clk => clk,
        reset => reset,
        next_pc_in => ex1_next_pc,
        next_pc_out => ex2_next_pc,
        reg_write_address_1_in => ex1_reg_write_address_1,
        reg_write_address_1_out => ex2_reg_write_address_1,
        reg_write_address_2_in => ex1_reg_write_address_2,
        reg_write_address_2_out => ex2_reg_write_address_2
    );
execute2_stage_inst : ENTITY work.execute2_stage
    PORT MAP (
        clk => clk,
        reset => reset
    );
EX2_MEM_reg_inst : ENTITY work.ex2_mem_register
    port map (
        clk => clk,
        reset => reset,
        next_pc_in => ex2_next_pc,
        next_pc_out => mem_next_pc,
        reg_write_address_1_in => ex2_reg_write_address_1,
        reg_write_address_1_out => mem_reg_write_address_1,
        reg_write_address_2_in => ex2_reg_write_address_2,
        reg_write_address_2_out => mem_reg_write_address_2
    );
Memory_Stage_inst : ENTITY work.memory_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        next_pc_in => mem_next_pc
    );
MEM_WB_reg_inst : ENTITY work.mem_wb_register
    PORT MAP (
        clk => clk,
        reset => reset,
        reg_write_address_1_in => mem_reg_write_address_1,
        reg_write_address_1_out => wb_reg_write_address_1,
        reg_write_address_2_in => mem_reg_write_address_2,
        reg_write_address_2_out => wb_reg_write_address_2
    );
output_port_inst : ENTITY work.output_port
    PORT MAP (
        clk => clk,
        reset => reset,
        enable => open,
        output_port_in => open,
        output_port_out => out_port
    );

END ARCHITECTURE rtl;