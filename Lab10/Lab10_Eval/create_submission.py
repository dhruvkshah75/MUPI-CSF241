#!/usr/bin/env python3
"""
create_submission.py — Lab 10
======================================
Packages student-written Verilog files into a ZIP for submission.
Run from the lab10/ directory:

    python3 create_submission.py
"""

import os, sys, zipfile

def cprint(msg, code):
    print(f"\033[{code}m{msg}\033[0m")

FILES = [
    "control_register.v",
    "counter.v",
    "data_bus_buffer.v",
    "rw_logic.v",
    "top.v",
]

student_id = input("Enter your ID number (e.g. 2022A7PS9999G): ").strip()
if len(student_id) != 13:
    cprint("Invalid ID number (expected 13 characters).", 91)
    sys.exit(1)

zip_name = f"{student_id}_lab10.zip"

missing = [f for f in FILES if not os.path.exists(f)]
if missing:
    cprint(f"Missing files: {', '.join(missing)}", 91)
    sys.exit(1)

with zipfile.ZipFile(zip_name, "w") as zf:
    for f in FILES:
        zf.write(f, f)
    
    if os.path.exists("outputs"):
        for output_file in os.listdir("outputs"):
            if output_file.endswith(".vcd"):
                zf.write(os.path.join("outputs", output_file), os.path.join("outputs", output_file))

cprint(f"Created '{zip_name}' — submit this on Quanta.", 92)
