# Instruction Format (Phase 1)

## Target

Define final bit layout for all ISA-visible instruction classes and clarify internal micro-op policy.

## Common fields

- Instruction word size: `32 bits`
- Bit numbering: `[31:0]` (`[31]` is MSB)
- Unified memory address space: `4 KB x 32-bit` (`4096` words, address width = `12 bits`)
- `opcode` (5 bits)
- `rdst` (3 bits)
- `rsrc1` (3 bits)
- `rsrc2` (3 bits)
- `imm/offset` (up to 16 bits, encoded in the same 32-bit instruction word)

## Final formats

### F0: No-operand

- Bits: `[31:27]=opcode`, `[26:24]=000`, `[23:21]=000`, `[20:0]=0`
- Used by: `NOP`, `HLT`, `SETC`, `RET`, `RTI`

### F1: One-operand

- **F1-MirroredReg**
- Bits: `[31:27]=opcode`, `[26:24]=rop`, `[23:21]=rop`, `[20:0]=0`
- Used by: `NOT`, `INC`, `IN`, `OUT`, `PUSH`, `POP`

### F2: Two/Three-operand

- **F2-2R**
- Bits: `[31:27]=opcode`, `[26:24]=rdst`, `[23:21]=rsrc1`, `[20:0]=0`
- Used by: `MOV`, `SWAP`
- Note: assembler syntax for `MOV` is `MOV Rdst, Rsrc` (first operand is destination, second is source).
- Note: `SWAP` cycle 1 is encoded exactly like a normal 2-register move. Decode then injects internal `SWAP2` on cycle 2.
- **F2-3R**
- Bits: `[31:27]=opcode`, `[26:24]=rdst`, `[23:21]=rsrc1`, `[20:18]=rsrc2`, `[17:0]=0`
- Used by: `ADD`, `SUB`, `AND`

### F3: Immediate/Offset (1-word)

- All F3 instructions are encoded in a single 32-bit word:
- **F3-Addr12-EarlyDecode**:
	- Layout: `[31:27]=opcode`, `[26:18]=0`, `[17]=cond_branch_hint`, `[16]=uncond_branch_hint`, `[15:12]=0`, `[11:0]=target_addr`
	- Used by: `JZ`, `JN`, `JC`, `JMP`, `CALL`
	- Policy:
		- `JZ`, `JN`, `JC`: `cond_branch_hint=1`, `uncond_branch_hint=0`
		- `JMP`, `CALL`: `cond_branch_hint=0`, `uncond_branch_hint=1`
- **F3-RdImm16**: `[31:27]=opcode`, `[26:24]=rdst`, `[23:16]=0`, `[15:0]=imm16` (used by `LDM`)
- **F3-RdRsImm16**: `[31:27]=opcode`, `[26:24]=rdst`, `[23:21]=000`, `[20:18]=rsrc1`, `[17:16]=00`, `[15:0]=imm16` (used by `IADD`, `LDD`)
- **F3-StoreRsRsOff16**: `[31:27]=opcode`, `[26:24]=000`, `[23:21]=rsrc1`, `[20:18]=rsrc2`, `[17:16]=00`, `[15:0]=offset16` (used by `STD`)
- **F3-IntIdx**: `[31:27]=opcode`, `[26:2]=0`, `[1:0]=index` (used by `INT`; assembler accepts only `0` or `1` and encodes `INT 0 -> 10`, `INT 1 -> 11`; `01` is reserved for hardware interrupt entry)

## Internal micro-operations (decode injected)

- `SWAP2` (`opcode=00111`): emitted by multicycle control after `SWAP` to perform reverse move and assert `SWAP_2ND_CYCLE`.
- `INT2` (`opcode=01110`): emitted after `INT` to push flags.
- `INT3` (`opcode=01111`): emitted after `INT2` to load interrupt vector address into PC.
- These are not legal assembly mnemonics and have no external encoding contract.

## Decisions to freeze

- Register field positions are fixed exactly as specified above.
- Opcode width remains `5 bits`; opcode values stay as listed in the opcode table.
- One-operand rule: the operand register is mirrored into both `Rdst` (`[26:24]`) and `Rsrc1` (`[23:21]`).
- No-operand rule: `Rdst` and `Rsrc1` are both encoded as `000`.
- Data immediate/offset rule (`IADD`, `LDM`, `LDD`, `STD`): assembler stores 16 bits in `[15:0]` of the instruction word; negative values are encoded in 16-bit two's complement.
- Address-immediate rule (`JZ`, `JN`, `JC`, `JMP`, `CALL`): target address is constrained to memory range `0x000`..`0xFFF` and encoded in `[11:0]`.
- Early decode rule for fetch prediction:
	- `instr[16]=1` for immediate unconditional branch (`JMP`, `CALL`)
	- `instr[17]=1` only for `JZ`, `JN`, `JC`
	- `RET` is not flagged by these bits
- `INT` index encoding is fixed to instruction bits `[1:0]` (`10` for `INT 0`, `11` for `INT 1`).
- Hardware interrupt entry uses interrupt index marker `01` (internal control-path encoding, not assembler input).
- Remaining index value `10` is reserved.
- `NOP` encoding is fixed to `00000` followed by 27 zeros (`32'b00000_000000000000000000000000000`).