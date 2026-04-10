# Architecture Project SP26 Skeleton

Team-ready starter structure for your 6-stage pipelined Von-Neumann processor.

## Scope of this skeleton

- Folder structure aligned with SP26 handout
- Module/entity interface stubs only
- No logic implementation
- Phase-1/Phase-2 documentation templates
- Assembler, testcase, and `.do` script placeholders

## Pipeline stages

1. Fetch
2. Decode
3. Execute-1
4. Execute-2
5. Memory
6. Write-Back

## Spec assumptions baked into this skeleton

- Unified memory (program + data)
- 32-bit datapath
- 8 GPRs (`R0`-`R7`)
- `PC`, `SP`, `CCR`
- Non-maskable interrupt + reset flow hooks
- Static branch prediction hooks (not implemented)

## Team workflow suggestion

1. Fill `docs/phase1/` first (ISA bits, opcodes, stage/control contracts).
2. Freeze control bundle bitfields in control unit and pipeline regs.
3. Implement modules stage-by-stage with unit testbenches.
4. Integrate top-level and run full waveform scripts.
5. Track any phase-1 design changes in `docs/phase2/design_changes.md`.

## Report planning

- Use `docs/phase1/report_execution_plan.md` for task division and report-writing flow.
