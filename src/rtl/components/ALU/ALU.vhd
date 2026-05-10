LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY ALU IS
    PORT (
        A       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        prev_flags : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        output_flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALUOP   : IN  alu_op_t;
        Result1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Result2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ALU;
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY ALU IS
    PORT (
        A            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        prev_flags   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        output_flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALUOP        : IN  alu_op_t;
        Result1      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Result2      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ALU;

ARCHITECTURE Behavioral OF ALU IS

    SIGNAL result_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL carry_out : STD_LOGIC;

BEGIN

    PROCESS(A, B, ALUOP, prev_flags)
        VARIABLE temp : unsigned(32 DOWNTO 0);
    BEGIN
        carry_out <= '0';
        CASE ALUOP IS

            WHEN ALU_OP_ADD =>
                temp := unsigned('0' & A) + unsigned('0' & B);
                result_int <= std_logic_vector(temp(31 DOWNTO 0));
                carry_out <= temp(32);
            WHEN ALU_OP_SUB =>
                temp := unsigned('0' & A) - unsigned('0' & B);
                result_int <= std_logic_vector(temp(31 DOWNTO 0));
                carry_out <= temp(32);
            WHEN ALU_OP_INC_A =>
                temp := unsigned('0' & A) + 1;
                result_int <= std_logic_vector(temp(31 DOWNTO 0));
                carry_out <= temp(32);
            WHEN ALU_OP_AND =>
                result_int <= A AND B;
                carry_out <= prev_flags(CARRY_FLAG_BIT); -- AND does not affect carry, so pass through previous carry
            WHEN ALU_OP_PASS =>
                result_int <= A;
                carry_out <= prev_flags(CARRY_FLAG_BIT); -- PASS does not affect carry, so pass through previous carry
            WHEN ALU_OP_NOT_A =>
                result_int <= NOT A;
                carry_out <= prev_flags(CARRY_FLAG_BIT); -- NOT does not affect carry, so pass through previous carry
            WHEN ALU_OP_SETC =>
                result_int <= (31 downto 1 => '0') & prev_flags(CARRY_FLAG_BIT); -- SETC sets the least significant bit to the previous carry, other bits are 0
                carry_out <= '1';
            WHEN OTHERS =>
                result_int <= (OTHERS => '0');
                carry_out <= prev_flags(CARRY_FLAG_BIT); 
        END CASE;
    END PROCESS;

    Result1 <= result_int;
    Result2 <= B;
    
    output_flags(CARRY_FLAG_BIT) <= carry_out; 
    output_flags(NEGATIVE_FLAG_BIT) <= result_int(31) WHEN ALUOP = ALU_OP_NOT_A OR ALUOP = ALU_OP_AND or ALUOP = ALU_OP_SUB or ALUOP = ALU_OP_INC_A or ALUOP = ALU_OP_ADD  ELSE prev_flags(NEGATIVE_FLAG_BIT); 
    output_flags(ZERO_FLAG_BIT) <= '1' WHEN result_int = x"00000000" AND (ALUOP = ALU_OP_NOT_A OR ALUOP = ALU_OP_AND or ALUOP = ALU_OP_SUB or ALUOP = ALU_OP_INC_A or ALUOP = ALU_OP_ADD) 
                                        ELSE '0' WHEN ALUOP = ALU_OP_NOT_A OR ALUOP = ALU_OP_AND or ALUOP = ALU_OP_SUB or ALUOP = ALU_OP_INC_A or ALUOP = ALU_OP_ADD 
                                        ELSE prev_flags(ZERO_FLAG_BIT); 
END Behavioral;