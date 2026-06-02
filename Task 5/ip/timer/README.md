# Timer IP — VSDSquadron FPGA

A programmable 32-bit countdown timer peripheral, memory-mapped into a RISC-V SoC, targeting the VSDSquadron FM (iCE40 FPGA).

## What Is This?

A hardware timer that counts down from a programmable value and sets a TIMEOUT flag when it reaches zero. Supports one-shot and periodic modes with an optional prescaler.

## Quick Start (30 seconds)

### Base Address
```c
#define TIMER_BASE  0x400040
```

### Minimal Example
```c
#define TIMER_CTRL   (*((volatile uint32_t *)(0x400040 + 0x00)))
#define TIMER_LOAD   (*((volatile uint32_t *)(0x400040 + 0x04)))
#define TIMER_STATUS (*((volatile uint32_t *)(0x400040 + 0x0C)))

TIMER_LOAD = 1000;       // Count from 1000
TIMER_CTRL = 0x1;        // Enable, one-shot
while (!(TIMER_STATUS & 0x1));  // Wait for timeout
TIMER_STATUS = 0x1;      // Clear flag
```

## Documentation

| File | Description |
|------|-------------|
| [docs/IP_User_Guide.md](docs/IP_User_Guide.md) | Full IP overview, features, block diagram |
| [docs/Register_Map.md](docs/Register_Map.md) | All registers, bits, reset values |
| [docs/Integration_Guide.md](docs/Integration_Guide.md) | How to integrate into your SoC |
| [docs/Example_Usage.md](docs/Example_Usage.md) | Ready-to-run C code examples |

## Hardware Validation

Tested on **VSDSquadron FM** (Lattice iCE40UP5K):
- ✅ Synthesis: 0 problems, 1405 LUTs
- ✅ Max frequency: 17.32 MHz (target: 12 MHz)
- ✅ Board demo: LED toggles on every timer timeout

## Author
VSD RISC-V Workshop — Task 4 & Task 5
Assigned IP: Timer
