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
    -- =========================================================
    -- FETCH stage outputs
    -- =========================================================
    signal fetch_next_pc   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fetch_instr     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fetch_pc_out    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fetch_branch_prediction : STD_LOGIC;
 
    -- =========================================================
    -- IF/ID -> DECODE stage
    -- =========================================================
    signal dec_next_pc         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal decode_instr        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dec_branch_prediction : STD_LOGIC;
 
    -- =========================================================
    -- DECODE stage outputs (control)
    -- =========================================================
    signal dec_LOAD_FLAGS       : STD_LOGIC;
    signal dec_PC_WRITE_EN      : STD_LOGIC;
    signal dec_MEM_WRITE_SEL    : STD_LOGIC;
    signal dec_COND_BRANCH      : STD_LOGIC;
    signal dec_HLT              : STD_LOGIC;
    signal dec_MEMW             : STD_LOGIC;
    signal dec_MEMR             : STD_LOGIC;
    signal dec_UPDATE_FLAGS     : STD_LOGIC;
    signal dec_MEM_ADDRESS_SEL  : STD_LOGIC;
    signal dec_OUTPUT_PORT_EN   : STD_LOGIC;
    signal dec_REG_WB_EN_1      : STD_LOGIC;
    signal dec_REG_WB_EN_2      : STD_LOGIC;
    signal dec_ALU_INPUT_SEL    : STD_LOGIC;
    signal dec_JMP_FLAG_SEL     : STD_LOGIC;
    signal dec_ALU_OP           : alu_op_t;
    signal dec_MULTICYCLE_SEL   : multicycle_sel_t;
    signal dec_MULTICYCLE_STALL : STD_LOGIC;
    signal dec_INT_TARGET_ADDR  : int_idx_t;
    signal dec_ID_COND_BRANCH   : STD_LOGIC;
 
    -- DECODE stage outputs (data)
    signal dec_read_data_1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dec_read_data_2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dec_imm_offset       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dec_reg_write_address_1 : reg_idx_t;
    signal dec_reg_write_address_2 : reg_idx_t;
    signal dec_read_reg_1       : reg_idx_t;
    signal dec_read_reg_2       : reg_idx_t;
 
    -- =========================================================
    -- ID/EX1 -> EX1 stage
    -- =========================================================
    signal ex1_LOAD_FLAGS       : STD_LOGIC;
    signal ex1_PC_WRITE_EN      : STD_LOGIC;
    signal ex1_MEM_WRITE_SEL    : STD_LOGIC;
    signal ex1_COND_BRANCH      : STD_LOGIC;
    signal ex1_HLT              : STD_LOGIC;
    signal ex1_MEMW             : STD_LOGIC;
    signal ex1_MEMR             : STD_LOGIC;
    signal ex1_UPDATE_FLAGS     : STD_LOGIC;
    signal ex1_MEM_ADDRESS_SEL  : STD_LOGIC;
    signal ex1_OUTPUT_PORT_EN   : STD_LOGIC;
    signal ex1_REG_WB_EN_1      : STD_LOGIC;
    signal ex1_REG_WB_EN_2      : STD_LOGIC;
    signal ex1_ALU_INPUT_SEL    : STD_LOGIC;
    signal ex1_JMP_FLAG_SEL     : STD_LOGIC;
    signal ex1_ALU_OP           : alu_op_t;
    signal ex1_branch_prediction : STD_LOGIC;
    signal ex1_read_data_1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_read_data_2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_imm_offset       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_reg_write_address_1 : reg_idx_t;
    signal ex1_reg_write_address_2 : reg_idx_t;
    signal ex1_next_pc          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_read_reg_1       : reg_idx_t;
    signal ex1_read_reg_2       : reg_idx_t;
 
    -- EX1 stage outputs (results)
    signal ex1_alu_result_1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_alu_result_2     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_base_reg_data    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_alu_flags        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ex1_corrected_ccr    : STD_LOGIC_VECTOR(2 DOWNTO 0);
 
    -- =========================================================
    -- EX1/EX2 -> EX2 stage
    -- =========================================================
    signal ex2_LOAD_FLAGS       : STD_LOGIC;
    signal ex2_PC_WRITE_EN      : STD_LOGIC;
    signal ex2_MEM_WRITE_SEL    : STD_LOGIC;
    signal ex2_COND_BRANCH      : STD_LOGIC;
    signal ex2_HLT              : STD_LOGIC;
    signal ex2_MEMW             : STD_LOGIC;
    signal ex2_MEMR             : STD_LOGIC;
    signal ex2_UPDATE_FLAGS     : STD_LOGIC;
    signal ex2_MEM_ADDRESS_SEL  : STD_LOGIC;
    signal ex2_OUTPUT_PORT_EN   : STD_LOGIC;
    signal ex2_REG_WB_EN_1      : STD_LOGIC;
    signal ex2_REG_WB_EN_2      : STD_LOGIC;
    signal ex2_JMP_FLAG_SEL     : STD_LOGIC;
    signal ex2_corrected_ccr    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ex2_branch_prediction : STD_LOGIC;
    signal ex2_alu_flags        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ex2_alu_result_1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_alu_result_2     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_base_reg_data    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_imm_offset       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_reg_write_address_1 : reg_idx_t;
    signal ex2_reg_write_address_2 : reg_idx_t;
    signal ex2_next_pc          : STD_LOGIC_VECTOR(31 DOWNTO 0);
 
    -- EX2 stage outputs
    signal ex2_branch_result    : STD_LOGIC;
    signal ex2_branch_pred_out  : STD_LOGIC;
    signal ex2_correct_pc_value : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_mem_adr          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_interrupt_adr    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_HLT_out          : STD_LOGIC;
 
    -- =========================================================
    -- EX2/MEM -> MEM stage
    -- =========================================================
    signal mem_LOAD_FLAGS       : STD_LOGIC;
    signal mem_PC_WRITE_EN      : STD_LOGIC;
    signal mem_MEM_WRITE_SEL    : STD_LOGIC;
    signal mem_MEMW             : STD_LOGIC;
    signal mem_MEMR             : STD_LOGIC;
    signal mem_UPDATE_FLAGS     : STD_LOGIC;
    signal mem_MEM_ADDRESS_SEL  : STD_LOGIC;
    signal mem_OUTPUT_PORT_EN   : STD_LOGIC;
    signal mem_REG_WB_EN_1      : STD_LOGIC;
    signal mem_REG_WB_EN_2      : STD_LOGIC;
    signal mem_corrected_ccr    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal mem_alu_flags        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal mem_alu_result_1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_alu_result_2     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_mem_adr          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_interrupt_adr    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_reg_write_address_1 : reg_idx_t;
    signal mem_reg_write_address_2 : reg_idx_t;
    signal mem_next_pc          : STD_LOGIC_VECTOR(31 DOWNTO 0);
 
    -- MEM stage outputs
    signal mem_flag_wb          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal mem_wb_data_1        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_address          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_write_data       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_MEMORY           : STD_LOGIC;
 
    -- =========================================================
    -- MEM/WB -> WB outputs
    -- =========================================================
    signal wb_UPDATE_FLAGS      : STD_LOGIC;
    signal wb_OUTPUT_PORT_EN    : STD_LOGIC;
    signal wb_REG_WB_EN_1       : STD_LOGIC;
    signal wb_REG_WB_EN_2       : STD_LOGIC;
    signal wb_flag_wb           : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal wb_data_1            : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal wb_data_2            : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal wb_reg_write_address_1 : reg_idx_t;
    signal wb_reg_write_address_2 : reg_idx_t;
 
    -- =========================================================
    -- Hazard unit outputs
    -- =========================================================
    signal haz_STALL            : STD_LOGIC;
    signal haz_FLUSH            : STD_LOGIC;
    signal haz_MULTICYCLE_STALL : STD_LOGIC;
    signal haz_FETCH_MEMORY_HAZARD : STD_LOGIC;
    signal haz_ALLOW_HW_INT     : STD_LOGIC;
    signal haz_CORRECT_PC       : STD_LOGIC;
 
    -- =========================================================
    -- Forwarding unit outputs
    -- =========================================================
    signal fwd_RSRC1_SEL        : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal fwd_RSRC2_SEL        : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal fwd_FLAG_SRC_SEL     : STD_LOGIC_VECTOR(1 DOWNTO 0);
 
    -- =========================================================
    -- Interrupt handler outputs
    -- =========================================================
    signal int_INT_REQUEST      : STD_LOGIC;
 
    -- =========================================================
    -- Memory outputs
    -- =========================================================
    signal mem_data_out         : STD_LOGIC_VECTOR(31 DOWNTO 0);
 
BEGIN

forward_unit_inst : ENTITY work.forwarding_unit
    PORT MAP (
        read_reg_1          => ex1_read_reg_1,
        read_reg_2          => ex1_read_reg_2,

        EX1_UPDATE_FLAGS    => ex2_UPDATE_FLAGS, -- different naming convention between stages
        EX2_UPDATE_FLAGS    => mem_UPDATE_FLAGS,-- different naming convention between stages
        MEM_UPDATE_FLAGS    => wb_UPDATE_FLAGS, -- different naming convention between stages

        EX1_REG_WRITE_EN_1  => ex2_REG_WB_EN_1,
        EX1_REG_WRITE_EN_2  => ex2_REG_WB_EN_2,
        EX1_WRITE_ADDRESS_1 => ex2_reg_write_address_1,
        EX1_WRITE_ADDRESS_2 => ex2_reg_write_address_2,
        EX2_REG_WRITE_EN_1  => mem_REG_WB_EN_1,
        EX2_REG_WRITE_EN_2  => mem_REG_WB_EN_2,
        EX2_WRITE_ADDRESS_1 => mem_reg_write_address_1,
        EX2_WRITE_ADDRESS_2 => mem_reg_write_address_2,
        MEM_REG_WRITE_EN_1  => wb_REG_WB_EN_1,
        MEM_REG_WRITE_EN_2  => wb_REG_WB_EN_2,
        MEM_WRITE_ADDRESS_1 => wb_reg_write_address_1,
        MEM_WRITE_ADDRESS_2 => wb_reg_write_address_2,

        FLAG_SRC_SEL        => fwd_FLAG_SRC_SEL,
        RSRC1_SEL           => fwd_RSRC1_SEL,
        RSRC2_SEL           => fwd_RSRC2_SEL
    );
hazard_control_unit_inst : ENTITY work.hazard_control_unit
    PORT MAP (
        --Structural hazard signals
        MEMORY                => mem_MEMORY,
        FETCH_MEMORY_HAZARD   => haz_FETCH_MEMORY_HAZARD,

        -- load use hazard signals
        read_reg_1            => dec_read_reg_1,
        read_reg_2            => dec_read_reg_2,
        ID_EX1_WRITE_ADDRESS  => ex1_reg_write_address_1,
        EX1_MEMR              => ex1_MEMR,
        EX1_EX2_WRITE_ADDRESS => ex2_reg_write_address_1,
        EX2_MEMR              => ex2_MEMR,

        -- control hazard signals
        branch_prediction     => fetch_branch_prediction,
        branch_result         => ex2_branch_result,
        CORRECT_PC            => haz_CORRECT_PC,

        -- pc write hazard signals
        EX1_PC_WRITE          => ex1_PC_WRITE_EN,
        EX2_PC_WRITE          => ex2_PC_WRITE_EN,
        MEM_PC_WRITE          => mem_PC_WRITE_EN,


        --interrupt hazard signals
        EX2_COND_BRANCH       => ex2_COND_BRANCH,
        EX1_COND_BRANCH       => ex1_COND_BRANCH,
        ID_COND_BRANCH        => dec_ID_COND_BRANCH,


        MULTICYCLE_STALL      => haz_MULTICYCLE_STALL,
        HARDWARE_INTERRUPT    => int_INT_REQUEST,
        ALLOW_HW_INT          => haz_ALLOW_HW_INT,
        STALL                 => haz_STALL,
        FLUSH                 => haz_FLUSH
    );
Interrupt_handler_inst : ENTITY work.interrupt_handler
    PORT MAP (
        clk           => clk,
        reset         => reset,
        HW_INT_SIGNAL => intr_in,
        INT_STARTED   => haz_ALLOW_HW_INT,
        INT_REQUEST   => int_INT_REQUEST
    );
memory_inst: ENTITY work.memory
    PORT MAP (
        clk => clk,
        reset => reset,
        mem_addr => open,
        mem_data_in => open,
        mem_data_out => mem_data_out,
        MEMORY_READ_EN => open,
        MEMORY_WRITE_EN => open
    );
fetch_stage_inst : ENTITY work.fetch_stage
    PORT MAP (
        clk                      => clk,
        reset                    => reset,
        next_pc_out              => fetch_next_pc,
        instr_out                => fetch_instr,

        PC_WRITE_ENABLE          => ex2_PC_WRITE_EN,
        FETCH_STALL              => haz_STALL,
        MULTICYCLE_STALL         => haz_MULTICYCLE_STALL,
        MULTICYCLE_SEL           => dec_MULTICYCLE_SEL,
        FLUSH                    => haz_FLUSH,

        CORRECT_PC               => haz_CORRECT_PC,
        correct_pc_value         => ex2_correct_pc_value,
        fetched_instruction_in   => mem_data_out,
        loaded_pc_in             => mem_data_out,
        DECODE_INT_TARGET_IDX    => dec_INT_TARGET_ADDR,
        COND_BRANCH              => ex2_COND_BRANCH,
        BRANCH_TAKEN             => ex2_branch_result,
        HLT                      => ex2_HLT,
        FETCH_MEMORY_HAZARD      => haz_FETCH_MEMORY_HAZARD,
        ALLOW_HW_INT             => haz_ALLOW_HW_INT,
        pc_out                   => fetch_pc_out,
        branch_prediction_out    => fetch_branch_prediction
    );

IF_ID_reg_inst : ENTITY work.if_id_register
    PORT MAP (  
        clk => clk,
        reset => reset,
        next_pc_in => fetch_next_pc,
        next_pc_out => dec_next_pc,
        instr_in => fetch_instr,
        instr_out => decode_instr,
        enable => NOT (haz_STALL OR ex2_HLT),
        branch_prediction_in  => fetch_branch_prediction,
        branch_prediction_out => dec_branch_prediction
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
        enable => open,

        LOAD_FLAGS_IN => open,
        PC_WRITE_EN_IN => open,
        MEM_WRITE_SEL_IN => open,
        COND_BRANCH_IN => open,
        HLT_IN => open,
        MEMW_IN => open,
        MEMR_IN => open,
        UPDATE_FLAGS_IN => open,
        MEM_ADDRESS_SEL_IN => open,
        OUTPUT_PORT_EN_IN => open,
        REG_WB_EN_1_IN => open,
        REG_WB_EN_2_IN => open,
        ALU_INPUT_SEL_IN => open,
        JMP_FLAG_SEL_IN => open,
        ALU_OP_IN => open,

        branch_prediction_in => open,
        read_data_1_in => open,
        read_data_2_in => open,
        imm_offset_in => open,
        reg_write_address_1_in => dec_reg_write_address_1,
        reg_write_address_2_in => dec_reg_write_address_2,
        next_pc_in => dec_next_pc,
        read_reg_1_in => open,
        read_reg_2_in => open,

        LOAD_FLAGS_OUT => open,
        PC_WRITE_EN_OUT => open,
        MEM_WRITE_SEL_OUT => open,
        COND_BRANCH_OUT => open,
        HLT_OUT => open,
        MEMW_OUT => open,
        MEMR_OUT => open,
        UPDATE_FLAGS_OUT => open,
        MEM_ADDRESS_SEL_OUT => open,
        OUTPUT_PORT_EN_OUT => open,
        REG_WB_EN_1_OUT => open,
        REG_WB_EN_2_OUT => open,
        ALU_INPUT_SEL_OUT => open,
        JMP_FLAG_SEL_OUT => open,
        ALU_OP_OUT => open,

        branch_prediction_out => open,
        read_data_1_out => open,
        read_data_2_out => open,
        imm_offset_out => open,
        reg_write_address_1_out => ex1_reg_write_address_1,
        reg_write_address_2_out => ex1_reg_write_address_2,

        next_pc_out => ex1_next_pc,
        read_reg_1_out => open,
        read_reg_2_out => open
    );
EX1_Stage_inst : ENTITY work.execute1_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        ALU_OP => open,
        ALU_INPUT_SEL => open,
        UPDATE_FLAGS => open,

        imm_offset_in => open,
        alu_result_1_out => open,
        alu_result_2_out => open,
        base_reg_data_out => open,
        alu_flags_out => open,
        corrected_ccr_flags_out => open,

        -- input port
        input_port_data_in => open,

        -- forwarding control
        RSRC1_SEL => open,
        RSRC2_SEL => open,
        FLAG_SRC_SEL => open,
        -- forwarding data
        read_data_1_in => open,
        read_data_2_in => open,
        fwd_ex2_data_1 => open,
        fwd_ex2_data_2 => open,
        fwd_mem_data_1 => open,
        fwd_mem_data_2 => open,
        fwd_wb_data_1 => open,
        fwd_wb_data_2 => open,

        fwd_ex2_flags => open,
        fwd_mem_flags => open,
        flag_wb => open,


        --debug 
        CCR_monitor => open 
        
    );
EX1_EX2_reg_inst : ENTITY work.ex1_ex2_register
    PORT MAP (  
        clk => clk,
        reset => reset,
        FLUSH => open,
        enable => open,

        LOAD_FLAGS_IN => open, 
        PC_WRITE_EN_IN => open,
        MEM_WRITE_SEL_IN => open,
        COND_BRANCH_IN => open,
        HLT_IN => open,
        MEMW_IN => open,
        MEMR_IN => open,
        UPDATE_FLAGS_IN => open,
        MEM_ADDRESS_SEL_IN => open,
        OUTPUT_PORT_EN_IN => open,
        REG_WB_EN_1_IN => open,
        REG_WB_EN_2_IN => open,
        JMP_FLAG_SEL_IN => open,

        corrected_ccr_flags_in => open,
        branch_prediction_in => open,
        alu_flags_in => open,
        alu_result_1_in => open,
        alu_result_2_in => open,
        base_reg_data_in => open,
        imm_offset_in => open,
        reg_write_address_1_in => ex1_reg_write_address_1,
        reg_write_address_2_in => ex1_reg_write_address_2,
        next_pc_in => ex1_next_pc,

        LOAD_FLAGS_OUT => open,
        PC_WRITE_EN_OUT => open,
        MEM_WRITE_SEL_OUT => open,
        COND_BRANCH_OUT => open,
        HLT_OUT => open,
        MEMW_OUT => open,
        MEMR_OUT => open,
        UPDATE_FLAGS_OUT => open,
        MEM_ADDRESS_SEL_OUT => open,
        OUTPUT_PORT_EN_OUT => open,
        REG_WB_EN_1_OUT => open,
        REG_WB_EN_2_OUT => open,
        JMP_FLAG_SEL_OUT => open,

        corrected_ccr_flags_out => open,
        branch_prediction_out => open,
        alu_flags_out => open,
        alu_result_1_out => open,
        alu_result_2_out => open,
        base_reg_data_out => open,
        imm_offset_out => open,
        reg_write_address_1_out => ex2_reg_write_address_1,
        reg_write_address_2_out => ex2_reg_write_address_2,
        next_pc_out => ex2_next_pc
    );
execute2_stage_inst : ENTITY work.execute2_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        COND_BRANCH_IN => open,
        HLT_IN => open,
        JMP_FLAG_SEL_IN => open,
        corrected_ccr_flags_in => open,
        base_reg_data_in => open,
        imm_offset_in => open,
        next_pc_in => open,
        branch_prediction_in => open,
    
        branch_result_out => open,
        branch_prediction_out => open,
        correct_pc_value_out => open,
        mem_adr_out => open,
        interrupt_adr_out => open,
        HLT_OUT => open
    );
EX2_MEM_reg_inst : ENTITY work.ex2_mem_register
    port map (
        clk => clk,
        reset => reset,
        enable => open,

        LOAD_FLAGS_IN => open,
        PC_WRITE_EN_IN => open,
        MEM_WRITE_SEL_IN => open,
        MEMW_IN => open,
        MEMR_IN => open,
        UPDATE_FLAGS_IN => open,
        MEM_ADDRESS_SEL_IN => open,
        OUTPUT_PORT_EN_IN => open,
        REG_WB_EN_1_IN => open,
        REG_WB_EN_2_IN => open,

        corrected_ccr_flags_in => open,
        alu_flags_in => open,
        alu_result_1_in => open,
        alu_result_2_in => open,
        mem_adr_in => open,
        interrupt_adr_in => open,
        reg_write_address_1_in => ex2_reg_write_address_1,
        reg_write_address_2_in => ex2_reg_write_address_2,
        next_pc_in => ex2_next_pc,

        LOAD_FLAGS_OUT => open,
        PC_WRITE_EN_OUT => open,
        MEM_WRITE_SEL_OUT => open,
        MEMW_OUT => open,
        MEMR_OUT => open,
        UPDATE_FLAGS_OUT => open,
        MEM_ADDRESS_SEL_OUT => open,
        OUTPUT_PORT_EN_OUT => open,
        REG_WB_EN_1_OUT => open,
        REG_WB_EN_2_OUT => open,

        corrected_ccr_flags_out => open,
        alu_flags_out => open,
        alu_result_1_out => open,
        alu_result_2_out => open,
        mem_adr_out => open,
        interrupt_adr_out => open,
        reg_write_address_1_out => mem_reg_write_address_1,
        reg_write_address_2_out => mem_reg_write_address_2,
        next_pc_out => mem_next_pc
    );
Memory_Stage_inst : ENTITY work.memory_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        next_pc_in => mem_next_pc,
        LOAD_FLAGS_IN => open,
        MEM_WRITE_SEL_IN => open,
        MEMW_IN => open,
        MEMR_IN => open,
        MEM_ADDRESS_SEL_IN => open,
        HLT => open,

        corrected_ccr_flags_in => open,
        alu_flags_in => open,
        alu_result_1_in => open,
        mem_adr_in => open,
        interrupt_adr_in => open,
        next_pc_in => open,

        mem_read_data_in => open,

        flag_wb_out => open,
        wb_data_1_out => open,

        mem_address => open,
        mem_write_data_out => open,
        MEMORY => open,
        sp_monitor => open
    );
MEM_WB_reg_inst : ENTITY work.mem_wb_register
    PORT MAP (
        clk => clk,
        reset => reset,

        UPDATE_FLAGS_IN => open,
        OUTPUT_PORT_EN_IN => open,
        REG_WB_EN_1_IN => open,
        REG_WB_EN_2_IN => open,

        flag_wb_in => open,
        wb_data_1_in => open,
        wb_data_2_in => open,
        reg_write_address_1_in => mem_reg_write_address_1,
        reg_write_address_2_in => mem_reg_write_address_2,

        UPDATE_FLAGS_OUT => open,
        OUTPUT_PORT_EN_OUT => open,
        REG_WB_EN_1_OUT => open,
        REG_WB_EN_2_OUT => open,

        flag_wb_out => open,
        wb_data_1_out => open,
        wb_data_2_out => open,
        reg_write_address_1_out => wb_reg_write_address_1,
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