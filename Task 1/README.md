# Task-1: Environment Setup & RISC-V Reference Bring-Up

## Objective
- Ensure toolchain readiness
- Verify a working RISC-V reference execution
- Understand the RISC-V software execution flow
- Prepare for upcoming FPGA and IP development work

## Environment Used
- Oracle VirtualBox with VSDSquadron FPGA Mini VDI
- OS: Xubuntu 64-bit
- Local machine (not GitHub Codespace)

---

## Step 1: Install Dependencies

```bash
sudo apt-get update
sudo apt-get install git vim autoconf automake curl libmpc-dev \
libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
gperf libtool patchutils bc zlib1g-dev libexpat1-dev gtkwave picocom -y
```

---

## Step 2: Clone vsd-riscv2 Repository

```bash
cd /home/vsduser
git clone https://github.com/YOUR_USERNAME/vsd-riscv2.git
cd vsd-riscv2/samples
```

---

## Step 3: Run sum1ton.c Program

```bash
gcc -o sum1ton sum1ton.c
./sum1ton
```

**Expected Output:**
