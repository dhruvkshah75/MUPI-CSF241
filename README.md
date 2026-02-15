# Microprocessors & Interfacing (CS F241)
This repository contains the lab exercises for the **Microprocessors & Interfacing** (MUPI) course, focusing on x86 Assembly language.

* **Language:** 8086 Assembly
* **Assembler:** MASM (Microsoft Macro Assembler) 
* **Environment:** DOSBox 

## How to Run
To run these programs, you need **DOSBox** and **MASM** mounted.
Open DOSBox and run:
```bash
mount c /home/user/MASM/MASM611
c:

cd BIN

masm filename.asm;       # file name should have less than 9 characters 
link filename.obj;
# press Enter 4 times 

filename.exe

```

