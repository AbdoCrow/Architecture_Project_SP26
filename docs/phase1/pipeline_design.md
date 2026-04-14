# Pipeline Design (Phase 1)

## 6 Stages

1. Fetch
2. Decode
3. Execute-1
4. Execute-2
5. Memory
6. Write-Back

## Stage responsibilities

### 1) Fetch

- Fetches `instr` and `next_pc`.
- Performs early decode for immediate branches using instruction bits:
	- `instr[16]`: unconditional immediate branch hint (`JMP`, `CALL`)
	- `instr[17]`: conditional branch hint (`JZ/JN/JC`)
- Hosts dynamic branch prediction unit (2-bit predictor).
- Computes predicted fetch address and emits `branch_prediction` with IF payload.

### 2) Decode

- Performs standard decode and register reads.
- Builds control bundle for downstream stages.
- Contains multicycle instruction sequencer:
	- If instruction requires follow-up internal cycle (`SWAP2`, `INT2`, `INT3`, return sequence), assert `MULTICYCLE_STALL`.
	- Stall fetch and PC while decode injects internal follow-up operation selected by `MULTICYCLE_SEL`.

### 3) Execute-1

- Performs ALU operation.
- Uses forwarding for ALU operands.
- Applies flag forwarding inputs used by next stage branch comparator.

### 4) Execute-2

- Evaluates branch condition against forwarded/corrected flags.
- Compares real branch result with `branch_prediction`.
- On misprediction:
	- assert flush of 3 younger instructions (`IF/ID`, `ID/EX1`, `EX1/EX2`)
	- write corrected PC (`immediate target` on wrong-not-taken, `next_pc` on wrong-taken)

### 5) Memory

- Accesses unified data/instruction memory interface.
- Uses SP unit to compute push/pop addresses and SP update direction.
- Handles memory path for stack-based PC/flags save-restore and interrupt vector access.

### 6) Write-Back

- Writes register data.
- Writes flags when enabled.
- Writes PC when enabled by delayed control path.

## Pipeline registers

- `IF_ID`
- `ID_EX1`
- `EX1_EX2`
- `EX2_MEM`
- `MEM_WB`

## Pipeline register payload contract

Naming convention:
- Control signals: `ALL_CAPS`
- Data signals: `lowercase`

### IF_ID

- Data: `instr[31:0]`, `next_pc[31:0]`, `branch_prediction`

### ID_EX1

- Control: `LOAD_FLAGS`, `PC_WRITE_EN`, `MEM_WRITE_SEL[1:0]`, `COND_BRANCH`, `HLT`, `SWAP_2ND_CYCLE`, `MEMW`, `MEMR`, `UPDATE_FLAGS`, `MEM_ADDRESS_SEL[1:0]`, `OUTPUT_PORT_EN`, `REG_WB_EN`, `ALU_INPUT_SEL[2:0]`, `JMP_FLAG_SEL[1:0]`
- Data: `branch_prediction`, `read_data_1[31:0]`, `read_data_2[31:0]`, `imm_offset[15:0]`, `reg_write_address[2:0]`, `next_pc[31:0]`, `read_reg_1[2:0]`, `read_reg_2[2:0]`

### EX1_EX2

- Control: `LOAD_FLAGS`, `PC_WRITE_EN`, `MEM_WRITE_SEL[1:0]`, `COND_BRANCH`, `HLT`, `MEMW`, `MEMR`, `UPDATE_FLAGS`, `MEM_ADDRESS_SEL[1:0]`, `OUTPUT_PORT_EN`, `REG_WB_EN`, `JMP_FLAG_SEL[1:0]`
- Data: `corrected_ccr_flags[2:0]`, `branch_prediction`, `alu_flags[2:0]`, `alu_result[31:0]`, `base_reg_data[31:0]`, `imm_offset[15:0]`, `reg_write_address[2:0]`, `next_pc[31:0]`

### EX2_MEM

- Control: `LOAD_FLAGS`, `PC_WRITE_EN`, `MEM_WRITE_SEL[1:0]`, `MEMW`, `MEMR`, `UPDATE_FLAGS`, `MEM_ADDRESS_SEL[1:0]`, `OUTPUT_PORT_EN`, `REG_WB_EN`
- Data: `corrected_ccr_flags[2:0]`, `alu_flags[2:0]`, `alu_result[31:0]`, `mem_adr[31:0]`, `interrupt_adr[1:0]`, `reg_write_address[2:0]`, `next_pc[31:0]`

### MEM_WB

- Control: `UPDATE_FLAGS`, `OUTPUT_PORT_EN`, `REG_WB_EN`
- Data: `flag_wb[2:0]`, `wb_data[31:0]`, `reg_write_address[2:0]`

## Stage contracts

- ALU class (`NOT`, `INC`, `MOV`, `SWAP`, `ADD`, `SUB`, `AND`, `IADD`) resolves result in Execute-1.
- Branch condition class (`JZ`, `JN`, `JC`) resolves in Execute-2.
- Memory class (`PUSH`, `POP`, `LDM`, `LDD`, `STD`, call/interrupt stack effects) resolves memory action in Memory stage.
- PC-load class (returns/interrupt entry completion) has exclusive control path and can force global stall/flush.

## Clocking policy

- Single-edge synchronous policy for all pipeline registers.
- Register file write in WB, read in Decode.
- Memory port arbitration handled by hazard/structural control; fetch is stalled when data memory has priority.
