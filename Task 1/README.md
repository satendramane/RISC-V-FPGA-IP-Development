# Task-1: Environment Setup & RISC-V Reference Bring-Up

## Objective
- Ensure toolchain readiness
- Verify a working RISC-V reference execution
- Understand the RISC-V software execution flow
- Prepare for upcoming FPGA and IP development work

## Environment Used
- GitHub Codespace
- Oracle VirtualBox

---

## Step 1: GitHub Codespace Setup
### Repository Used
```bash
https://github.com/vsdip/vsd-riscv2
```
-Forked the vsd-riscv2 repository <br>
-Click on the green Code Button <br>
-Make new Codespace (first time may take 10-15 min.)
![Codespace Build](images/Codespace.png)

---

## Step 2: Verify RISC-V Reference Flow 
### Verify the Setup
#### Inside the vsd-riscv2 Codespace:(Follow the README instructions)

In Terminal
```bash
riscv64-unknown-elf-gcc --version
spike --version #If not working then use: spike --help
iverilog -V
```
This will give version information for each tool.

---

## Step 3: Run sum1ton.c Program

```bash
gcc -o sum1ton sum1ton.c
./sum1ton
```

**Expected Output:**
