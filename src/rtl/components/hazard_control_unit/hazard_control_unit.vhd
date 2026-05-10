LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY hazard_control_unit IS
    PORT (
        --Structural hazard signals
        MEMORY : IN STD_LOGIC;
        FETCH_MEMORY_HAZARD : OUT STD_LOGIC;

        -- load use hazard signals
        read_reg_1 : IN reg_idx_t;
        read_reg_2 : IN reg_idx_t;
        ID_EX1_WRITE_ADDRESS : IN reg_idx_t;
        ID_EX1_WRITE_ENABLE : IN STD_LOGIC;
        EX1_MEMR : IN STD_LOGIC;
        EX1_EX2_WRITE_ADDRESS : IN reg_idx_t;
        EX1_EX2_WRITE_ENABLE : IN STD_LOGIC;
        EX2_MEMR : IN STD_LOGIC;

        -- control hazard signals
        branch_prediction : IN STD_LOGIC;
        branch_result : IN STD_LOGIC;
        CORRECT_PC : OUT STD_LOGIC;

        -- pc write hazard signals
        DEC_PC_WRITE : IN STD_LOGIC;
        EX1_PC_WRITE : IN STD_LOGIC;
        EX2_PC_WRITE : IN STD_LOGIC;
        MEM_PC_WRITE : IN STD_LOGIC;
        --interrupt hazard signals
        EX2_COND_BRANCH : IN STD_LOGIC;
        EX1_COND_BRANCH : IN STD_LOGIC;
        ID_COND_BRANCH : IN STD_LOGIC;
        IF_COND_BRANCH : IN STD_LOGIC;
        IF_UNCOND_BRANCH : IN STD_LOGIC;
        MULTICYCLE_STALL : IN STD_LOGIC;
        HARDWARE_INTERRUPT : IN STD_LOGIC;
        ALLOW_HW_INT : OUT STD_LOGIC;
        STALL : OUT STD_LOGIC;
        FETCH_STALL: OUT STD_LOGIC;
        DECODE_STALL: OUT STD_LOGIC;
        FLUSH : OUT STD_LOGIC
    );
END ENTITY hazard_control_unit;

ARCHITECTURE rtl OF hazard_control_unit IS
SIGNAL DECODESTALL : STD_LOGIC;
SIGNAL FETCHSTALL : STD_LOGIC;
BEGIN
    -- Structural hazard: Memory access in EX1 stage causes a stall in IF stage
    FETCH_MEMORY_HAZARD <= MEMORY;
    STALL <= FETCHSTALL OR DECODESTALL;
    FETCH_STALL <= FETCHSTALL;
    DECODE_STALL <= DECODESTALL;
    -- PC write hazard: If there is a pending PC write in EX1, EX2, or MEM stage, stall the IF stage to prevent overwriting the PC with an incorrect value
    -- Load-use hazard: If EX1 stage is performing a memory read and the destination register matches either source register in ID stage, stall the pipeline
    PROCESS(read_reg_1, read_reg_2, ID_EX1_WRITE_ADDRESS, ID_EX1_WRITE_ENABLE, EX1_MEMR, EX1_EX2_WRITE_ADDRESS, EX1_EX2_WRITE_ENABLE, EX2_MEMR, EX1_PC_WRITE)
    BEGIN
        IF (EX1_MEMR = '1'  AND ID_EX1_WRITE_ENABLE = '1' AND (ID_EX1_WRITE_ADDRESS = read_reg_1 OR ID_EX1_WRITE_ADDRESS = read_reg_2)) OR 
            (EX2_MEMR = '1' AND EX1_EX2_WRITE_ENABLE = '1' AND (EX1_EX2_WRITE_ADDRESS = read_reg_1 OR EX1_EX2_WRITE_ADDRESS = read_reg_2)) or
            EX1_PC_WRITE = '1'
         THEN
            DECODESTALL <= '1';
        ELSE
            DECODESTALL <= '0';
        END IF;
    END PROCESS;
    PROCESS(EX1_PC_WRITE, EX2_PC_WRITE, DEC_PC_WRITE, HARDWARE_INTERRUPT, MEM_PC_WRITE)
    BEGIN
        IF (EX1_PC_WRITE = '1' OR EX2_PC_WRITE = '1' OR DEC_PC_WRITE = '1' OR MEM_PC_WRITE = '1') OR
            HARDWARE_INTERRUPT = '1' THEN
            FETCHSTALL <= '1';
        ELSE
            FETCHSTALL <= '0';
        END IF;
    END PROCESS;
    -- Control hazard: If there is a branch misprediction, flush the pipeline and correct the PC
    PROCESS(branch_prediction, branch_result)
    BEGIN
        IF (branch_prediction /= branch_result) THEN
            CORRECT_PC <= '1';
        ELSE
            CORRECT_PC <= '0';
        END IF;
    END PROCESS;
    -- Control hazard: If there is a branch misprediction, flush the pipeline and correct the PC, flush before pc correction to ensure incorrect instruction is not executed
    PROCESS(branch_prediction, branch_result, MEM_PC_WRITE)
    BEGIN
        IF (branch_prediction /= branch_result) OR MEM_PC_WRITE = '1' THEN
            FLUSH <= '1';
        ELSE
            FLUSH <= '0';
        END IF;
    END PROCESS;
    -- Hardware interrupt hazard: If there is a hardware interrupt and there are no pending control hazards or multicycle stalls, allow the interrupt to be serviced
    PROCESS(HARDWARE_INTERRUPT, EX2_COND_BRANCH, EX1_COND_BRANCH, ID_COND_BRANCH, MULTICYCLE_STALL, MEM_PC_WRITE, EX1_PC_WRITE, EX2_PC_WRITE, IF_COND_BRANCH, DEC_PC_WRITE, IF_UNCOND_BRANCH)
    BEGIN
        IF (HARDWARE_INTERRUPT = '1' 
        AND EX2_COND_BRANCH = '0' 
        AND EX1_COND_BRANCH = '0' 
        AND ID_COND_BRANCH = '0' 
        AND MULTICYCLE_STALL = '0'
        AND MEM_PC_WRITE = '0'
        AND EX1_PC_WRITE = '0'
        AND EX2_PC_WRITE = '0'
        AND DEC_PC_WRITE = '0'
        AND IF_COND_BRANCH = '0'
        AND IF_UNCOND_BRANCH = '0'
        ) THEN
            ALLOW_HW_INT <= '1';
        ELSE
            ALLOW_HW_INT <= '0';
        END IF;
    END PROCESS;
    
END ARCHITECTURE rtl;