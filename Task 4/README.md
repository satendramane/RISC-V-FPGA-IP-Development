# Task 4: Timer IP — Real Peripheral IP Development

## What This IP Does

This is a **programmable countdown timer** integrated as a memory-mapped peripheral into a RISC-V SoC targeting the VSDSquadron FM (iCE40 FPGA).

The timer counts down from a programmable value and sets a **TIMEOUT flag** when it reaches zero. It supports:
- **One-shot mode** — counts down once and stops
- **Periodic mode** — auto-reloads and keeps counting
- **Prescaler** — slows the count rate for longer timeouts

---

## Repository Structure

```
/ip/timer/
├── rtl/
│   ├── timer.v           ← Timer IP (this file)
│   ├── riscv.v           ← RISC-V SoC (modified to integrate timer)
│   └── gpio_out_v2.v     ← GPIO IP (from Task 3, used alongside timer)
├── test/
│   ├── timer_test.c      ← C firmware test
│   └── Makefile          ← Build system
└── README.md             ← This file
```

---

## Register Map

**Base Address:** `0x400040`

| Offset | Name   | R/W | Description                        |
|--------|--------|-----|------------------------------------|
| 0x00   | CTRL   | R/W | Control: EN, MODE, PRESC_EN, PRESC_DIV |
| 0x04   | LOAD   | R/W | Countdown start value              |
| 0x08   | VALUE  | R   | Current countdown value (read-only)|
| 0x0C   | STATUS | R/W | Timeout flag (write-1-to-clear)    |

### CTRL Register (0x00)
| Bit     | Name      | Description                                      |
|---------|-----------|--------------------------------------------------|
| [0]     | EN        | 1 = enable counting, 0 = stop                    |
| [1]     | MODE      | 0 = one-shot, 1 = periodic (auto-reload)         |
| [2]     | PRESC_EN  | 1 = enable prescaler                             |
| [15:8]  | PRESC_DIV | Prescaler divide value — decrement every (PRESC_DIV+1) cycles |

### LOAD Register (0x04)
32-bit start value. Timer loads this value when enabled or when periodic reload occurs.

### VALUE Register (0x08)
Current countdown value. Read-only. Decrements every clock cycle (or every PRESC_DIV+1 cycles if prescaler enabled).

### STATUS Register (0x0C)
| Bit | Name    | Description                              |
|-----|---------|------------------------------------------|
| [0] | TIMEOUT | Set to 1 when VALUE reaches 0. Write 1 to clear. |

---

## How Software Controls It

### One-Shot Example
```c
#define TIMER_BASE   0x400040
#define TIMER_CTRL   (*((volatile uint32_t *)(TIMER_BASE + 0x00)))
#define TIMER_LOAD   (*((volatile uint32_t *)(TIMER_BASE + 0x04)))
#define TIMER_VALUE  (*((volatile uint32_t *)(TIMER_BASE + 0x08)))
#define TIMER_STATUS (*((volatile uint32_t *)(TIMER_BASE + 0x0C)))

// One-shot: count down from 100, then stop
TIMER_CTRL = 0x0;        // Disable first
TIMER_LOAD = 100;        // Load value
TIMER_CTRL = 0x1;        // EN=1, MODE=0 (one-shot)

while (!(TIMER_STATUS & 0x1));  // Wait for timeout
TIMER_STATUS = 0x1;             // Clear timeout flag
```

### Periodic Example
```c
// Periodic: reload every 50 cycles, count 3 timeouts
TIMER_CTRL = 0x0;
TIMER_LOAD = 50;
TIMER_CTRL = 0x3;        // EN=1, MODE=1 (periodic)

int count = 0;
while (count < 3) {
    while (!(TIMER_STATUS & 0x1));
    TIMER_STATUS = 0x1;
    count++;
}
TIMER_CTRL = 0x0;        // Stop
```

---

## SoC Integration

The timer is connected to the RISC-V CPU bus in `riscv.v`:

```verilog
localparam IO_TIMER_bit = 4;   // Bit 4 of word address

wire [31:0] timer_rdata;
timer TIMER (
   .clk(clk),
   .rst(!resetn),
   .valid(isIO & mem_wordaddr[IO_TIMER_bit]),
   .we(mem_wstrb),
   .addr(mem_addr),
   .wdata(mem_wdata),
   .rdata(timer_rdata)
);
```

**Address decoding:**
- IO space selected by `mem_addr[22]` = bit 22 of byte address
- Timer selected by `mem_wordaddr[4]` = bit 4 of word address = bit 6 of byte address
- Base address = `(1 << 22) | (1 << 6)` = `0x400040`

The timer readback is added to the IO mux:
```verilog
mem_wordaddr[IO_TIMER_bit] ? timer_rdata :
```

---

## Simulation Results

### Terminal Output
```
=== TIMER TEST START ===
Test 1: One-shot mode
Timeout! VALUE=0
Status cleared: 0
Test 2: Periodic mode
Periodic timeout #1
Periodic timeout #2
Periodic timeout #3
=== TIMER TEST DONE ===
```

### Simulation Waveform
> 📸 **[INSERT SCREENSHOT HERE]**
> Open GTKWave and take a screenshot showing:
> - `ctrl_reg` → 00000001 (one-shot) then 00000003 (periodic)
> - `load_reg` → 00000064 (100) then 00000032 (50)
> - `value_reg` counting down
> - `timeout_flag` going HIGH at timeout
>
> **How to open:** In Codespace noVNC, run:
> ```bash
> gtkwave gpio_sim.vcd timer_waves.gtkw &
> ```
> Set From: `50000000`, To: `180000000`

---

## Synthesis Results

### Yosys Synthesis
```
Number of cells: 1909
  SB_LUT4:  1405
  SB_DFFE:    50
  SB_RAM40_4K: 16
found and reported 0 problems 
```

> 📸 **[INSERT SCREENSHOT HERE]**
> Take a screenshot of your terminal showing the Yosys synthesis output ending with `found and reported 0 problems`

### Place & Route (nextpnr)
```
Max frequency for clock 'clk': 17.32 MHz (PASS at 12.00 MHz) 
1 warning, 0 errors
```

> 📸 **[INSERT SCREENSHOT HERE]**
> Take a screenshot showing `Max frequency` line and `PASS` result

---

## Hardware Validation

### Flashing the Board
```bash
sudo iceprog SOC.bin
```
Expected output:
```
init..
programming..
VERIFY OK 
```

> 📸 **[INSERT SCREENSHOT HERE]**
> Take a screenshot of your Ubuntu VM terminal showing `VERIFY OK`

### Board Demo — LED Blink on Timeout
The firmware toggles the RGB LED on every timer timeout.

> 📸 **[INSERT PHOTO HERE]**
> Take a photo of your VSDSquadron FM board showing:
> - The RGB LED glowing
> - CH340 connected for UART
> - Board powered via USB-C

### UART Output
Connect CH340 to board TXD pin, then run:
```bash
sudo screen /dev/ttyUSB0 9600
```
Press RESET. Expected output:
```
=== TIMER LED TEST ===
Timeout #1 LED ON
Timeout #2 LED OFF
Timeout #3 LED ON
...
=== DONE ===
```

> 📸 **[INSERT SCREENSHOT HERE]**
> Take a screenshot of the UART output in minicom/screen

---

## Design Decisions

1. **Single always block** — All registers (CTRL, LOAD, VALUE, STATUS) are updated in one synchronous always block to avoid multi-driver conflicts.

2. **CPU write priority** — The timeout flag clear (CPU write) takes priority over the timer set in the same clock cycle to ensure reliable software control.

3. **Prescaler** — Allows very long timeouts without needing a large LOAD value. A prescaler of 255 at 12MHz gives ~21ms per decrement.

4. **One-shot behavior** — When VALUE=0 in one-shot mode, the timer stays at 0 and EN remains set. Software must clear EN or reload LOAD to restart.

5. **Periodic reload** — In periodic mode, VALUE reloads from LOAD in the same cycle it hits 0, so there is no missed cycle.

---

## Building and Running

### Compile Firmware
```bash
cd Firmware
make timer_test.bram.hex
cp timer_test.bram.hex ../RTL/firmware.hex
```

### Run Simulation
```bash
cd RTL
iverilog -o test_timer -DBENCH riscv.v gpio_out_v2.v timer.v ice40_primitives.v
vvp test_timer
```

### Synthesize
```bash
yosys -p "synth_ice40 -top SOC -json SOC.json" riscv.v gpio_out_v2.v timer.v
nextpnr-ice40 --up5k --package sg48 --json SOC.json --pcf VSDSquadronFM.pcf --asc SOC.asc
icepack SOC.asc SOC.bin
```

### Flash to Board
```bash
sudo iceprog SOC.bin
```

---


