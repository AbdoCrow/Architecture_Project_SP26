#!/usr/bin/env python3
"""Assembler skeleton (no encoding logic yet)."""

import argparse


def main() -> None:
    parser = argparse.ArgumentParser(description="Processor assembler skeleton")
    parser.add_argument("input", help="assembly input file")
    parser.add_argument("output", help="output .mem file")
    _args = parser.parse_args()

    raise NotImplementedError("Assembler encoding is intentionally left for team implementation.")


if __name__ == "__main__":
    main()
