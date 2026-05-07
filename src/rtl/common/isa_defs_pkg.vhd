LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE isa_defs_pkg IS
    SUBTYPE opcode_t IS STD_LOGIC_VECTOR(4 DOWNTO 0);
    SUBTYPE reg_idx_t IS STD_LOGIC_VECTOR(2 DOWNTO 0);

    SUBTYPE alu_op_t IS STD_LOGIC_VECTOR(3 DOWNTO 0);
    SUBTYPE alu_input_sel_t IS STD_LOGIC_VECTOR(2 DOWNTO 0);
    SUBTYPE jmp_flag_sel_t IS STD_LOGIC_VECTOR(1 DOWNTO 0);
    SUBTYPE mem_address_sel_t IS STD_LOGIC_VECTOR(1 DOWNTO 0);
    SUBTYPE mem_write_sel_t IS STD_LOGIC_VECTOR(1 DOWNTO 0);
    SUBTYPE multicycle_sel_t IS STD_LOGIC_VECTOR(1 DOWNTO 0);
    SUBTYPE fwd_sel_t IS STD_LOGIC_VECTOR(2 DOWNTO 0);
    SUBTYPE flag_src_sel_t IS STD_LOGIC_VECTOR(1 DOWNTO 0);
    SUBTYPE int_idx_t IS STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- ISA-visible opcodes.
    CONSTANT OPCODE_NOP  : opcode_t := "00000";
    CONSTANT OPCODE_HLT  : opcode_t := "00001";
    CONSTANT OPCODE_SETC : opcode_t := "00010";
    CONSTANT OPCODE_NOT  : opcode_t := "00011";
    CONSTANT OPCODE_INC  : opcode_t := "00100";
    CONSTANT OPCODE_OUT  : opcode_t := "00101";
    CONSTANT OPCODE_IN   : opcode_t := "00110";
    CONSTANT OPCODE_MOV  : opcode_t := "01000";
    CONSTANT OPCODE_SWAP : opcode_t := "01001";
    CONSTANT OPCODE_ADD  : opcode_t := "01010";
    CONSTANT OPCODE_SUB  : opcode_t := "01011";
    CONSTANT OPCODE_AND  : opcode_t := "01100";
    CONSTANT OPCODE_IADD : opcode_t := "01101";
    CONSTANT OPCODE_PUSH : opcode_t := "10000";
    CONSTANT OPCODE_POP  : opcode_t := "10001";
    CONSTANT OPCODE_LDM  : opcode_t := "10010";
    CONSTANT OPCODE_LDD  : opcode_t := "10011";
    CONSTANT OPCODE_STD  : opcode_t := "10100";
    CONSTANT OPCODE_JZ   : opcode_t := "11000";
    CONSTANT OPCODE_JN   : opcode_t := "11001";
    CONSTANT OPCODE_JC   : opcode_t := "11010";
    CONSTANT OPCODE_JMP  : opcode_t := "11011";
    CONSTANT OPCODE_CALL : opcode_t := "11100";
    CONSTANT OPCODE_RET  : opcode_t := "11101";
    CONSTANT OPCODE_INT  : opcode_t := "11110";
    CONSTANT OPCODE_RTI  : opcode_t := "11111";

    -- Internal-only opcodes (decode injected; not assembler-supported).
    CONSTANT OPCODE_INT2  : opcode_t := "01110";
    CONSTANT OPCODE_INT3  : opcode_t := "01111";

    -- Interrupt index encoding in instruction bits [1:0].
    CONSTANT INT_IDX_SW_0 : int_idx_t := "10";
    CONSTANT INT_IDX_HW   : int_idx_t := "01";
    CONSTANT INT_IDX_SW_1 : int_idx_t := "11";

    -- Early decode branch hint bits in instr[31:0].
    CONSTANT BR_HINT_COND_BIT : INTEGER := 17;
    CONSTANT BR_HINT_UNCOND_BIT : INTEGER := 16;

    -- ALU operation identifiers.
    CONSTANT ALU_OP_NOP : alu_op_t := "0000";
    CONSTANT ALU_OP_PASS_A : alu_op_t := "0001";
    CONSTANT ALU_OP_PASS_B : alu_op_t := "0010";
    CONSTANT ALU_OP_NOT_A : alu_op_t := "0011";
    CONSTANT ALU_OP_INC_A : alu_op_t := "0100";
    CONSTANT ALU_OP_SETC : alu_op_t := "0101";
    CONSTANT ALU_OP_ADD : alu_op_t := "0110";
    CONSTANT ALU_OP_SUB : alu_op_t := "0111";
    CONSTANT ALU_OP_AND : alu_op_t := "1000";
    CONSTANT ALU_OP_SWAP : alu_op_t := "1001";
    -- SWAP/INT micro-operations reuse generic PASS_A/PASS_B with control-path sequencing.

    -- ALU input select.
    CONSTANT ALU_INPUT_RSRC2 : alu_input_sel_t := "000";
    CONSTANT ALU_INPUT_IN_PORT : alu_input_sel_t := "001";
    CONSTANT ALU_INPUT_IMMEDIATE : alu_input_sel_t := "010";

    -- Branch condition selector.
    CONSTANT JMP_FLAG_Z : jmp_flag_sel_t := "00";
    CONSTANT JMP_FLAG_N : jmp_flag_sel_t := "01";
    CONSTANT JMP_FLAG_C : jmp_flag_sel_t := "10";
    CONSTANT JMP_FLAG_NONE : jmp_flag_sel_t := "11";
    CONSTANT CARRY_FLAG_BIT : INTEGER := 2;
    CONSTANT ZERO_FLAG_BIT : INTEGER := 0;
    CONSTANT NEGATIVE_FLAG_BIT : INTEGER := 1;
    -- Memory source/address selectors.
    CONSTANT MEM_WRITE_ALU_DATA : mem_write_sel_t := "00";
    CONSTANT MEM_WRITE_PC_DATA : mem_write_sel_t := "01";
    CONSTANT MEM_WRITE_FLAGS_DATA : mem_write_sel_t := "10";
    CONSTANT MEM_WRITE_RSVD : mem_write_sel_t := "11";

    CONSTANT MEM_ADDRESS_CALC : mem_address_sel_t := "00";
    CONSTANT MEM_ADDRESS_INT_VECTOR : mem_address_sel_t := "01";
    CONSTANT MEM_ADDRESS_SP_PUSH : mem_address_sel_t := "10";
    CONSTANT MEM_ADDRESS_SP_POP : mem_address_sel_t := "11";

    -- Decode-injected multicycle selection.
    CONSTANT MULTICYCLE_NONE : multicycle_sel_t := "00";
    CONSTANT MULTICYCLE_RET_STEP : multicycle_sel_t := "01";
    CONSTANT MULTICYCLE_INT2 : multicycle_sel_t := "10";
    CONSTANT MULTICYCLE_INT3 : multicycle_sel_t := "11";

    -- Forwarding select encoding.
    CONSTANT FWD_FROM_REGFILE : fwd_sel_t := "000";
    CONSTANT FWD_FROM_EX1 : fwd_sel_t := "010";
    CONSTANT FWD_FROM_EX1_PORT2 : fwd_sel_t := "011";
    CONSTANT FWD_FROM_EX2 : fwd_sel_t := "100";
    CONSTANT FWD_FROM_EX2_PORT2 : fwd_sel_t := "101";
    CONSTANT FWD_FROM_MEM : fwd_sel_t := "110";
    CONSTANT FWD_FROM_MEM_PORT2 : fwd_sel_t := "111";

    CONSTANT FLAG_FROM_EX1 : flag_src_sel_t := "00";
    CONSTANT FLAG_FROM_EX2 : flag_src_sel_t := "01";
    CONSTANT FLAG_FROM_MEM : flag_src_sel_t := "10";
    CONSTANT FLAG_FROM_REGFILE : flag_src_sel_t := "11";

END PACKAGE isa_defs_pkg;

PACKAGE BODY isa_defs_pkg IS
END PACKAGE BODY isa_defs_pkg;