# Phase 1 Report Execution Plan (Task Division + How To Write)

## 1) Team task division (4 members)

## Member A - ISA and Encoding Owner

- Owns instruction format definition.
- Owns opcode table and instruction bit details.
- Owns assembler-side encoding consistency check.
- Writes these sections:
  - Instruction format of your design
  - Opcode of each instruction
  - Instruction bits details

### Deliverables

- Final bitfield diagrams for F0/F1/F2/F3 formats.
- Complete opcode table with no TODO entries.
- 3-5 worked encoding examples (binary fields broken down).

## Member B - Datapath and Block-Level Architecture Owner

- Owns schematic and datapath block-level architecture.
- Owns ALU/Register/Memory block specs and sizes.
- Writes these sections:
  - Schematic diagram with dataflow details
  - ALU / Registers / Memory Blocks
  - Dataflow interconnections between blocks & sizes

### Deliverables

- Clean digital schematic (draw.io, Visio, Figma, or diagrams.net).
- Block spec table: each block, inputs/outputs, bit widths, clock/reset behavior.
- Main buses table: name, source, destination, width.

## Member C - Control and Pipeline Owner

- Owns control-unit detailed design.
- Owns 6-stage partitioning and pipeline-register contracts.
- Writes these sections:
  - Control Unit detailed design
  - Pipeline stages design
  - Pipeline registers details (size, input, connection)

### Deliverables

- Control truth table per opcode (or per instruction class + exceptions).
- Stage responsibilities for Fetch/Decode/EX1/EX2/MEM/WB.
- Pipeline register payload maps: IF_ID, ID_EX1, EX1_EX2, EX2_MEM, MEM_WB.

## Member D - Hazards and Verification Strategy Owner

- Owns hazard policy and branch prediction policy write-up.
- Owns verification plan for those hazards.
- Writes these sections:
  - Pipeline hazards and your solution
  - Data forwarding
  - Static branch prediction

### Deliverables

- Hazard matrix (Data/Structural/Control) with detection + action.
- Forwarding matrix (from which stage to which operand).
- Static prediction policy and misprediction recovery sequence.

## Editor/Integrator role (rotate or assign one member)

- Merges all sections, standardizes notation/naming, checks consistency.
- Final quality gate before submission.

---

## 2) How to write each report requirement (exactly what to include)

## Instruction format of your design

Include:

- 32-bit word layout for each instruction class.
- Which instructions consume a second word.
- Where `Rdst`, `Rsrc1`, `Rsrc2`, `Imm/Offset`, `Index` are encoded.

Avoid:

- Mixing multiple alternative layouts in final report.

## Opcode of each instruction

Include:

- Single table with all mnemonics and final binary opcode.
- Mark special micro-sequenced instructions (`SWAP`, `INT`, `RTI`, `CALL`, `RET`).

## Instruction bits details

Include:

- Bit slices like `[31:27]=opcode`, etc.
- 3-5 fully worked examples: instruction -> binary words.

## Schematic diagram with dataflow details

Include:

- One top-level 6-stage pipeline diagram.
- Control paths and data paths in different colors.
- Hazard and forwarding units explicitly shown.

## ALU / Registers / Memory Blocks

Include:

- Per-block mini-spec:
  - Purpose
  - Inputs/outputs and widths
  - Clock edge usage
  - Reset behavior

## Dataflow interconnections and sizes

Include:

- Bus table with widths.
- Critical signals: PC path, immediate path, forwarding path, memory address/data, stack path.

## Control Unit detailed design

Include:

- Inputs, outputs, and control bundle definitions.
- Instruction-class control mapping.
- Sequencing notes for interrupt/return/branch corner cases.

## Pipeline stages design

Include:

- For each stage: responsibilities and consumed/produced signals.
- Where each instruction type is resolved.

## Pipeline registers details

Include:

- Register name
- Payload fields (control + data)
- Total width
- Flush/stall behavior

## Hazards + solutions

Include:

- Data hazards: forwarding paths and load-use handling.
- Structural hazards: one-memory arbitration policy.
- Control hazards: branch resolution stage, flush count.
- Static branch prediction: policy and correction behavior.

---

## 3) Suggested section order in final report

1. ISA overview
2. Instruction format and opcode table
3. Datapath architecture and block specs
4. 6-stage pipeline partitioning
5. Control unit design
6. Pipeline register design
7. Hazard handling and static branch prediction
8. Design tradeoffs and assumptions

---

## 4) Quality checklist before submission

- [ ] No TODO text remains in phase1 docs.
- [ ] Same signal names are used across all sections.
- [ ] Opcode table matches instruction examples.
- [ ] Pipeline stage count is 6 everywhere.
- [ ] Memory size is consistently 4KB x 32-bit.
- [ ] SP initial value is consistently documented as `(2^12 - 1)`.
- [ ] Interrupt/reset behavior matches handout wording.
- [ ] Hazard actions (stall/flush/forward) are fully specified.

---

## 5) Fast execution timeline (5 working days)

- Day 1: Freeze ISA format + opcode table (Member A)
- Day 2: Finish schematic + block specs + buses (Member B)
- Day 3: Finish control and pipeline-register maps (Member C)
- Day 4: Finish hazards + prediction + verification notes (Member D)
- Day 5: Integrate, review, consistency pass, export PDF

---

## 6) Mapping to existing files in this repo

- ISA and encoding:
  - `docs/phase1/instruction_format.md`
  - `docs/phase1/opcode_table.md`
- Pipeline and control:
  - `docs/phase1/pipeline_design.md`
  - `docs/phase1/control_unit_design.md`
- Hazards and prediction:
  - `docs/phase1/hazards_and_prediction.md`
