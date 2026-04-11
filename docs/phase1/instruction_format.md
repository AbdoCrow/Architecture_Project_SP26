# Instruction Format (Phase 1)

## Target

Define final bit layout for all instruction classes.

## Common fields

- Instruction word size: `32 bits`
- Bit numbering: `[31:0]` (`[31]` is MSB)
- `Opcode` (5 bits)
- `Rdst` (3 bits)
- `Rsrc1` (3 bits)
- `Rsrc2` (3 bits)
- `Imm/Offset` (16 bits, in next memory word when needed)

## Format proposals

### F0: No-operand

- Bits: `[31:27]=Opcode`
- Remaining bits: `[26:0]=0`
- Used by: `NOP`, `HLT`, `SETC`, `RET`, `RTI`

### F1: One-operand

- **F1-D (destination-style)**
- Bits: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:0]=0`
- Used by: `NOT`, `INC`, `IN`, `POP`
- **F1-S (source-style)**
- Bits: `[31:27]=Opcode`, `[26:24]=000`, `[23:21]=Rsrc1`, `[20:18]=000`, `[17:0]=0`
- Used by: `OUT`, `PUSH`

### F2: Two/Three-operand

- **F2-2R**
- Bits: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:21]=Rsrc1`, `[20:0]=0`
- Used by: `MOV`, `SWAP`
- Note: assembler syntax for `MOV` is `MOV Rdst, Rsrc` (first operand is destination, second is source).
- **F2-3R**
- Bits: `[31:27]=Opcode`, `[26:24]=Rdst`, `[23:21]=Rsrc1`, `[20:18]=Rsrc2`, `[17:0]=0`
- Used by: `ADD`, `SUB`, `AND`

### F3: Immediate/Offset (2-word)

- Word 1 always starts with `[31:27]=Opcode`, with one of the following layouts:
- **F3-ImmOnly**: `[26:0]=0` (used by `JZ`, `JN`, `JC`, `JMP`, `CALL`, `INT` word 1)
- **F3-RdOnly**: `[26:24]=Rdst`, `[23:0]=0` (used by `LDM`)
- **F3-RdRs**: `[26:24]=Rdst`, `[23:21]=000`, `[20:18]=Rsrc1`, `[17:0]=0` (used by `IADD`, `LDD`)
- **F3-StoreRsRs**: `[26:24]=000`, `[23:21]=Rsrc1`, `[20:18]=Rsrc2`, `[17:0]=0` (used by `STD`)
- Word 2 encoding:
- Normal immediate/offset form: `[31:16]=0`, `[15:0]=Imm/Offset(16-bit)`
- `INT` form: `[31:2]=0`, `[1:0]=index` (assembler accepts only `0` or `1`)

## Decisions to freeze

- Register field positions are fixed exactly as specified above.
- Immediate/offset rule: assembler stores only 16 bits in `[15:0]`; negative values are encoded in 16-bit two's complement. Upper half of word 2 is always zero (`[31:16]=0`).
- `INT` index encoding is fixed to word 2 bits `[1:0]` (`00` for `INT 0`, `01` for `INT 1`; other values are rejected by assembler).
- `NOP` encoding is fixed to `00000` followed by 27 zeros (`32'b00000_000000000000000000000000000`).
