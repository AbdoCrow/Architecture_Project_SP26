LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY execute1_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        ALU_OP : IN alu_op_t;
        ALU_INPUT_SEL : IN alu_input_sel_t;
        UPDATE_FLAGS : IN STD_LOGIC;

        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_result_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        corrected_ccr_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- input port
        input_port_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- forwarding control
        RSRC1_SEL : IN fwd_sel_t;
        RSRC2_SEL : IN fwd_sel_t;
        FLAG_SRC_SEL : IN flag_src_sel_t;
        -- forwarding data
        read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_ex2_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_ex2_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_mem_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_mem_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_wb_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_wb_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        fwd_ex2_flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        fwd_mem_flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        flag_wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0)



    );
END ENTITY execute1_stage;

ARCHITECTURE rtl OF execute1_stage IS
BEGIN
    -- Should contain flag_reg and ALU
    -- control signals that will path through should not be registered here
END ARCHITECTURE rtl;