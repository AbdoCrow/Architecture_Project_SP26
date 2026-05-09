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

forward_unit_inst : ENTITY work.forwarding_unit
    PORT MAP (
        read_reg_1 => open,
        read_reg_2 => open,
        
        EX1_UPDATE_FLAGS => open,
        EX2_UPDATE_FLAGS => open,
        MEM_UPDATE_FLAGS => open,

        EX1_REG_WRITE_EN_1 => open,
        EX1_REG_WRITE_EN_2 => open,
        EX1_WRITE_ADDRESS_1 => open,
        EX1_WRITE_ADDRESS_2 => open,
        EX2_REG_WRITE_EN_1 => open,
        EX2_REG_WRITE_EN_2 => open,
        EX2_WRITE_ADDRESS_1 => open,
        EX2_WRITE_ADDRESS_2 => open,
        MEM_REG_WRITE_EN_1 => open,
        MEM_REG_WRITE_EN_2 => open,
        MEM_WRITE_ADDRESS_1 => open,
        MEM_WRITE_ADDRESS_2 => open,

        FLAG_SRC_SEL => open,
        RSRC1_SEL => open,
        RSRC2_SEL => open
    );
hazard_control_unit_inst : ENTITY work.hazard_control_unit
    PORT MAP (
        --Structural hazard signals
        MEMORY => open,
        FETCH_MEMORY_HAZARD => open,

        -- load use hazard signals
        read_reg_1 => open,
        read_reg_2 => open,
        ID_EX1_WRITE_ADDRESS => open,
        EX1_MEMR => open,
        EX1_EX2_WRITE_ADDRESS => open,
        EX2_MEMR => open,

        -- control hazard signals
        branch_prediction => open,
        branch_result => open,
        CORRECT_PC => open,

        -- pc write hazard signals
        EX1_PC_WRITE => open,
        EX2_PC_WRITE => open,
        MEM_PC_WRITE => open,


        --interrupt hazard signals
        EX2_COND_BRANCH => open,
        EX1_COND_BRANCH => open,
        ID_COND_BRANCH => open,

        MULTICYCLE_STALL => open,
        HARDWARE_INTERRUPT => open,
        ALLOW_HW_INT => open,
        STALL => open,
        FLUSH => open
    );
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
        instr_out => decode_instr,
        enable => open,
        branch_prediction_in=> open,
        branch_prediction_out => open
    );
decode_stage_inst : ENTITY work.decode_stage
    PORT MAP (
        clk => clk,
        reset => reset,
  
        -- Inputs from fetch stage
        instr_in => decode_instr, 
        -- Inputs from writeback stage
        wb_addr_1_in => open,
        wb_data_1_in => open,
        REG_WB_EN_1_IN => open,
        wb_addr_2_in => open,
        wb_data_2_in => open,
        REG_WB_EN_2_IN => open,

        -- Inputs from Hazard unit
        STALL => open,
        FLUSH => open,
        -- Control signals to execute stage
        LOAD_FLAGS => open,
        PC_WRITE_EN => open,
        MEM_WRITE_SEL => open,
        COND_BRANCH => open,
        HLT => open,
        MEMW => open,
        MEMR => open,
        UPDATE_FLAGS => open,
        MEM_ADDRESS_SEL => open,
        OUTPUT_PORT_EN => open,

        REG_WB_EN_1 => open,
        REG_WB_EN_2 => open,
        ALU_INPUT_SEL => open,
        JMP_FLAG_SEL=> open,
        ALU_OP => open,
        -- Data signals to execute stage
        read_data_1_out => open,
        read_data_2_out => open,
        imm_offset_out => open,
        reg_write_address_1_out => dec_reg_write_address_1,
        reg_write_address_2_out => dec_reg_write_address_2,
        read_reg_1_out => open,
        read_reg_2_out => open,

        -- Outputs to other Stages
        MULTICYCLE_SEL => open,
        MULTICYCLE_STALL => open,
        INT_TARGERT_ADDR => open,
        ID_COND_BRANCH => open,
        -- monitoring register values for debugging
        reg0_out => open,
        reg1_out => open,
        reg2_out => open,
        reg3_out => open,
        reg4_out => open,
        reg5_out => open,
        reg6_out => open,
        reg7_out => open
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