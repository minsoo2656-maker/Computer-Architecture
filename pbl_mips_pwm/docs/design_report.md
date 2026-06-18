# Design Report

## Introduction

This project connects a pipelined MIPS processor to a PWM controller through memory-mapped I/O. The processor runs a MIPS machine-code program from instruction memory, writes duty-cycle values to an MMIO register, and produces a PWM waveform through the peripheral.

## System Architecture

```text
Instruction Memory -> MIPS Pipeline -> Data Memory / MMIO -> PWM Controller -> pwm_out
                                      ^
                                      |
                                   switches
```

The instruction memory loads `memfile.dat`. The control unit and datapath execute the program through the five pipeline stages. The hazard unit handles forwarding, branch hazards, and load-use stalls. The data memory module stores normal RAM data and also decodes MMIO addresses. The PWM controller receives `enable` and `duty_cycle` values and generates `pwm_out`.

## MMIO Design

| Address | Device | Direction | Notes |
|---|---|---|---|
| `0x0000` | RAM | read/write | normal data memory |
| `0x0090` | switches | read | 8-bit external input |
| `0x0098` | PWM duty | write | 8-bit PWM duty cycle |
| `0x009C` | PWM enable | write | 1-bit enable |

The data memory checks the address in a `case` statement. `0x90` returns the switch input, `0x98` updates the duty register, and `0x9C` updates the enable register. Other addresses go to RAM. Writes are synchronous so that register updates happen on the clock edge. Reads are combinational so that the MEM stage can receive the selected data value directly.

## PWM Controller Design

The PWM controller uses an 8-bit counter and a comparator. When enabled, the counter increments every clock. The output is high while `counter < duty_cycle`; otherwise it is low. A duty value of 0 produces a low output, 128 produces about 50 percent duty, and 255 produces almost full duty. The PWM period is `256 × Tclk`. With the testbench clock period of 10 ns, one PWM period is 2.56 us.

## Software Algorithm

Option A was used: ramp-up, hold at maximum, ramp-down, hold at zero, and repeat.

```text
enable PWM
set duty = 0
while true:
    while duty != 255:
        write duty to 0x98
        duty = duty + 1
        delay
    write 255 to 0x98
    hold
    while duty != 0:
        write duty to 0x98
        duty = duty - 1
        delay
    write 0 to 0x98
    hold
```

The delay loop keeps each duty value visible for multiple cycles. The hold loops keep the waveform at maximum and zero before the next phase begins.

## Reflection

The main difficulty was connecting the software-visible memory addresses to hardware registers without changing the normal RAM behavior. With more time, the testbench could include more automated checks for duty-cycle timing and reset behavior.
