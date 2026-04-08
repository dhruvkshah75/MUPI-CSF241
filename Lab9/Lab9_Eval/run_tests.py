#!/usr/bin/env python3
"""
run_tests.py — Lab 9: Module Testbench Runner
=======================================================
Compiles and simulates each Verilog testbench in dependency order.
Testbench files live in: testbenches/
Module source files live in the current directory.

Requirements: iverilog + vvp (Icarus Verilog)

Usage:
    python3 run_tests.py              # run all testbenches
    python3 run_tests.py D_ff         # run a single named testbench
"""

import subprocess
import os
import sys

# ── ANSI colours ──────────────────────────────────────────────────────────────
GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

# ── Testbenches in bottom-up dependency order ─────────────────────────────────
TESTBENCHES = [
    ("D_ff",           "D_ff_tb.v",           "D Flip-Flop"),
    ("decoder4to16",   "decoder4to16_tb.v",    "4-to-16 Decoder"),
    ("mux2to1_16bits", "mux2to1_16bits_tb.v",  "2-to-1 16-bit MUX"),
    ("mux32to2",       "mux32to2_tb.v",        "32-to-2 Byte MUX"),
    ("register8bit",   "register8bit_tb.v",    "8-bit Register"),
    ("ram32byte",      "ram32byte_tb.v",        "32-Byte RAM"),
    ("rom32byte",      "rom32byte_tb.v",        "32-Byte ROM"),
    ("memory_system",  "memory_system_tb.v",    "Memory System (8086)"),
]

MARKS_RUBRIC = {
    "D_ff": 0.0,
    "decoder4to16": 0.5,
    "mux2to1_16bits": 0.5,
    "mux32to2": 1.0,
    "register8bit": 1.0,
    "ram32byte": 2.0,
    "rom32byte": 2.0,
    "memory_system": 3.0
}

TB_DIR  = "testbenches"
TMP_DIR = "/tmp/lab9"

def sep(ch="─", n=62):
    return ch * n

def run_one(name, tb_file):
    sim_bin = os.path.join(TMP_DIR, f"{name}_sim")
    compile_result = subprocess.run(
        ["iverilog", "-g2001", "-o", sim_bin, tb_file],
        capture_output=True, text=True
    )
    if compile_result.returncode != 0:
        return False, f"{RED}COMPILE ERROR{RESET}\n{compile_result.stderr.strip()}"

    sim_result = subprocess.run(
        ["vvp", sim_bin], capture_output=True, text=True, timeout=30
    )
    output = sim_result.stdout
    if sim_result.returncode != 0:
        output += f"\n{RED}SIMULATION ERROR:{RESET}\n{sim_result.stderr}"
        return False, output
    return "SOME TESTS FAILED" not in output, output


def main():
    os.makedirs("outputs", exist_ok=True)
    os.makedirs(TMP_DIR, exist_ok=True)

    filter_name = sys.argv[1].lower() if len(sys.argv) > 1 else None
    selected = [(n, os.path.join(TB_DIR, f), d) for n, f, d in TESTBENCHES
                if filter_name is None or filter_name in n.lower()]

    if not selected:
        print(f"{RED}No testbench matching '{filter_name}'.{RESET}")
        sys.exit(1)

    results = []

    for name, tb_path, description in selected:
        print(f"\n{BOLD}{sep()}{RESET}")
        print(f"{CYAN}{BOLD}  Testing: {description}{RESET}")
        print(f"{BOLD}{sep()}{RESET}")

        if not os.path.exists(tb_path):
            print(f"  {YELLOW}SKIP — {tb_path} not found{RESET}")
            results.append((name, description, None))
            continue

        try:
            passed, output = run_one(name, tb_path)
        except subprocess.TimeoutExpired:
            print(f"  {RED}TIMEOUT{RESET}")
            results.append((name, description, False))
            continue

        for line in output.strip().splitlines():
            print(f"  {line}")
        results.append((name, description, passed))

    # Summary
    print(f"\n{BOLD}{sep('═')}{RESET}")
    print(f"{BOLD}  RESULTS{RESET}")
    print(f"{BOLD}{sep('═')}{RESET}")
    n_pass = sum(1 for _, _, p in results if p is True)
    n_fail = sum(1 for _, _, p in results if p is False)
    n_skip = sum(1 for _, _, p in results if p is None)
    total  = sum(1 for _, _, p in results if p is not None)

    total_marks = 0.0
    earned_marks = 0.0

    for name, description, passed in results:
        badge = (f"{YELLOW}SKIP{RESET}" if passed is None else
                 f"{GREEN}PASS{RESET}" if passed else f"{RED}FAIL{RESET}")
        
        module_marks = MARKS_RUBRIC.get(name, 0.0)
        total_marks += module_marks
        if passed is True:
            earned_marks += module_marks

        print(f"  {badge}  {description:<25} ({module_marks} marks)")

    print(f"{BOLD}{sep()}{RESET}")
    print(f"  {GREEN}{n_pass} passed{RESET} | {RED}{n_fail} failed{RESET} | "
          f"{YELLOW}{n_skip} skipped{RESET}  (of {total})")
    
    print(f"  {BOLD}TOTAL SCORE: {earned_marks}/{total_marks} marks{RESET}")

    if n_fail == 0 and total > 0:
        print(f"\n  {GREEN}{BOLD}All tested modules passed ✓{RESET}")
    else:
        print(f"\n  {RED}Some modules need work — see output above.{RESET}")

    sys.exit(0 if n_fail == 0 else 1)


if __name__ == "__main__":
    main()
