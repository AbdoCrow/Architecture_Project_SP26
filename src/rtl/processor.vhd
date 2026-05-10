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
    signal fetch_cond_branch : STD_LOGIC;
 
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
    signal dec_MEM_WRITE_SEL    : mem_write_sel_t;
    signal dec_COND_BRANCH      : STD_LOGIC;
    signal dec_HLT              : STD_LOGIC;
    signal dec_MEMW             : STD_LOGIC;
    signal dec_MEMR             : STD_LOGIC;
    signal dec_UPDATE_FLAGS     : STD_LOGIC;
    signal dec_MEM_ADDRESS_SEL  : mem_address_sel_t;
    signal dec_OUTPUT_PORT_EN   : STD_LOGIC;
    signal dec_REG_WB_EN_1      : STD_LOGIC;
    signal dec_REG_WB_EN_2      : STD_LOGIC;
    signal dec_ALU_INPUT_SEL    : alu_input_sel_t;
    signal dec_JMP_FLAG_SEL     : jmp_flag_sel_t;
    signal dec_ALU_OP           : alu_op_t;
    signal dec_MULTICYCLE_SEL   : multicycle_sel_t;
    signal dec_MULTICYCLE_STALL : STD_LOGIC;
    signal dec_INT_TARGET_ADDR  : int_idx_t;
    signal dec_ID_COND_BRANCH   : STD_LOGIC;
 
    -- DECODE stage outputs (data)
    signal dec_read_data_1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dec_read_data_2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal dec_imm_offset       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal dec_reg_write_address_1 : reg_idx_t;
    signal dec_reg_write_address_2 : reg_idx_t;
    signal dec_read_reg_1       : reg_idx_t;
    signal dec_read_reg_2       : reg_idx_t;
    signal dec_input_port        : STD_LOGIC_VECTOR(31 DOWNTO 0);
 
    -- =========================================================
    -- ID/EX1 -> EX1 stage
    -- =========================================================
    signal ex1_LOAD_FLAGS       : STD_LOGIC;
    signal ex1_PC_WRITE_EN      : STD_LOGIC;
    signal ex1_MEM_WRITE_SEL    : mem_write_sel_t;
    signal ex1_COND_BRANCH      : STD_LOGIC;
    signal ex1_HLT              : STD_LOGIC;
    signal ex1_MEMW             : STD_LOGIC;
    signal ex1_MEMR             : STD_LOGIC;
    signal ex1_UPDATE_FLAGS     : STD_LOGIC;
    signal ex1_MEM_ADDRESS_SEL  : mem_address_sel_t;
    signal ex1_OUTPUT_PORT_EN   : STD_LOGIC;
    signal ex1_REG_WB_EN_1      : STD_LOGIC;
    signal ex1_REG_WB_EN_2      : STD_LOGIC;
    signal ex1_ALU_INPUT_SEL    : alu_input_sel_t;
    signal ex1_JMP_FLAG_SEL     : jmp_flag_sel_t;
    signal ex1_ALU_OP           : alu_op_t;
    signal ex1_branch_prediction : STD_LOGIC;
    signal ex1_read_data_1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_read_data_2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_imm_offset       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal ex1_reg_write_address_1 : reg_idx_t;
    signal ex1_reg_write_address_2 : reg_idx_t;
    signal ex1_next_pc          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex1_read_reg_1       : reg_idx_t;
    signal ex1_read_reg_2       : reg_idx_t;
    signal ex1_input_port        : STD_LOGIC_VECTOR(31 DOWNTO 0);
 
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
    signal ex2_MEM_WRITE_SEL    : mem_write_sel_t;
    signal ex2_COND_BRANCH      : STD_LOGIC;
    signal ex2_HLT              : STD_LOGIC;
    signal ex2_MEMW             : STD_LOGIC;
    signal ex2_MEMR             : STD_LOGIC;
    signal ex2_UPDATE_FLAGS     : STD_LOGIC;
    signal ex2_MEM_ADDRESS_SEL  : mem_address_sel_t;
    signal ex2_OUTPUT_PORT_EN   : STD_LOGIC;
    signal ex2_REG_WB_EN_1      : STD_LOGIC;
    signal ex2_REG_WB_EN_2      : STD_LOGIC;
    signal ex2_JMP_FLAG_SEL     : jmp_flag_sel_t;
    signal ex2_corrected_ccr    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ex2_branch_prediction : STD_LOGIC;
    signal ex2_alu_flags        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ex2_alu_result_1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_alu_result_2     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_base_reg_data    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_imm_offset       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal ex2_reg_write_address_1 : reg_idx_t;
    signal ex2_reg_write_address_2 : reg_idx_t;
    signal ex2_next_pc          : STD_LOGIC_VECTOR(31 DOWNTO 0);
 
    -- EX2 stage outputs
    signal ex2_branch_result    : STD_LOGIC;
    signal ex2_branch_pred_out  : STD_LOGIC;
    signal ex2_correct_pc_value : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_mem_adr          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ex2_interrupt_adr    : int_idx_t;
    signal ex2_HLT_out          : STD_LOGIC;
    signal ex2_UPDATE_FLAGS_OUT     : STD_LOGIC;
    signal ex2_ALU_FLAGS_OUT       : STD_LOGIC_VECTOR(2 DOWNTO 0);
 
    -- =========================================================
    -- EX2/MEM -> MEM stage
    -- =========================================================
    signal mem_LOAD_FLAGS       : STD_LOGIC;
    signal mem_PC_WRITE_EN      : STD_LOGIC;
    signal mem_MEM_WRITE_SEL    : mem_write_sel_t;
    signal mem_MEMW             : STD_LOGIC;
    signal mem_MEMR             : STD_LOGIC;
    signal mem_UPDATE_FLAGS     : STD_LOGIC;
    signal mem_MEM_ADDRESS_SEL  : mem_address_sel_t;
    signal mem_OUTPUT_PORT_EN   : STD_LOGIC;
    signal mem_REG_WB_EN_1      : STD_LOGIC;
    signal mem_REG_WB_EN_2      : STD_LOGIC;
    signal mem_corrected_ccr    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal mem_alu_flags        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal mem_alu_result_1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_alu_result_2     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_mem_adr          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_interrupt_adr    : int_idx_t;
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
    signal haz_FETCH_STALL      : STD_LOGIC;
    signal haz_DECODE_STALL     : STD_LOGIC;
    signal haz_FLUSH            : STD_LOGIC;
    signal haz_FETCH_MEMORY_HAZARD : STD_LOGIC;
    signal haz_ALLOW_HW_INT     : STD_LOGIC;
    signal haz_CORRECT_PC       : STD_LOGIC;
 
    -- =========================================================
    -- Forwarding unit outputs
    -- =========================================================
    signal fwd_RSRC1_SEL        : fwd_sel_t;
    signal fwd_RSRC2_SEL        : fwd_sel_t;
    signal fwd_FLAG_SRC_SEL     : STD_LOGIC_VECTOR(1 DOWNTO 0);
 
    -- =========================================================
    -- Interrupt handler outputs
    -- =========================================================
    signal int_INT_REQUEST      : STD_LOGIC;
 
    -- =========================================================
    -- Memory outputs
    -- =========================================================
    signal mem_data_out         : STD_LOGIC_VECTOR(31 DOWNTO 0);



    -- =========================================================
    -- Intermediate operational signals
    -- =========================================================
    signal mem_addr             : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal MEMORY_READ_EN       : STD_LOGIC;
    signal MEMORY_WRITE_EN      : STD_LOGIC;

    signal IF_ID_enable : STD_LOGIC;
    signal ID_EX1_enable : STD_LOGIC;
    signal EX2_MEM_enable : STD_LOGIC;
 
BEGIN

forward_unit_inst : ENTITY work.forwarding_unit
    PORT MAP (
        read_reg_1          => ex1_read_reg_1,
        read_reg_2          => ex1_read_reg_2,

        EX1_UPDATE_FLAGS    => ex2_UPDATE_FLAGS_OUT, -- different naming convention between stages
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
        branch_prediction     => ex2_branch_pred_out,
        branch_result         => ex2_branch_result,
        CORRECT_PC            => haz_CORRECT_PC,

        -- pc write hazard signals
        EX1_PC_WRITE          => ex1_PC_WRITE_EN,
        EX2_PC_WRITE          => ex2_PC_WRITE_EN,
        MEM_PC_WRITE          => mem_PC_WRITE_EN,
        DEC_PC_WRITE          => dec_PC_WRITE_EN,
        --interrupt hazard signals
        EX2_COND_BRANCH       => ex2_COND_BRANCH,
        EX1_COND_BRANCH       => ex1_COND_BRANCH,
        ID_COND_BRANCH        => dec_ID_COND_BRANCH,
        IF_COND_BRANCH        => fetch_cond_branch,

        MULTICYCLE_STALL      => dec_MULTICYCLE_STALL,
        HARDWARE_INTERRUPT    => int_INT_REQUEST,
        ALLOW_HW_INT          => haz_ALLOW_HW_INT,
        STALL                 => haz_STALL,
        FETCH_STALL           => haz_FETCH_STALL,
        DECODE_STALL          => haz_DECODE_STALL,
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

    MEMORY_READ_EN <= mem_MEMR or NOT haz_FETCH_MEMORY_HAZARD; -- 2 to 1 mux simplifed
    MEMORY_WRITE_EN <= mem_MEMW; -- simplied mux too
    mem_addr <= mem_address(11 downto 0) WHEN haz_FETCH_MEMORY_HAZARD = '1' ELSE fetch_pc_out(11 DOWNTO 0); 
    pc_monitor <= fetch_pc_out;
memory_inst: ENTITY work.memory
    PORT MAP (
        clk => clk,
        reset => reset,
        mem_addr => mem_addr,
        mem_data_in => mem_write_data,
        mem_data_out => mem_data_out,
        MEMORY_READ_EN => MEMORY_READ_EN,
        MEMORY_WRITE_EN => MEMORY_WRITE_EN
    );
fetch_stage_inst : ENTITY work.fetch_stage
    PORT MAP (
        clk  => clk,
        reset  => reset,
        next_pc_out => fetch_next_pc,
        instr_out => fetch_instr,

        PC_WRITE_ENABLE  => mem_PC_WRITE_EN,
        FETCH_STALL   => haz_STALL,
        MULTICYCLE_STALL   => dec_MULTICYCLE_STALL,
        MULTICYCLE_SEL  => dec_MULTICYCLE_SEL,
        FLUSH => haz_FLUSH,

        CORRECT_PC  => haz_CORRECT_PC,
        correct_pc_value   => ex2_correct_pc_value,
        fetched_instruction_in => mem_data_out,
        loaded_pc_in => mem_data_out,
        DECODE_INT_TARGET_IDX  => dec_INT_TARGET_ADDR,
        COND_BRANCH  => ex2_COND_BRANCH,
        BRANCH_TAKEN=> ex2_branch_result,
        HLT=> ex2_HLT,
        FETCH_MEMORY_HAZARD => haz_FETCH_MEMORY_HAZARD,
        ALLOW_HW_INT => haz_ALLOW_HW_INT,
        pc_out   => fetch_pc_out,
        branch_prediction_out  => fetch_branch_prediction,
        if_cond_branch => fetch_cond_branch
    );

    IF_ID_enable <= NOT (haz_DECODE_STALL OR ex2_HLT) OR haz_ALLOW_HW_INT;
IF_ID_reg_inst : ENTITY work.if_id_register
    PORT MAP (  
        clk => clk,
        reset => reset,
        next_pc_in => fetch_next_pc,
        next_pc_out => dec_next_pc,
        instr_in => fetch_instr,
        instr_out => decode_instr,
        enable => IF_ID_enable,
        branch_prediction_in  => fetch_branch_prediction,
        branch_prediction_out => dec_branch_prediction,
        input_port_in => in_port,
        input_port_out => dec_input_port
    );
decode_stage_inst : ENTITY work.decode_stage
    PORT MAP (
        clk => clk,
        reset => reset,
  
        -- Inputs from fetch stage
        instr_in => decode_instr, 
        -- Inputs from writeback stage
        wb_addr_1_in           => wb_reg_write_address_1,
        wb_data_1_in           => wb_data_1,
        REG_WB_EN_1_IN         => wb_REG_WB_EN_1,
        wb_addr_2_in           => wb_reg_write_address_2,
        wb_data_2_in           => wb_data_2,
        REG_WB_EN_2_IN         => wb_REG_WB_EN_2,

        -- Inputs from Hazard unit
        STALL                  => haz_decode_STALL,
        FLUSH                  => haz_FLUSH,
        
        -- Control signals to execute stage
        LOAD_FLAGS             => dec_LOAD_FLAGS,
        PC_WRITE_EN            => dec_PC_WRITE_EN,
        MEM_WRITE_SEL          => dec_MEM_WRITE_SEL,
        COND_BRANCH            => dec_COND_BRANCH,
        HLT                    => dec_HLT,
        MEMW                   => dec_MEMW,
        MEMR                   => dec_MEMR,
        UPDATE_FLAGS           => dec_UPDATE_FLAGS,
        MEM_ADDRESS_SEL        => dec_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN         => dec_OUTPUT_PORT_EN,
        REG_WB_EN_1            => dec_REG_WB_EN_1,
        REG_WB_EN_2            => dec_REG_WB_EN_2,
        ALU_INPUT_SEL          => dec_ALU_INPUT_SEL,
        JMP_FLAG_SEL           => dec_JMP_FLAG_SEL,
        ALU_OP                 => dec_ALU_OP,
        -- Data signals to execute stage
        read_data_1_out        => dec_read_data_1,
        read_data_2_out        => dec_read_data_2,
        imm_offset_out         => dec_imm_offset,
        reg_write_address_1_out => dec_reg_write_address_1,
        reg_write_address_2_out => dec_reg_write_address_2,
        read_reg_1_out         => dec_read_reg_1,
        read_reg_2_out         => dec_read_reg_2,

        -- Outputs to other Stages
        MULTICYCLE_SEL         => dec_MULTICYCLE_SEL,
        MULTICYCLE_STALL       => dec_MULTICYCLE_STALL,
        INT_TARGERT_ADDR       => dec_INT_TARGET_ADDR,
        ID_COND_BRANCH         => dec_ID_COND_BRANCH,

        -- monitoring register values for debugging
        reg0_out               => r0_monitor,
        reg1_out               => r1_monitor,
        reg2_out               => r2_monitor,
        reg3_out               => r3_monitor,
        reg4_out               => r4_monitor,
        reg5_out               => r5_monitor,
        reg6_out               => r6_monitor,
        reg7_out               => r7_monitor
    );

    ID_EX1_enable <= NOT (ex2_HLT);
ID_EX1_reg_inst : ENTITY work.id_ex1_register 
    port map (
        clk=> clk,
        reset=> reset,
        enable => ID_EX1_enable,
        LOAD_FLAGS_IN => dec_LOAD_FLAGS,
        PC_WRITE_EN_IN => dec_PC_WRITE_EN,
        MEM_WRITE_SEL_IN => dec_MEM_WRITE_SEL,
        COND_BRANCH_IN => dec_COND_BRANCH,
        HLT_IN => dec_HLT,
        MEMW_IN => dec_MEMW,
        MEMR_IN  => dec_MEMR,
        UPDATE_FLAGS_IN => dec_UPDATE_FLAGS,
        MEM_ADDRESS_SEL_IN  => dec_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN_IN  => dec_OUTPUT_PORT_EN,
        REG_WB_EN_1_IN  => dec_REG_WB_EN_1,
        REG_WB_EN_2_IN  => dec_REG_WB_EN_2,
        ALU_INPUT_SEL_IN  => dec_ALU_INPUT_SEL,
        JMP_FLAG_SEL_IN => dec_JMP_FLAG_SEL,
        ALU_OP_IN => dec_ALU_OP,
        input_port_in => dec_input_port,

        branch_prediction_in => dec_branch_prediction,
        read_data_1_in => dec_read_data_1,
        read_data_2_in => dec_read_data_2,
        imm_offset_in  => dec_imm_offset,
        reg_write_address_1_in => dec_reg_write_address_1,
        reg_write_address_2_in => dec_reg_write_address_2,
        next_pc_in => dec_next_pc,
        read_reg_1_in  => dec_read_reg_1,
        read_reg_2_in => dec_read_reg_2,

        LOAD_FLAGS_OUT => ex1_LOAD_FLAGS,
        PC_WRITE_EN_OUT => ex1_PC_WRITE_EN,
        MEM_WRITE_SEL_OUT  => ex1_MEM_WRITE_SEL,
        COND_BRANCH_OUT   => ex1_COND_BRANCH,
        HLT_OUT  => ex1_HLT,
        MEMW_OUT  => ex1_MEMW,
        MEMR_OUT  => ex1_MEMR,
        UPDATE_FLAGS_OUT => ex1_UPDATE_FLAGS,
        MEM_ADDRESS_SEL_OUT=> ex1_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN_OUT=> ex1_OUTPUT_PORT_EN,
        REG_WB_EN_1_OUT => ex1_REG_WB_EN_1,
        REG_WB_EN_2_OUT  => ex1_REG_WB_EN_2,
        ALU_INPUT_SEL_OUT => ex1_ALU_INPUT_SEL,
        JMP_FLAG_SEL_OUT  => ex1_JMP_FLAG_SEL,
        ALU_OP_OUT => ex1_ALU_OP,

        branch_prediction_out => ex1_branch_prediction,
        read_data_1_out => ex1_read_data_1,
        read_data_2_out => ex1_read_data_2,
        imm_offset_out => ex1_imm_offset,
        reg_write_address_1_out => ex1_reg_write_address_1,
        reg_write_address_2_out => ex1_reg_write_address_2,
        next_pc_out => ex1_next_pc,
        read_reg_1_out => ex1_read_reg_1,
        read_reg_2_out  => ex1_read_reg_2,
        input_port_out => ex1_input_port
    );
execute1_stage_inst : ENTITY work.execute1_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        ALU_OP => ex1_ALU_OP,
        ALU_INPUT_SEL => ex1_ALU_INPUT_SEL,
        UPDATE_FLAGS => wb_UPDATE_FLAGS,

        imm_offset_in  => ex1_imm_offset,
        alu_result_1_out  => ex1_alu_result_1,
        alu_result_2_out  => ex1_alu_result_2,
        base_reg_data_out  => ex1_base_reg_data,
        alu_flags_out  => ex1_alu_flags,
        corrected_ccr_flags_out => ex1_corrected_ccr,

        -- input port
        input_port_data_in => ex1_input_port,

        -- forwarding control
        RSRC1_SEL => fwd_RSRC1_SEL,
        RSRC2_SEL => fwd_RSRC2_SEL,
        FLAG_SRC_SEL => fwd_FLAG_SRC_SEL,
        -- forwarding data
        read_data_1_in => ex1_read_data_1,
        read_data_2_in => ex1_read_data_2,
        fwd_ex2_data_1 => ex2_alu_result_1,
        fwd_ex2_data_2 => ex2_alu_result_2,
        fwd_mem_data_1 => mem_wb_data_1,
        fwd_mem_data_2 => mem_alu_result_2,
        fwd_wb_data_1 => wb_data_1,
        fwd_wb_data_2  => wb_data_2,

        fwd_ex2_flags => ex2_alu_flags_OUT,
        fwd_mem_flags => mem_alu_flags,
        flag_wb => wb_flag_wb,


        --debug 
        CCR_monitor => ccr_monitor
        
    );
EX1_EX2_reg_inst : ENTITY work.ex1_ex2_register
    PORT MAP (  
        clk => clk,
        reset=> reset,
        FLUSH  => haz_FLUSH,

        LOAD_FLAGS_IN => ex1_LOAD_FLAGS,
        PC_WRITE_EN_IN => ex1_PC_WRITE_EN,
        MEM_WRITE_SEL_IN  => ex1_MEM_WRITE_SEL,
        COND_BRANCH_IN  => ex1_COND_BRANCH,
        HLT_IN   => ex1_HLT,
        MEMW_IN => ex1_MEMW,
        MEMR_IN => ex1_MEMR,
        UPDATE_FLAGS_IN  => ex1_UPDATE_FLAGS,
        MEM_ADDRESS_SEL_IN  => ex1_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN_IN  => ex1_OUTPUT_PORT_EN,
        REG_WB_EN_1_IN  => ex1_REG_WB_EN_1,
        REG_WB_EN_2_IN => ex1_REG_WB_EN_2,
        JMP_FLAG_SEL_IN  => ex1_JMP_FLAG_SEL,

        corrected_ccr_flags_in => ex1_corrected_ccr,
        branch_prediction_in  => ex1_branch_prediction,
        alu_flags_in  => ex1_alu_flags,
        alu_result_1_in => ex1_alu_result_1,
        alu_result_2_in => ex1_alu_result_2,
        base_reg_data_in  => ex1_base_reg_data,
        imm_offset_in  => ex1_imm_offset,
        reg_write_address_1_in => ex1_reg_write_address_1,
        reg_write_address_2_in => ex1_reg_write_address_2,
        next_pc_in  => ex1_next_pc,

        LOAD_FLAGS_OUT  => ex2_LOAD_FLAGS,
        PC_WRITE_EN_OUT => ex2_PC_WRITE_EN,
        MEM_WRITE_SEL_OUT=> ex2_MEM_WRITE_SEL,
        COND_BRANCH_OUT => ex2_COND_BRANCH,
        HLT_OUT  => ex2_HLT,
        MEMW_OUT => ex2_MEMW,
        MEMR_OUT  => ex2_MEMR,
        UPDATE_FLAGS_OUT => ex2_UPDATE_FLAGS,
        MEM_ADDRESS_SEL_OUT=> ex2_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN_OUT=> ex2_OUTPUT_PORT_EN,
        REG_WB_EN_1_OUT => ex2_REG_WB_EN_1,
        REG_WB_EN_2_OUT  => ex2_REG_WB_EN_2,
        JMP_FLAG_SEL_OUT => ex2_JMP_FLAG_SEL,

        corrected_ccr_flags_out => ex2_corrected_ccr,
        branch_prediction_out  => ex2_branch_prediction,
        alu_flags_out  => ex2_alu_flags,
        alu_result_1_out => ex2_alu_result_1,
        alu_result_2_out => ex2_alu_result_2,
        base_reg_data_out => ex2_base_reg_data,
        imm_offset_out => ex2_imm_offset,
        reg_write_address_1_out => ex2_reg_write_address_1,
        reg_write_address_2_out => ex2_reg_write_address_2,
        next_pc_out => ex2_next_pc
    );
execute2_stage_inst : ENTITY work.execute2_stage
    PORT MAP (
        COND_BRANCH_IN => ex2_COND_BRANCH,
        JMP_FLAG_SEL_IN => ex2_JMP_FLAG_SEL,
        corrected_ccr_flags_in => ex2_corrected_ccr,
        base_reg_data_in => ex2_base_reg_data,
        imm_offset_in => ex2_imm_offset,
        next_pc_in => ex2_next_pc,
        branch_prediction_in => ex2_branch_prediction,
        ALU_flags_in => ex2_alu_flags,
        ALU_FLAGS_OUT => ex2_ALU_FLAGS_OUT,
        UPDATE_FLAGS_IN => ex2_UPDATE_FLAGS,
        UPDATE_FLAGS_OUT => ex2_UPDATE_FLAGS_OUT,
        branch_result_out => ex2_branch_result,
        branch_prediction_out => ex2_branch_pred_out,
        correct_pc_value_out => ex2_correct_pc_value,
        mem_adr_out => ex2_mem_adr,
        interrupt_adr_out => ex2_interrupt_adr
    );

EX2_MEM_enable <= NOT ex2_HLT;
EX2_MEM_reg_inst : ENTITY work.ex2_mem_register
    port map (
        clk => clk,
        reset => reset,
        enable => EX2_MEM_enable,

        LOAD_FLAGS_IN => ex2_LOAD_FLAGS,
        PC_WRITE_EN_IN => ex2_PC_WRITE_EN,
        MEM_WRITE_SEL_IN => ex2_MEM_WRITE_SEL,
        MEMW_IN => ex2_MEMW,
        MEMR_IN => ex2_MEMR,
        UPDATE_FLAGS_IN => ex2_UPDATE_FLAGS_OUT,
        MEM_ADDRESS_SEL_IN => ex2_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN_IN => ex2_OUTPUT_PORT_EN,
        REG_WB_EN_1_IN => ex2_REG_WB_EN_1,
        REG_WB_EN_2_IN => ex2_REG_WB_EN_2,

        corrected_ccr_flags_in => ex2_corrected_ccr,
        alu_flags_in  => ex2_alu_flags_OUT,
        alu_result_1_in => ex2_alu_result_1,
        alu_result_2_in => ex2_alu_result_2,
        mem_adr_in => ex2_mem_adr,
        interrupt_adr_in => ex2_interrupt_adr,
        reg_write_address_1_in => ex2_reg_write_address_1,
        reg_write_address_2_in => ex2_reg_write_address_2,
        next_pc_in  => ex2_next_pc,

        LOAD_FLAGS_OUT => mem_LOAD_FLAGS,
        PC_WRITE_EN_OUT => mem_PC_WRITE_EN,
        MEM_WRITE_SEL_OUT => mem_MEM_WRITE_SEL,
        MEMW_OUT => mem_MEMW,
        MEMR_OUT  => mem_MEMR,
        UPDATE_FLAGS_OUT => mem_UPDATE_FLAGS,
        MEM_ADDRESS_SEL_OUT => mem_MEM_ADDRESS_SEL,
        OUTPUT_PORT_EN_OUT => mem_OUTPUT_PORT_EN,
        REG_WB_EN_1_OUT => mem_REG_WB_EN_1,
        REG_WB_EN_2_OUT => mem_REG_WB_EN_2,

        corrected_ccr_flags_out => mem_corrected_ccr,
        alu_flags_out => mem_alu_flags,
        alu_result_1_out => mem_alu_result_1,
        alu_result_2_out => mem_alu_result_2,
        mem_adr_out => mem_mem_adr,
        interrupt_adr_out => mem_interrupt_adr,
        reg_write_address_1_out => mem_reg_write_address_1,
        reg_write_address_2_out => mem_reg_write_address_2,
        next_pc_out => mem_next_pc
    );
Memory_Stage_inst : ENTITY work.memory_stage
    PORT MAP (
        clk => clk,
        reset => reset,
        next_pc_in => mem_next_pc,
        LOAD_FLAGS_IN => mem_LOAD_FLAGS,
        MEM_WRITE_SEL_IN => mem_MEM_WRITE_SEL,
        MEMW_IN => mem_MEMW,
        MEMR_IN => mem_MEMR,
        MEM_ADDRESS_SEL_IN => mem_MEM_ADDRESS_SEL,
        HLT => ex2_HLT,

        corrected_ccr_flags_in => mem_corrected_ccr,
        alu_flags_in => mem_alu_flags,
        alu_result_1_in => mem_alu_result_1,
        mem_adr_in => mem_mem_adr,
        interrupt_adr_in => mem_interrupt_adr,

        mem_read_data_in  => mem_data_out,

        flag_wb_out => mem_flag_wb,
        wb_data_1_out  => mem_wb_data_1,

        mem_address => mem_address,
        mem_write_data_out => mem_write_data,
        MEMORY => mem_MEMORY,
        sp_monitor => sp_monitor
    );
MEM_WB_reg_inst : ENTITY work.mem_wb_register
    PORT MAP (
        clk => clk,
        reset  => reset,

        UPDATE_FLAGS_IN => mem_UPDATE_FLAGS,
        OUTPUT_PORT_EN_IN => mem_OUTPUT_PORT_EN,
        REG_WB_EN_1_IN => mem_REG_WB_EN_1,
        REG_WB_EN_2_IN => mem_REG_WB_EN_2,

        flag_wb_in => mem_flag_wb,
        wb_data_1_in => mem_wb_data_1,
        wb_data_2_in => mem_alu_result_2,
        reg_write_address_1_in => mem_reg_write_address_1,
        reg_write_address_2_in => mem_reg_write_address_2,

        UPDATE_FLAGS_OUT => wb_UPDATE_FLAGS,
        OUTPUT_PORT_EN_OUT => wb_OUTPUT_PORT_EN,
        REG_WB_EN_1_OUT  => wb_REG_WB_EN_1,
        REG_WB_EN_2_OUT  => wb_REG_WB_EN_2,

        flag_wb_out => wb_flag_wb,
        wb_data_1_out => wb_data_1,
        wb_data_2_out => wb_data_2,
        reg_write_address_1_out => wb_reg_write_address_1,
        reg_write_address_2_out => wb_reg_write_address_2
    );
output_port_inst : ENTITY work.output_port
    PORT MAP (
        clk => clk,
        reset => reset,
        enable => wb_OUTPUT_PORT_EN,
        output_port_in => wb_data_1,
        output_port_out => out_port
    );

END ARCHITECTURE rtl;