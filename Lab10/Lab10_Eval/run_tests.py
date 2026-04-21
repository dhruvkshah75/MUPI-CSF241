#!/usr/bin/env python3
"""
run_tests.py — Lab 10: Module Testbench Runner
=======================================================
Compiles and simulates each Verilog testbench in dependency order.
Testbench files live in: testbenches/
Module source files live in the current directory.

Requirements: iverilog + vvp (Icarus Verilog)

Usage:
    python3 run_tests.py              # run all testbenches
    python3 run_tests.py control_register  # run a single named testbench
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
    ("control_register", "control_register_tb.v", "Control Register"),
    ("counter",          "counter_tb.v",          "Counter"),
    ("top",              "top_tb.v",              "Top Module (Timer)"),
]

MARKS_RUBRIC = {
    "control_register": 2.0,
    "counter": 4.0,
    "top": 4.0
}

TB_DIR  = "testbenches"
TMP_DIR = "/tmp/lab10"

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

    cwd = os.getcwd()
    sim_result = subprocess.run(
        ["vvp", sim_bin], capture_output=True, text=True, timeout=30, cwd=cwd
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
            results.append((name, description, None, ""))
            continue

        try:
            passed, output = run_one(name, tb_path)
            for line in output.strip().splitlines():
                print(f"  {line}")
            results.append((name, description, passed, output))
        except subprocess.TimeoutExpired:
            print(f"  {RED}TIMEOUT{RESET}")
            results.append((name, description, False, ""))

    # Summary
    print(f"\n{BOLD}{sep('═')}{RESET}")
    print(f"{BOLD}  RESULTS{RESET}")
    print(f"{BOLD}{sep('═')}{RESET}")
    
    import re
    total_marks = 0.0
    earned_marks = 0.0
    
    n_pass = 0
    n_fail = 0
    n_skip = 0

    for name, description, passed, output in results:
        badge = f"{YELLOW}SKIP{RESET}"
        if passed is True:
            badge = f"{GREEN}PASS{RESET}"
            n_pass += 1
        elif passed is False:
            badge = f"{RED}FAIL{RESET}"
            n_fail += 1
        else:
            n_skip += 1
        
        module_marks = MARKS_RUBRIC.get(name, 0.0)
        total_marks += module_marks
        
        # Parse score
        module_earned = 0.0
        match = re.search(r"Score:\s*([\d.]+)\s*/\s*([\d.]+)", output)
        if match:
            # Score: X / Y Marks
            # In testbenches this is literal marks earned over max marks for that module
            module_earned = float(match.group(1))
        elif passed is True:
            module_earned = module_marks
            
        earned_marks += module_earned

        print(f"  {badge}  {description:<25} ({module_earned}/{module_marks} marks)")

    total = n_pass + n_fail + n_skip
    print(f"{BOLD}{sep()}{RESET}")
    print(f"  {GREEN}{n_pass} module(s) fully passed{RESET} | {RED}{n_fail} module(s) failed tests{RESET} | "
          f"{YELLOW}{n_skip} skipped{RESET}  (of {total})")
    
    print(f"  {BOLD}TOTAL SCORE: {earned_marks}/{total_marks} marks{RESET}")

    if n_fail == 0 and total > 0:
        print(f"\n  {GREEN}{BOLD}All tested modules passed ✓{RESET}")
    else:
        print(f"\n  {RED}Some modules need work — see output above.{RESET}")

    sys.exit(0 if n_fail == 0 else 1)


if __name__ == "__main__":
    main()
