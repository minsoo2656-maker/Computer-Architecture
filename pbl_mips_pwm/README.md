# MIPS PWM Motor Controller

A 5-stage pipelined MIPS processor controls a PWM output through memory-mapped I/O.

```text
MIPS CPU -> Data Memory / MMIO -> PWM Controller -> pwm_out
```

| Address | Device | Direction | Notes |
|---|---|---|---|
| `0x0000` | RAM | read/write | data memory |
| `0x0090` | switches | read | 8-bit input |
| `0x0098` | PWM duty | write | 8-bit duty value |
| `0x009C` | PWM enable | write | 1-bit enable |

Build and run:

```bash
make
make wave
```

The program enables PWM, ramps the duty value from 0 to 255, holds the maximum value, ramps back down to 0, holds 0, and repeats.

```text
pbl_mips_pwm/
├── Makefile
├── memfile.dat
├── mips.v
├── mips_tb.v
├── datapath.v
├── data_memory.v
├── pwm_controller.v
├── control_unit.v
├── hazard_unit.v
├── main_decoder.v
├── alu_decoder.v
├── instruction_memory.v
├── reg_file.v
├── alu.v
├── pc.v
└── docs/
    ├── design_report.md
    ├── test_report.md
    ├── waveform_mmio.png
    └── waveform_pwm_counter.png
```
