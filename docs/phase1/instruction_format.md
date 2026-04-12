# Instruction Format (Phase 1)

## Target

Define final bit layout for all instruction classes.

## Common fields

- Instruction word size: `32 bits`
- Bit numbering: `[31:0]` (`[31]` is MSB)
- Unified memory address space: `4 KB x 32-bit` (`4096` words, address width = `12 bits`)
- `Opcode` (5 bits)
- `Rdst` (3 bits)
- `Rsrc1` (3 bits)
- `Rsrc2` (3 bits)
- `Imm/Offset` (up to 16 bits, encoded in the same 32-bit instruction word)

## Format proposals

### F0: No-operand

- Bits: `[31:27]=Opcode`, `[26:24]=000`, `[23:21]=000`, `[20:0]=0`
- Used by: `NOP`, `HLT`, `SETC`, `RET`, `RTI`

### F1: One-operand

- **F1-MirroredReg**
- Bits: `[31:27]=Opcode`, `[26:24]=Rop`, `[23:21]=Rop`, `[20:0]=0`
- Used by: `NOT`, `INC`, `IN`, `OUT`, `PUSH`, `POP`

### F2: Two/Three-operand

- **F2-2R**
- Bits: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:21]=Rsrc1`, `[20:0]=0`
- Used by: `MOV`, `SWAP`
- Note: assembler syntax for `MOV` is `MOV Rdst, Rsrc` (first operand is destination, second is source).
- **F2-3R**
- Bits: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:21]=Rsrc1`, `[20:18]=Rsrc2`, `[17:0]=0`
- Used by: `ADD`, `SUB`, `AND`

### F3: Immediate/Offset (1-word)

- All F3 instructions are encoded in a single 32-bit word:
- **F3-Addr12**: `[31:27]=Opcode`, `[26:12]=0`, `[11:0]=TargetAddr` (used by `JZ`, `JN`, `JC`, `JMP`, `CALL`)
- **F3-RdImm16**: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:16]=0`, `[15:0]=Imm16` (used by `LDM`)
- **F3-RdRsImm16**: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:21]=000`, `[20:18]=Rsrc1`, `[17:16]=00`, `[15:0]=Imm16` (used by `IADD`, `LDD`)
- **F3-StoreRsRsOff16**: `[31:27]=Opcode`, `[26:24]=000`, `[23:21]=Rsrc1`, `[20:18]=Rsrc2`, `[17:16]=00`, `[15:0]=Offset16` (used by `STD`)
- **F3-IntIdx**: `[31:27]=Opcode`, `[26:2]=0`, `[1:0]=index` (used by `INT`; assembler accepts only `0` or `1`)

## Decisions to freeze

- Register field positions are fixed exactly as specified above.
- Opcode width remains `5 bits`; opcode values stay as listed in the opcode table.
- One-operand rule: the operand register is mirrored into both `Rdst` (`[26:24]`) and `Rsrc1` (`[23:21]`).
- No-operand rule: `Rdst` and `Rsrc1` are both encoded as `000`.
- Data immediate/offset rule (`IADD`, `LDM`, `LDD`, `STD`): assembler stores 16 bits in `[15:0]` of the instruction word; negative values are encoded in 16-bit two's complement.
- Address-immediate rule (`JZ`, `JN`, `JC`, `JMP`, `CALL`): target address is constrained to memory range `0x000`..`0xFFF` and encoded in `[11:0]`; bits `[26:12]` are always zero.
- `INT` index encoding is fixed to instruction bits `[1:0]` (`00` for `INT 0`, `01` for `INT 1`; other values are rejected by assembler).
- `NOP` encoding is fixed to `00000` followed by 27 zeros (`32'b00000_000000000000000000000000000`).
