LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY decode_stage IS
    PORT (

        -- Global signals
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        
        -- Inputs from fetch stage
        instr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Inputs from writeback stage
        wb_addr_1_in : IN reg_idx_t;
        wb_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        REG_WB_EN_1_IN : IN STD_LOGIC;
        wb_addr_2_in : IN reg_idx_t;
        wb_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        REG_WB_EN_2_IN : IN STD_LOGIC;

        -- Inputs from Hazard unit
        STALL : IN STD_LOGIC;
        FLUSH : IN STD_LOGIC;

        -- Control signals to execute stage
        LOAD_FLAGS : OUT STD_LOGIC;
        PC_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_SEL : OUT mem_write_sel_t;
        COND_BRANCH : OUT STD_LOGIC;
        HLT : OUT STD_LOGIC;
        MEMW : OUT STD_LOGIC;
        MEMR : OUT STD_LOGIC;
        UPDATE_FLAGS : OUT STD_LOGIC;
        MEM_ADDRESS_SEL : OUT mem_address_sel_t;
        OUTPUT_PORT_EN : OUT STD_LOGIC;
        REG_WB_EN_1 : OUT STD_LOGIC;
        REG_WB_EN_2 : OUT STD_LOGIC;
        ALU_INPUT_SEL : OUT alu_input_sel_t;
        JMP_FLAG_SEL : OUT jmp_flag_sel_t;
        ALU_OP : OUT alu_op_t;

        -- Data signals to execute stage
        read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_1_out : OUT reg_idx_t;
        reg_write_address_2_out : OUT reg_idx_t;
        read_reg_1_out : OUT reg_idx_t;
        read_reg_2_out : OUT reg_idx_t;

        -- Outputs to other Stages
        MULTICYCLE_SEL: OUT multicycle_sel_t;
        MULTICYCLE_STALL: OUT STD_LOGIC;
        INT_TARGERT_ADDR: OUT int_idx_t;
        ID_COND_BRANCH : OUT STD_LOGIC;
        -- monitoring register values for debugging
        reg0_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg3_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg4_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg5_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg6_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg7_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
END ENTITY decode_stage;

ARCHITECTURE rtl OF decode_stage IS
Signal RDST : reg_idx_t;
Signal RSRC1 : reg_idx_t;
Signal RSRC2 : reg_idx_t;

-- OPCODE INPUT
Signal OPCODE_MUX : opcode_t;


BEGIN
    -- Should include, register file, and NOP flushing logic

    -- decode logic
    RDST <= instr_in(26 DOWNTO 24);
    RSRC1 <= instr_in(23 DOWNTO 21);
    RSRC2 <= instr_in(20 DOWNTO 18);
    imm_offset_out <= instr_in(15 DOWNTO 0);
    INT_TARGERT_ADDR <= instr_in(1 DOWNTO 0);
    register_file_inst : entity work.register_file
        PORT MAP (
            clk => clk,
            reset => reset,
            WRITE_ENABLE_1 => REG_WB_EN_1_IN,
            write_addr_1 => wb_addr_1_in,
            write_data_1 => wb_data_1_in,
            WRITE_ENABLE_2 => REG_WB_EN_2_IN,
            write_addr_2 => wb_addr_2_in,
            write_data_2 => wb_data_2_in,
            read_addr_1 => RSRC1,
            read_data_1 => read_data_1_out,
            read_addr_2 => RSRC2,
            read_data_2 => read_data_2_out,
            reg0_out => reg0_out,
            reg1_out => reg1_out,
            reg2_out => reg2_out,
            reg3_out => reg3_out,
            reg4_out => reg4_out,
            reg5_out => reg5_out,
            reg6_out => reg6_out,
            reg7_out => reg7_out
        );

        reg_write_address_1_out <= RDST;
        reg_write_address_2_out <= RSRC1; -- for SWAP, IN and LDM, RSRC1 is also a write destination
        read_reg_1_out <= RSRC1;
        read_reg_2_out <= RSRC2;

        -- Control unit
    OPCODE_MUX <= OPCODE_NOP WHEN (STALL = '1' OR FLUSH = '1') ELSE instr_in(31 DOWNTO 27);
    ID_COND_BRANCH <= '0' when (STALL = '1' OR FLUSH = '1') else instr_in(BR_HINT_COND_BIT);
    control_unit_inst : entity work.control_unit
        PORT MAP (
            OPCODE => OPCODE_MUX,
            cond_branch_hint => instr_in(BR_HINT_COND_BIT),
            LOAD_FLAGS => LOAD_FLAGS,
            PC_WRITE_EN => PC_WRITE_EN,
            MEM_WRITE_SEL => MEM_WRITE_SEL,
            COND_BRANCH => COND_BRANCH,
            HLT => HLT,
            MEMW => MEMW,
            MEMR => MEMR,
            UPDATE_FLAGS => UPDATE_FLAGS,
            MEM_ADDRESS_SEL => MEM_ADDRESS_SEL,
            OUTPUT_PORT_EN => OUTPUT_PORT_EN,
            REG_WB_EN_1 => REG_WB_EN_1,
            REG_WB_EN_2 => REG_WB_EN_2,
            ALU_INPUT_SEL => ALU_INPUT_SEL,
            JMP_FLAG_SEL => JMP_FLAG_SEL,
            ALU_OP => ALU_OP,
            MULTICYCLE_SEL => MULTICYCLE_SEL,
            MULTICYCLE_STALL => MULTICYCLE_STALL
        );
END ARCHITECTURE rtl;