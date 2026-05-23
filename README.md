# Task-1: Environment Setup & RISC-V Reference Bring-Up

> **Internship Task | Deadline: 48 hours from task release**  
> **Status: Steps 1 & 2 Completed ✅**

---

## Table of Contents

- [Objective](#objective)
- [Step 1: GitHub Codespace Setup](#step-1-github-codespace-setup)
- [Step 2: RISC-V Reference Flow Verification](#step-2-risc-v-reference-flow-verification)
- [Understanding Check (Answers)](#understanding-check-answers)
- [Environment Used](#environment-used)

---

## Objective

Set up the development environment and successfully run a working **RISC-V reference design** using the [vsd-riscv2](https://github.com/vsdip/vsd-riscv2) repository.

This task focuses on:
- Toolchain readiness (`riscv64-unknown-elf-gcc`, `spike`, `iverilog`)
- Understanding the RISC-V execution flow
- Preparing for upcoming FPGA and IP development work

> ⚠️ This is **not** an FPGA programming task. FPGA tools (yosys, nextpnr) are intentionally **not installed** at this stage.

---

## Step 1: GitHub Codespace Setup

### 1.1 Fork the Repository

Fork the official reference repository to your GitHub account:

```
https://github.com/vsdip/vsd-riscv2
```

- Navigate to the repo → click **Fork** (top-right) → select your account.

### 1.2 Launch GitHub Codespace

1. Go to your forked repository.
2. Click the green **`< > Code`** button.
3. Select **`Open with Codespaces`** → **`New codespace`**.
4. Wait for the environment to build — first-time build takes approximately **10–15 minutes**.
5. A browser-based VS Code terminal will open automatically once ready.

### 1.3 Verify Toolchain

Once the Codespace terminal is open, verify the pre-installed tools:

```bash
riscv64-unknown-elf-gcc --version
spike --version
iverilog -V
```

**Expected output (example):**

```
riscv64-unknown-elf-gcc (GCC) 12.x.x ...
Spike RISC-V ISA Simulator ...
Icarus Verilog version 12.x ...
```

All three tools should print version information with **no errors**.

---

## Step 2: RISC-V Reference Flow Verification

### 2.1 Navigate to the Samples Folder

Inside the Codespace terminal:

```bash
cd samples
ls
```

You should see `sum1ton.c` (and possibly other sample files).

### 2.2 Compile the RISC-V Program

Use the RISC-V cross-compiler to compile the C program:

```bash
riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c
```

| Flag | Meaning |
|------|---------|
| `riscv64-unknown-elf-gcc` | Cross-compiler targeting RISC-V 64-bit bare-metal |
| `-o sum1ton.o` | Output object/executable file name |
| `sum1ton.c` | Source C program |

### 2.3 Run with Spike Simulator

Execute the compiled binary using the **Spike RISC-V ISA Simulator**:

```bash
spike pk sum1ton.o
```

**Expected output:**

```
Sum from 1 to 9 is 45
```

✅ If you see this output, the toolchain is working correctly and the RISC-V reference flow is verified.

### 2.4 What is Happening Under the Hood?

```
sum1ton.c  ──[riscv64-unknown-elf-gcc]──►  sum1ton.o (RISC-V ELF binary)
                                                  │
                                          [spike pk]
                                                  │
                                          Spike loads ELF into
                                          simulated memory, pk
                                          (proxy kernel) handles
                                          syscalls (printf)
                                                  │
                                          Output: "Sum from 1 to 9 is 45"
```

- **`spike`** — A functional RISC-V ISA simulator that simulates a RISC-V CPU in software.
- **`pk`** (Proxy Kernel) — A lightweight kernel that intercepts system calls (like `printf`) and forwards them to the host machine. This lets bare-metal RISC-V binaries produce console output without real hardware.

---

## Understanding Check (Answers)

### Q1. Where is the RISC-V program located in the vsd-riscv2 repository?

The RISC-V program (`sum1ton.c`) is located in the **`samples/`** directory of the repository:

```
vsd-riscv2/
└── samples/
    └── sum1ton.c    ← RISC-V C program (sum of 1 to N)
```

---

### Q2. How is the program compiled and loaded into memory?

**Compilation:**  
The C source is compiled using the RISC-V cross-toolchain:

```bash
riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c
```

This produces an **ELF (Executable and Linkable Format)** binary targeting the RISC-V ISA — not the host machine (x86/ARM).

**Loading into memory:**  
The **Spike simulator** (`spike pk sum1ton.o`) reads the ELF file, parses its segments, and **loads the program instructions and data into a simulated memory space**. The proxy kernel (`pk`) sets up a minimal runtime environment, and Spike begins executing from the ELF entry point — exactly as a real RISC-V CPU would boot and run a program.

---

### Q3. How does the RISC-V core access memory and memory-mapped IO?

**Memory Access:**  
The RISC-V core uses **load/store instructions** (`lw`, `sw`, `lb`, `sb`, etc.) to read from and write to memory. All memory accesses go through the **address space** — a flat, byte-addressable 64-bit space (for RV64).

**Memory-Mapped IO (MMIO):**  
In RISC-V systems, peripherals (UART, GPIO, timers, etc.) are accessed by reading/writing to **specific physical addresses** in the address map — there are no separate I/O instructions (unlike x86). For example:

```
Address 0x10000000 → UART TX register (write a byte here = send a character)
Address 0x02000000 → CLINT (timer interrupt registers)
```

In the Spike + pk simulation environment, `printf` syscalls are intercepted by the proxy kernel and forwarded to the host terminal, abstracting away actual MMIO. In a real SoC (e.g., on an FPGA), the core would write to a UART MMIO address to transmit characters.

---

### Q4. Where would a new FPGA IP block logically integrate in this system?

A new FPGA IP block (e.g., a custom accelerator, GPIO controller, or DSP block) would integrate at the **SoC bus/interconnect layer**, connected to the RISC-V core via the **memory-mapped address space**.

**Integration point:**

```
RISC-V Core
     │
     │  (Load/Store instructions to MMIO address)
     ▼
  AXI / Wishbone Bus Fabric  ◄── New IP block connects here
     │            │
     ▼            ▼
   SRAM        [New IP Block]
              (e.g., custom accelerator, UART, GPIO)
              Assigned a unique base address in the memory map
```

The CPU communicates with the new IP by reading/writing its **base address**. The IP block exposes control/status registers (CSRs) at fixed offsets. The software (running on the RISC-V core) uses these addresses to configure and interact with the IP — no changes to the core itself are needed.

---

## Environment Used

- ✅ **GitHub Codespace** (primary environment for Steps 1 & 2)
- 🔄 Local machine setup — in progress (Step 4)

### Codespace Specs

| Tool | Purpose |
|------|---------|
| `riscv64-unknown-elf-gcc` | RISC-V cross-compiler |
| `spike` | RISC-V ISA simulator |
| `pk` (proxy kernel) | Syscall handling for Spike |
| `iverilog` | Verilog simulator (for later labs) |

---

## Repository Structure

```
Task-1-RISCV-Bringup/
├── README.md               ← This file (Steps 1 & 2 documentation)
├── screenshots/
│   ├── codespace_build.png      ← Codespace launched successfully
│   ├── toolchain_versions.png   ← gcc, spike, iverilog version output
│   └── spike_output.png         ← "Sum from 1 to 9 is 45" output
└── notes/
    └── understanding_check.md   ← Answers to the 4 questions (also in README)
```

---

*Task from [vsd-riscv2](https://github.com/vsdip/vsd-riscv2) — VSD FPGA Internship Program*
