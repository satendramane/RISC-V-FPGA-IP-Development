# Register Map — Timer IP

**Base Address:** `0x400040`

## Register Summary

| Offset | Name   | R/W | Reset | Description |
|--------|--------|-----|-------|-------------|
| 0x00   | CTRL   | R/W | 0x00  | Control register |
| 0x04   | LOAD   | R/W | 0x00  | Countdown start value |
| 0x08   | VALUE  | R   | 0x00  | Current countdown value |
| 0x0C   | STATUS | R/W | 0x00  | Timeout status flag |

## CTRL — Control Register (0x00)

| Bits   | Name      | R/W | Reset | Description |
|--------|-----------|-----|-------|-------------|
| [0]    | EN        | R/W | 0     | 1=enable, 0=stop |
| [1]    | MODE      | R/W | 0     | 0=one-shot, 1=periodic |
| [2]    | PRESC_EN  | R/W | 0     | 1=enable prescaler |
| [15:8] | PRESC_DIV | R/W | 0     | Prescaler divide (÷PRESC_DIV+1) |

## LOAD Register (0x04)
32-bit start value. Timer loads this when enabled or reloads in periodic mode.

## VALUE Register (0x08)
Current countdown value (read-only). Decrements each clock cycle (or every PRESC_DIV+1 cycles if prescaler enabled).

## STATUS Register (0x0C)
| Bits | Name    | Description |
|-----|---------|-------------|
| [0] | TIMEOUT | Set to 1 at VALUE=0. Write 1 to clear. |
