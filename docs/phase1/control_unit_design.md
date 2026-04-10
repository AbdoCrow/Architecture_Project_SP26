# Control Unit Design (Phase 1)

## Inputs

- `opcode`
- current pipeline state / interrupt state

## Outputs

- Stage control bundles
- pipeline stall/flush controls
- PC/SP/CCR controls

## Required sequencing notes

- SWAP handling
- CALL/RET
- INT/RTI
- External interrupt entry and return behavior

## Control tables

- Fill per-instruction control values here.
