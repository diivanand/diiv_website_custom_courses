# Course 2 — Embedded DSP: lab workspace

Bench workspace for [Course 2 on diiv.io](https://www.diiv.io/course2/) — 46 labs
from instruments and analog front-ends through STM32 real-time DSP firmware to
edge ML and host-in-the-loop media. **Lab instructions live on the website, not
here** — each lab folder holds only what working it produces: notes, code,
captures, benchmarks, models.

## Modules

- m0 — Bench instruments & safety (labs 0.1–0.3): PSU, Fluke DMM, LCR meter
- m1 — Oscilloscope fundamentals (labs 1.1–1.3): probe compensation, measurements
- m2 — Digital timing & interrupts (labs 2.1–2.3): Saleae GPIO/timer/UART timing
- m3 — Mixed-signal I/O over I²C (labs 3.1–3.5): MCP4725 DAC, ADS1115 ADC
- m4 — Analog front-ends (labs 4.1–4.4): MCP6002 op-amp circuits
- m5 — Real-time acquisition (labs 5.1–5.4): STM32 ADC single → timer-triggered → DMA
- m6 — DSP kernels on the M4 (labs 6.1–6.9): FIR, IIR, FFT/PSD, Goertzel, Kalman, matched filter, LMS, CFAR
- m7 — Robustness & RTOS (labs 7.1–7.3): watchdog/HardFault, FreeRTOS pipeline, capstone
- m8 — Edge ML (labs 8.1–8.6): Pi 5 / Jetson Orin Nano, GPU DSP, ONNX/TensorRT, live camera object detection
- m9 — Host-in-the-loop media (labs 9.1–9.6): streaming DSP over the 921600-baud harness

## Layout

```
labs/lab-<M>-<N>/   one folder per lab: README.md (link to the lab page),
                    notes.md (bench write-up), host/ (simulate-first Python +
                    analysis.ipynb), captures/ (Siglent CSVs, Saleae .sal,
                    DMM/LCR logs); edge/ (C++20 app, device Python, exported
                    models) on M8–9 and on every lab with a "Jetson Orin Nano —
                    detailed procedure" section on the site (M2/M3/M6/M7)
firmware/           STM32 CMake projects (C18) — one per module that has firmware
                    (m2, m3, m5, m6, m7, m9), shared by that module's labs — see
                    firmware/README.md
  shared/           MCU-independent DSP kernels (portable C, no HAL): compiled
                    into every module project AND by the host harness below
  host/             native build + CTest of shared/ — runs on the Mac today,
                    with no ARM toolchain and no board
docs/               reading-map.md (bookshelf → modules), edge-setup.md
                    (Pi 5 / Jetson bench I/O + timing knobs + C++20 CMake
                    template — all modules, not just 8–9)
media/in|out/       shared Module 9 test media
hardware/           breadboard photos, LTspice .asc schematics, datasheets
```

## Build

```bash
uv sync                                  # from the repo root: Python for every lab's host/
cd course2/firmware/host                 # portable kernels — works right now
cmake --preset debug && cmake --build --preset debug && ctest --preset debug
```

STM32 firmware needs `arm-none-eabi-gcc` plus a one-time CubeMX generation per module; both are
covered in [`firmware/README.md`](firmware/README.md), and configuring without the toolchain tells
you exactly what to install.

## Workflow

**Simulate in Python first, always.** Every algorithm is prototyped in
NumPy/SciPy in the lab's `host/` folder (root uv env: `uv sync`, `--group ml`
for Module 8) before any C/C++ is written; the compiled implementation is
validated against that reference, measured on real hardware (DWT cycle counter,
scope, Saleae), and reconciled in the lab's `notes.md`.

Per-lab convention matches the Course 3/4 workspaces: a lab is *done* when its
`notes.md` has every Measured cell filled and `captures/` holds the raw
instrument evidence. All notes/measurements/code are written by hand — the
scaffolding here only removes build friction.
