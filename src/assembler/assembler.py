#!/usr/bin/env python3
import re
import sys
from typing import Dict, List, Tuple, Optional

# Number of words reserved at the bottom of memory for the vector table.
# Matches the 4-entry layout: reset, INT0, INT1, HW-INT.
VECTOR_TABLE_SIZE = 4

class RISCAssembler:
    def __init__(self):
        # Instruction opcodes (5 bits)
        self.opcodes = {
            # Type 1 - One Operand
            'NOP':  '00000',
            'HLT':  '00001',
            'SETC': '00010',
            'NOT':  '00011',
            'INC':  '00100',
            'OUT':  '00101',
            'IN':   '00110',

            # Type 2 - Two Operands
            'MOV':  '01000',
            'SWAP': '01001',
            'ADD':  '01010',
            'SUB':  '01011',
            'AND':  '01100',
            'IADD': '01101',

            # Type 3 - Memory Operations
            'PUSH': '10000',
            'POP':  '10001',
            'LDM':  '10010',
            'LDD':  '10011',
            'STD':  '10100',

            # Type 4 - Branch and Control
            'JZ':   '11000',
            'JN':   '11001',
            'JC':   '11010',
            'JMP':  '11011',
            'CALL': '11100',
            'RET':  '11101',
            'INT':  '11110',
            'RTI':  '11111',
        }

        # Register mapping (3 bits)
        self.registers = {
            'R0': '000', 'R1': '001', 'R2': '010', 'R3': '011',
            'R4': '100', 'R5': '101', 'R6': '110', 'R7': '111',
        }

        # Instruction classification
        self.type1_no_op       = ['NOP', 'HLT', 'SETC', 'RET', 'RTI']
        self.type1_one_op      = ['NOT', 'INC']
        self.type2_three_op    = ['ADD', 'SUB', 'AND']
        self.type2_imm         = ['IADD']
        self.type3_imm         = ['LDM']
        self.type4_imm         = ['JZ', 'JN', 'JC', 'JMP', 'CALL']
        self.type4_index       = ['INT']
        self.cond_branch_mnemonics   = {'JZ', 'JN', 'JC'}
        self.uncond_branch_mnemonics = {'JMP', 'CALL'}

        # Unified memory: 4 KB × 32-bit words.
        self.memory_size   = 2 ** 12
        self.address_bits  = 12
        self.max_address   = self.memory_size - 1

        self.labels: Dict[str, int] = {}
        self.current_address = VECTOR_TABLE_SIZE   # code always starts at 0x004

        # Vector table entries — filled in by .INT_VECTOR / implicit reset vector.
        # Index: 0=reset, 1=HW-INT, 2=INT0, 3=INT1
        self._vectors: Dict[int, Optional[int]] = {0: None, 1: None, 2: None, 3: None}

        # Address of the very first instruction word assembled (for the reset vector).
        self._first_instruction_address: Optional[int] = None

    # ------------------------------------------------------------------
    # Parsing helpers
    # ------------------------------------------------------------------

    def clean_line(self, line: str) -> str:
        """Remove comments and extra whitespace."""
        for comment_char in ['#', ';']:
            if comment_char in line:
                line = line[:line.index(comment_char)]
        return line.strip()

    def parse_register(self, reg: str) -> str:
        """Parse register name to 3-bit binary."""
        reg = reg.strip().upper().replace(',', '')
        if reg not in self.registers:
            raise ValueError(f"Invalid register: {reg}")
        return self.registers[reg]

    def parse_numeric_value(self, value_str: str) -> int:
        """Parse numeric token supporting binary, hex, and decimal.
        Defaults to hexadecimal.
        """
        value_str = value_str.strip().replace(',', '')
        if value_str.upper().startswith('0X'):
            return int(value_str, 16)
        if value_str.upper().startswith('0B'):
            return int(value_str, 2)
        # Default to hexadecimal; fallback to decimal.
        try:
            return int(value_str, 16)
        except ValueError:
            return int(value_str, 10)

    def parse_address_immediate(self, addr: str, allow_labels: bool = False) -> str:
        """Parse an absolute address immediate constrained to 4 KB memory space."""
        addr = addr.strip().replace(',', '')
        if allow_labels and addr in self.labels:
            value = self.labels[addr]
        else:
            value = self.parse_numeric_value(addr)
        if value < 0 or value > self.max_address:
            raise ValueError(
                f"Address out of range for 4KB memory: {addr} "
                f"(valid: 0x000..0x{self.max_address:03X})"
            )
        return format(value, f'0{self.address_bits}b')

    def parse_immediate(self, imm: str, bits: int = 16, allow_labels: bool = False) -> str:
        """Parse immediate value to *bits*-wide binary.
        Defaults to hexadecimal interpretation.
        """
        imm = imm.strip().replace(',', '')
        if allow_labels and imm in self.labels:
            value = self.labels[imm]
        else:
            value = self.parse_numeric_value(imm)
        if value < 0:
            value = (1 << bits) + value
        return format(value & ((1 << bits) - 1), f'0{bits}b')

    def parse_data_value(self, value_str: str) -> int:
        """Parse a 32-bit data value (hex default)."""
        return self.parse_numeric_value(value_str)

    def parse_offset_register(self, operand: str) -> Tuple[str, str]:
        """Parse offset(register) format -> (offset_bits, reg_bits)."""
        match = re.match(r'(.+)\((.+)\)', operand.strip())
        if not match:
            raise ValueError(f"Invalid offset(register) format: {operand}")
        offset_str = match.group(1).strip()
        reg_str    = match.group(2).strip()
        offset = self.parse_immediate(offset_str, 16)
        reg    = self.parse_register(reg_str)
        
        return offset, reg

    def encode_branch_hint_bits(self, mnemonic: str) -> str:
        """Encode instr[17] (conditional) and instr[16] (unconditional) hints.

        Layout for bits [26:12] in F3 branch/call format:
        [26:18]=0, [17]=COND_BRANCH_HINT, [16]=UNCOND_BRANCH_HINT, [15:12]=0
        """
        cond   = '1' if mnemonic in self.cond_branch_mnemonics   else '0'
        uncond = '1' if mnemonic in self.uncond_branch_mnemonics else '0'
        return '0' * 9 + cond + uncond + '0' * 4

    # ------------------------------------------------------------------
    # Directive handling
    # ------------------------------------------------------------------

    def _handle_int_vector_directive(self, parts: List[str], line_num: int) -> bool:
        """Handle .INT_VECTOR <index> <label_or_address>.

        Sets _vectors[index+2] (index 0 = INT0 slot = vector table entry 2,
        index 1 = INT1 slot = entry 3).
        Returns True if line was consumed, False otherwise.
        """
        if parts[0].upper() != '.INT_VECTOR':
            return False
        if len(parts) < 3:
            raise ValueError(f"Line {line_num}: .INT_VECTOR requires an index and a target")
        try:
            idx = int(parts[1])
        except ValueError:
            raise ValueError(f"Line {line_num}: .INT_VECTOR index must be 0 or 1")
        if idx not in (0, 1):
            raise ValueError(f"Line {line_num}: .INT_VECTOR index must be 0 or 1, got {idx}")
        target_str = parts[2].strip().replace(',', '')
        # Store as string; resolve to address during second pass label lookup.
        # We keep it raw here and resolve it after first pass.
        self._vector_directives[idx] = (target_str, line_num)
        return True

    # ------------------------------------------------------------------
    # First pass
    # ------------------------------------------------------------------

    def first_pass(self, lines: List[str]) -> List[Tuple[int, str, int, bool]]:
        """Collect labels and calculate addresses.

        All user instructions are placed starting at VECTOR_TABLE_SIZE (0x004),
        unless an explicit .ORG moves the address (must be >= VECTOR_TABLE_SIZE).

        Returns a list of (address, line, line_num, is_data_value).
        """
        processed_lines = []
        # Reset state for a fresh assembly run.
        self.current_address = VECTOR_TABLE_SIZE
        self._first_instruction_address = None
        self._vectors = {0: None, 1: None, 2: None, 3: None}
        self._vector_directives: Dict[int, Tuple[str, int]] = {}

        expect_data_value = False

        for line_num, line in enumerate(lines, 1):
            original_line = line
            line = self.clean_line(line)
            if not line:
                continue

            # ---- .ORG directive ------------------------------------------
            if line.upper().startswith('.ORG'):
                parts = line.split()
                if len(parts) != 2:
                    raise ValueError(f"Line {line_num}: Invalid .ORG directive: {original_line}")
                new_addr = self.parse_numeric_value(parts[1])
                if new_addr > self.max_address:
                    raise ValueError(
                        f"Line {line_num}: .ORG address out of 4KB range: {parts[1]} "
                        f"(valid: 0x{VECTOR_TABLE_SIZE:03X}..0x{self.max_address:03X})"
                    )
                self.current_address = new_addr
                expect_data_value = True
                continue

            # ---- .INT_VECTOR directive ------------------------------------
            parts_raw = line.split()
            if parts_raw and parts_raw[0].upper() == '.INT_VECTOR':
                self._handle_int_vector_directive(parts_raw, line_num)
                continue

            # ---- Label definitions ----------------------------------------
            if ':' in line:
                label_part, instruction_part = line.split(':', 1)
                label = label_part.strip()
                if label in self.labels:
                    raise ValueError(f"Line {line_num}: Duplicate label '{label}'")
                if self.current_address > self.max_address:
                    raise ValueError(
                        f"Line {line_num}: Label '{label}' resolved outside 4KB range "
                        f"at 0x{self.current_address:X}"
                    )
                self.labels[label] = self.current_address
                line = instruction_part.strip()
                if not line:
                    continue

            parts = line.split()
            if not parts:
                continue

            # ---- INT0 / INT1 shorthand ------------------------------------
            if parts[0].upper() == 'INT0':
                line  = 'INT 0'
                parts = ['INT', '0']
            elif parts[0].upper() == 'INT1':
                line  = 'INT 1'
                parts = ['INT', '1']

            # ---- Data values after .ORG -----------------------------------
            if expect_data_value:
                mnemonic_check = parts[0].upper()
                if mnemonic_check not in self.opcodes and mnemonic_check not in ['INT0', 'INT1']:
                    try:
                        self.parse_numeric_value(parts[0])
                        processed_lines.append((self.current_address, line, line_num, True))
                        self.current_address += 1
                        if self.current_address > self.memory_size:
                            raise ValueError(
                                f"Line {line_num}: Data placement exceeded memory limit "
                                f"(last valid address: 0x{self.max_address:03X})"
                            )
                        expect_data_value = False
                        continue
                    except ValueError:
                        pass
                expect_data_value = False

            # ---- Normal instruction ---------------------------------------
            mnemonic = parts[0].upper()
            if mnemonic not in self.opcodes:
                raise ValueError(f"Line {line_num}: Unknown instruction '{mnemonic}': {original_line}")

            if self.current_address > self.max_address:
                raise ValueError(
                    f"Line {line_num}: Instruction '{mnemonic}' at address "
                    f"0x{self.current_address:X} exceeds 4KB memory range"
                )

            # Track the very first instruction word for the reset vector.
            if self._first_instruction_address is None:
                self._first_instruction_address = self.current_address

            processed_lines.append((self.current_address, line, line_num, False))
            self.current_address += 1

        return processed_lines

    # ------------------------------------------------------------------
    # Instruction encoding
    # ------------------------------------------------------------------

    def assemble_instruction(self, line: str, line_num: int) -> List[str]:
        """Assemble a single instruction into one 32-bit word."""
        parts = re.split(r'[,\s]+', line.strip())
        parts = [p for p in parts if p]

        mnemonic = parts[0].upper()
        opcode   = self.opcodes[mnemonic]
        instructions = []

        try:
            if mnemonic in self.type1_no_op:
                instructions.append(opcode + '0' * 27)

            elif mnemonic in self.type1_one_op:
                if len(parts) < 2:
                    raise ValueError(f"{mnemonic} requires a register operand")
                rop = self.parse_register(parts[1])
                instructions.append(opcode + rop + rop + '0' * 21)
            elif mnemonic == 'IN':
                if len(parts) < 2:
                    raise ValueError(f"{mnemonic} requires a register operand")
                rdst = self.parse_register(parts[1])
                instructions.append(opcode + '000' + rdst + '0' * 21)
            elif mnemonic == 'OUT':
                if len(parts) < 2:
                    raise ValueError(f"{mnemonic} requires a register operand")
                rsrc = self.parse_register(parts[1])
                instructions.append(opcode + '000' + rsrc + '0' * 21)
            elif mnemonic == 'MOV':
                if len(parts) < 3:
                    raise ValueError("MOV requires 2 register operands")
                rd = self.parse_register(parts[1])
                rs = self.parse_register(parts[2])
                instructions.append(opcode + rd + rs + '0' * 21)

            elif mnemonic == 'SWAP':
                if len(parts) < 3:
                    raise ValueError("SWAP requires 2 register operands")
                rd  = self.parse_register(parts[1])
                rs1 = self.parse_register(parts[2])
                rs2 = rd
                instructions.append(opcode + rd + rs1 + rs2 + '0' * 18)

            elif mnemonic in self.type2_three_op:
                if len(parts) < 4:
                    raise ValueError(f"{mnemonic} requires 3 register operands")
                rd  = self.parse_register(parts[1])
                rs1 = self.parse_register(parts[2])
                rs2 = self.parse_register(parts[3])
                instructions.append(opcode + rd + rs1 + rs2 + '0' * 18)

            elif mnemonic in self.type2_imm:
                if len(parts) < 4:
                    raise ValueError(f"{mnemonic} requires Rd, Rs, Imm")
                rd  = self.parse_register(parts[1])
                rs  = self.parse_register(parts[2])
                imm = self.parse_immediate(parts[3], 16, allow_labels=True)
                instructions.append(opcode + rd + rs +'000' + '00' + imm)

            elif mnemonic == 'PUSH':
                if len(parts) < 2:
                    raise ValueError("PUSH requires a register operand")
                rsrc = self.parse_register(parts[1])
                instructions.append(opcode + '000' + rsrc + '0' * 21)

            elif mnemonic == 'POP':
                if len(parts) < 2:
                    raise ValueError("POP requires a register operand")
                rdst = self.parse_register(parts[1])
                instructions.append(opcode + rdst + '000' + '0' * 21)

            elif mnemonic in self.type3_imm:
                if len(parts) < 3:
                    raise ValueError(f"{mnemonic} requires Rd, Imm")
                rd  = self.parse_register(parts[1])
                imm = self.parse_immediate(parts[2], 16, allow_labels=True)
                instructions.append(opcode + rd + rd +'0' * 5 + imm)

            elif mnemonic == 'LDD':
                if len(parts) < 3:
                    raise ValueError("LDD requires Rd, offset(Rs)")
                rd          = self.parse_register(parts[1])
                offset_part = ''.join(parts[2:])
                offset, rs  = self.parse_offset_register(offset_part)
                instructions.append(opcode + rd + '000' + rs + '00' + offset)

            elif mnemonic == 'STD':
                if len(parts) < 3:
                    raise ValueError("STD requires Rs1, offset(Rs2)")
                rs1         = self.parse_register(parts[1])
                offset_part = ''.join(parts[2:])
                offset, rs2 = self.parse_offset_register(offset_part)
                instructions.append(opcode + '000' + rs1 + rs2 + '00' + offset)

            elif mnemonic in self.type4_imm:
                if len(parts) < 2:
                    raise ValueError(f"{mnemonic} requires an immediate address value")
                addr12            = self.parse_address_immediate(parts[1], allow_labels=True)
                branch_hint_bits  = self.encode_branch_hint_bits(mnemonic)
                instructions.append(opcode + branch_hint_bits + addr12)

            elif mnemonic in self.type4_index:
                if len(parts) < 2:
                    raise ValueError("INT requires an index (0 or 1)")
                index_val = parts[1].strip().replace(',', '')
                try:
                    index = int(index_val)
                except ValueError:
                    raise ValueError(f"INT index must be 0 or 1, got: {parts[1]}")
                if index not in [0, 1]:
                    raise ValueError(f"INT index must be 0 or 1, got: {index}")
                # INT 0 -> bits[1:0] = 10 ; INT 1 -> bits[1:0] = 11
                # 01 is reserved for the hardware interrupt entry.
                index_bits = '10' if index == 0 else '11'
                instructions.append(opcode + '0' * 25 + index_bits)

            else:
                raise ValueError(f"Unhandled instruction type: {mnemonic}")

        except Exception as e:
            raise ValueError(f"Error assembling '{line}': {str(e)}")

        return instructions

    # ------------------------------------------------------------------
    # Vector table helpers
    # ------------------------------------------------------------------

    def _resolve_vector_directives(self):
        """Resolve .INT_VECTOR targets to addresses after the first pass."""
        for idx, (target_str, line_num) in self._vector_directives.items():
            # vector slot: INT0 -> index 2, INT1 -> index 3
            slot = idx + 2
            if target_str in self.labels:
                addr = self.labels[target_str]
            else:
                try:
                    addr = self.parse_numeric_value(target_str)
                except ValueError:
                    raise ValueError(
                        f"Line {line_num}: .INT_VECTOR target '{target_str}' is neither "
                        f"a known label nor a valid address"
                    )
            if addr < VECTOR_TABLE_SIZE or addr > self.max_address:
                raise ValueError(
                    f"Line {line_num}: .INT_VECTOR target address 0x{addr:X} is out of "
                    f"the valid instruction range (0x{VECTOR_TABLE_SIZE:03X}-0x{self.max_address:03X})"
                )
            self._vectors[slot] = addr

    def _build_vector_table(self, memory: List[str]):
        """Write the four vector-table words into the memory image.

        Slot 0 (0x000): reset vector  -> address of first instruction
        Slot 1 (0x003): HW-INT vector -> reserved (left as 0x00000004 i.e. start)
        Slot 2 (0x001): INT 0 vector  -> set by .INT_VECTOR 0 <target>
        Slot 3 (0x002): INT 1 vector  -> set by .INT_VECTOR 1 <target>

        Each entry is stored as a 32-bit word holding the target address.
        """
        # Reset vector: always points at the first assembled instruction.
        reset_addr = self._first_instruction_address
        if reset_addr is None:
            reset_addr = VECTOR_TABLE_SIZE   # safe default if no instructions
        memory[0] = format(reset_addr, '032b')

        # INT 0 / INT 1 vectors from .INT_VECTOR directives (or 0 if absent).
        for slot in (2, 3):
            addr = self._vectors.get(slot)
            if addr is not None:
                memory[slot] = format(addr, '032b')
            else:
                # Default: point to the reset address (safe trap behaviour).
                memory[slot] = format(reset_addr, '032b')

        # Slot 3: HW-INT vector — default to reset address; user can override
        # with .INT_VECTOR 3 if the ISA supports it.
        hw_addr = self._vectors.get(3)
        memory[3] = format(hw_addr if hw_addr is not None else reset_addr, '032b')

    # ------------------------------------------------------------------
    # Main assembly entry point
    # ------------------------------------------------------------------

    def assemble(self, input_file: str, output_file: str):
        """Run the full two-pass assembly."""
        try:
            print(f"\n{'='*60}")
            print(f"RISC Processor Assembler")
            print(f"{'='*60}")
            print(f"Reading: {input_file}")

            with open(input_file, 'r') as f:
                lines = f.readlines()

            print(f"Total lines: {len(lines)}")

            print(f"\nFirst pass: Collecting labels...")
            processed_lines = self.first_pass(lines)

            print(f"Instructions found: {len(processed_lines)}")
            print(f"Labels found: {len(self.labels)}")

            if self.labels:
                print("\nLabel Table:")
                for label, addr in sorted(self.labels.items(), key=lambda x: x[1]):
                    print(f"  {label:20s} = {addr:5d} (0x{addr:04X})")

            # Resolve .INT_VECTOR directives now that all labels are known.
            self._resolve_vector_directives()

            print(f"\nInitializing memory ({self.memory_size} words)...")
            # Fill entire memory with NOP so unwritten words are benign.
            memory = [self.opcodes['NOP'] + '0' * 27] * self.memory_size

            # Write the vector table before any instructions.
            self._build_vector_table(memory)

            print(f"\nVector table:")
            print(f"  [0x000] Reset vector      -> 0x{self._first_instruction_address or VECTOR_TABLE_SIZE:04X}")
            for slot, label in ((2, "INT 0 vector"), (3, "INT 1 vector"), (4, "HW-INT vector")):
                addr = self._vectors.get(slot)
                resolved = addr if addr is not None else (self._first_instruction_address or VECTOR_TABLE_SIZE)
                print(f"  [0x{slot:03X}] {label:18s} -> 0x{resolved:04X}")

            print(f"\nSecond pass: Generating machine code...")
            error_count = 0

            for address, line, line_num, is_data_value in processed_lines:
                try:
                    if is_data_value:
                        value = self.parse_data_value(line.split()[0])
                        memory[address] = format(value & 0xFFFFFFFF, '032b')
                    else:
                        for i, instruction in enumerate(self.assemble_instruction(line, line_num)):
                            mem_addr = address + i
                            if mem_addr < self.memory_size:
                                memory[mem_addr] = instruction
                            else:
                                raise ValueError(f"Address 0x{mem_addr:X} exceeds memory size")
                except Exception as e:
                    error_count += 1
                    print(f"  ERROR at line {line_num}: {line}")
                    print(f"    {str(e)}")

            if error_count > 0:
                print(f"\nERROR: Assembly failed with {error_count} error(s)")
                sys.exit(1)

            print(f"\nWriting output: {output_file}")
            with open(output_file, 'w') as f:
                f.write("// instance=/cpu/id_memory_inst/mem\n")
                f.write("// format=mti addressradix=h dataradix=s version 1.0 wordsperline=1\n")
                for i, instruction in enumerate(memory):
                    addr_hex = format(i, 'x')
                    f.write(f"{addr_hex:>8}: {instruction}\n")

            print(f"\n{'='*60}")
            print(f"Assembly Successful!")
            print(f"{'='*60}")
            print(f"Input file:    {input_file}")
            print(f"Output file:   {output_file}")
            print(f"Memory size:   {self.memory_size} words")
            print(f"Instructions:  {len(processed_lines)}")
            print(f"Labels:        {len(self.labels)}")
            print(f"{'='*60}\n")

        except FileNotFoundError:
            print(f"ERROR: Input file '{input_file}' not found")
            sys.exit(1)
        except Exception as e:
            print(f"ERROR: Assembly error: {str(e)}")
            import traceback
            traceback.print_exc()
            sys.exit(1)


def main():
    print("\n" + "="*60)
    print("RISC Processor Assembler v2.0")
    print("="*60)

    if len(sys.argv) < 2:
        print("\nUsage: python assembler.py <input.asm> [output.mem]")
        print("\nExample:")
        print("  python assembler.py program.asm program.mem")
        sys.exit(1)

    input_file  = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file.rsplit('.', 1)[0] + '.mem'

    assembler = RISCAssembler()
    assembler.assemble(input_file, output_file)


if __name__ == "__main__":
    main()