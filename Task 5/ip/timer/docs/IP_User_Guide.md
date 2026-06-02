# IP User Guide — Timer IP

## 1. Purpose

This IP provides a **programmable 32-bit countdown timer** suitable for:
- Software delays
- Periodic event generation
- Timeout detection
- LED blinking via software control

## 2. Typical Use Cases

| Use Case | Mode | Description |
|----------|------|-------------|
| One-time delay | One-shot | Count down once, stop, set flag |
| Periodic heartbeat | Periodic | Auto-reload, keep counting forever |
| LED blink | Periodic | Toggle LED on every timeout |

## 3. Feature Summary

| Feature | Details |
|---------|---------|
| Counter width | 32-bit |
| Modes | One-shot, Periodic (auto-reload) |
| Prescaler | Optional, 8-bit divide value |
| Timeout flag | Write-1-to-clear |
| Bus interface | 32-bit memory-mapped, word-aligned |
| Clock | 12 MHz system clock |

### Known Limitations
- No interrupt support (software must poll STATUS)
- Single channel only
- No capture/compare functionality

## 4. Block Diagram
CPU Bus
      |
+------+------+
| Address Dec |
+------+------+
|
+------+------+
| Registers    |
| CTRL/LOAD/.. |
+------+------+
|
+------+------+
| Prescaler    |
+------+------+
|
+------+------+
| 32-bit Count |
+------+------+
|
TIMEOUT
## 5. Timing at 12 MHz

| LOAD Value | No Prescaler | Prescaler ÷256 |
|------------|-------------|----------------|
| 12,000 | 1 ms | 256 ms |
| 120,000 | 10 ms | 2.56 sec |
| 1,200,000 | 100 ms | 25.6 sec |
| 12,000,000 | 1 sec | ~4.27 min |

## 6. Validation

### Simulation
✅ One-shot mode: VALUE counts to 0, TIMEOUT set
✅ Periodic mode: 3 consecutive timeouts observed
✅ Write-1-to-clear STATUS works

### Hardware (VSDSquadron FM)
✅ Synthesis: 0 problems
✅ Max frequency: 17.32 MHz (PASS at 12 MHz)
✅ LED toggles on timeout
