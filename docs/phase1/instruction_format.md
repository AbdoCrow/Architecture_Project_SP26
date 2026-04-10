# Instruction Format (Phase 1)

## Target

Define final bit layout for all instruction classes.

## Common fields

- `Opcode` (5 bits)
- `Rdst` (3 bits)
- `Rsrc1` (3 bits)
- `Rsrc2` (3 bits)
- `Imm/Offset` (16 bits, in next memory word when needed)

## Format proposals

### F0: No-operand

- Bits: `[31:27]=Opcode`
- Remaining bits: reserved

### F1: One-operand

- Bits: `[31:27]=Opcode`, register field assignment: TODO

### F2: Two/Three-operand

- Bits mapping: TODO

### F3: Immediate/Offset (2-word)

- Word 1: opcode + regs
- Word 2: immediate/offset 16-bit (extension policy: TODO)

## Decisions to freeze

- Register field positions
- Immediate sign/zero extension rule
- INT index encoding
- NOP encoding
