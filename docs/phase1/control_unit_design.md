# Control Unit Design (Phase 1)

## Inputs

- `opcode[4:0]`
- pipeline state and hazard feedback
- interrupt state (software and hardware interrupt requests)
- multicycle sequencing state

## Outputs

- stage control bundle (Decode -> pipeline)
- multicycle follow-up selection
- stall/flush handshake outputs for fetch/hazard path
- PC/SP/flags control enables

## Signal naming convention

- Control signals: `ALL_CAPS`
- Data signals: `lowercase`

## Primary control signals

### Control signals

- `LOAD_FLAGS`: write flags from memory path
- `PC_WRITE_EN`: write PC from memory/control path
- `MEM_WRITE_SEL[1:0]`: memory write source select
- `COND_BRANCH`: instruction is conditional branch
- `HLT`: halt execution/fetch progress
- `MEMW`: memory write enable
- `MEMR`: memory read enable
- `REG_WB_EN`: register writeback enable
- `UPDATE_FLAGS`: write ALU-generated flags
- `ALU_OP`: ALU operation code
- `JMP_FLAG_SEL[1:0]`: branch condition selector (Z/N/C)
- `OUTPUT_PORT_EN`: output port write enable
- `MEM_ADDRESS_SEL[1:0]`: memory address source select
- `SWAP_2ND_CYCLE`: disable EX1->EX1 forwarding in swap second cycle
- `MULTICYCLE_STALL`: stall fetch and PC while decode injects internal cycle
- `MULTICYCLE_SEL[2:0]`: select injected internal operation (`SWAP2`, `RET_STEP`, `INT2`, `INT3`, ...)

### Data signals (examples crossing decode/control boundary)

- `read_data_1`, `read_data_2`
- `imm_offset`
- `reg_write_address`
- `next_pc`
- `interrupt_adr`

## Control-field encodings

- `MEM_WRITE_SEL`:
	- `00`: write `alu_result`
	- `01`: write `next_pc` (stack push PC)
	- `10`: write extended flags
	- `11`: reserved
- `MEM_ADDRESS_SEL`:
	- `00`: computed address (`alu_result`)
	- `01`: interrupt vector address source
	- `10`: stack push address path (`SP--` behavior)
	- `11`: stack pop address path (`SP++` behavior)
- `MULTICYCLE_SEL`:
	- `000`: none
	- `001`: `SWAP2`
	- `010`: `RET_STEP`
	- `011`: `INT2`
	- `100`: `INT3`
	- other values reserved

## Required sequencing notes

- `SWAP`:
	- cycle 1 executes move `rdst <- rsrc1`
	- decode emits internal `SWAP2` on next cycle (`MULTICYCLE_STALL=1`, `MULTICYCLE_SEL=SWAP2`)
	- `SWAP2` performs reverse move and asserts `SWAP_2ND_CYCLE=1`
- `INT` sequence:
	- `INT`: push PC
	- `INT2` (internal): push flags
	- `INT3` (internal): load interrupt vector PC
	- interrupt index encoding convention `[1:0]`: `10` for software `INT 0`, `11` for software `INT 1`, `01` for hardware interrupt entry
- `CALL`: push PC then transfer control to immediate target (`instr[16]=1` early branch hint)
- `RET/RTI`: stack-driven control-flow return; treated as control-critical sequence with stall/flush as needed
- Hardware interrupt:
	- can enter only when branch window resolved and no decode multicycle stall active
	- held pending otherwise

## Control tables

### ALU / register class (ISA-visible)

| Instr | ALU_OP | REG_WB_EN | UPDATE_FLAGS | MEMR | MEMW | OUTPUT_PORT_EN | Notes |
| ----- | ------ | --------- | ------------ | ---- | ---- | -------------- | ----- |
| NOP | NOP | 0 | 0 | 0 | 0 | 0 | all controls deasserted |
| HLT | NOP | 0 | 0 | 0 | 0 | 0 | assert `HLT=1` |
| SETC | SETC | 0 | 1 | 0 | 0 | 0 | set carry |
| NOT | NOT_A | 1 | 1 | 0 | 0 | 0 | unary op on `read_data_1` |
| INC | INC_A | 1 | 1 | 0 | 0 | 0 | unary increment |
| IN | PASS_B | 1 | 0 | 0 | 0 | 0 | input-port selected by `ALU_INPUT_SEL` |
| OUT | PASS_A | 0 | 0 | 0 | 0 | 1 | write output port |
| MOV | PASS_A | 1 | 0 | 0 | 0 | 0 | `rdst <- rsrc1` |
| SWAP | PASS_A | 1 | 0 | 0 | 0 | 0 | also assert `MULTICYCLE_STALL` and schedule `SWAP2` |
| ADD | ADD | 1 | 1 | 0 | 0 | 0 | 3-register add |
| SUB | SUB | 1 | 1 | 0 | 0 | 0 | 3-register sub |
| AND | AND | 1 | 1 | 0 | 0 | 0 | 3-register and |
| IADD | ADD | 1 | 1 | 0 | 0 | 0 | immediate selected |

### Memory / stack / branch class (ISA-visible)

| Instr | ALU_OP | REG_WB_EN | UPDATE_FLAGS | MEMR | MEMW | MEM_ADDRESS_SEL | MEM_WRITE_SEL | COND_BRANCH | PC_WRITE_EN | Notes |
| ----- | ------ | --------- | ------------ | ---- | ---- | --------------- | ------------- | ----------- | ----------- | ----- |
| PUSH | PASS_A | 0 | 0 | 0 | 1 | 10 | 00 | 0 | 0 | push register data |
| POP | PASS_A | 1 | 0 | 1 | 0 | 11 | 00 | 0 | 0 | pop to register |
| LDM | PASS_B | 1 | 0 | 0 | 0 | 00 | 00 | 0 | 0 | immediate to register |
| LDD | ADD | 1 | 0 | 1 | 0 | 00 | 00 | 0 | 0 | load from computed address |
| STD | PASS_A | 0 | 0 | 0 | 1 | 00 | 00 | 0 | 0 | store to computed address |
| JZ/JN/JC | PASS_A | 0 | 0 | 0 | 0 | 00 | 00 | 1 | 0 | branch condition checked in EX2 |
| JMP | PASS_A | 0 | 0 | 0 | 0 | 00 | 00 | 0 | 0 | immediate unconditional transfer (fetch early decode via `instr[16]`) |
| CALL | PASS_A | 0 | 0 | 0 | 1 | 10 | 01 | 0 | 0 | push PC; immediate target is treated as early unconditional branch |
| RET | PASS_A | 0 | 0 | 1 | 0 | 11 | 00 | 0 | 1 | pop PC from stack; stall/flush around PC write |
| RTI | PASS_A | 0 | 1 | 1 | 0 | 11 | 00 | 0 | 1 | restore flags and PC through sequence |
| INT | PASS_A | 0 | 0 | 0 | 1 | 10 | 01 | 0 | 0 | push PC, then schedule `INT2` |

### Internal micro-operations (not assembler-visible)

| Internal op | REG_WB_EN | UPDATE_FLAGS | MEMR | MEMW | MEM_ADDRESS_SEL | MEM_WRITE_SEL | PC_WRITE_EN | SWAP_2ND_CYCLE | Notes |
| ----------- | --------- | ------------ | ---- | ---- | --------------- | ------------- | ----------- | -------------- | ----- |
| SWAP2 | 1 | 0 | 0 | 0 | 00 | 00 | 0 | 1 | reverse move cycle |
| INT2 | 0 | 0 | 0 | 1 | 10 | 10 | 0 | 0 | push flags |
| INT3 | 0 | 0 | 0 | 0 | 01 | 00 | 1 | 0 | load interrupt vector into PC |

## Integration notes

- Any in-flight instruction with `PC_WRITE_EN=1` has highest control priority:
	- stall younger instructions while pending
	- flush younger instructions when PC write commits
- `MULTICYCLE_STALL=1` must stall fetch and PC but keep decode active to emit the selected internal operation.
- Branch misprediction recovery (from EX2) flushes 3 instructions and overrides PC with corrected value.
- `ALU_OP` stays generic; SWAP/INT sequencing does not require dedicated ALU opcodes.
