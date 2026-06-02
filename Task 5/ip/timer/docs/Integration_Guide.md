# Integration Guide

## Add to riscv.v

```verilog
localparam IO_TIMER_bit = 4;
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

assign mem_rdata = mem_wordaddr[IO_TIMER_bit] ? timer_rdata : 32'b0;
```

## Compile & Flash

```bash
iverilog -o test_timer -DBENCH riscv.v gpio_out_v2.v timer.v ice40_primitives.v
vvp test_timer
yosys -p "synth_ice40 -top SOC -json SOC.json" riscv.v gpio_out_v2.v timer.v
nextpnr-ice40 --up5k --package sg48 --json SOC.json --pcf VSDSquadronFM.pcf --asc SOC.asc
icepack SOC.asc SOC.bin
sudo iceprog SOC.bin
```
