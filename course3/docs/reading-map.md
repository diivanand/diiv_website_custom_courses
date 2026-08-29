# Embedded-engineering reading map

The course pages already carry per-lab **Recommended reading** from the DSP/theory shelf (Kuo, Lyons, Bendat & Piersol, Richards, Proakis & Salehi, Tekalp, Zölzer, Gonzalez & Woods, Oppenheim). This map covers the *embedded systems software engineering* shelf — which parts of each book pay off in which modules of this repo.

## The shelf

| Book | Role in this course |
|---|---|
| Yiu, *The Definitive Guide to ARM Cortex-M3 and Cortex-M4 Processors* (3rd ed) | The STM32L476RG's CPU explained: NVIC, exceptions, memory system, FPU, DSP extensions |
| Barry, *Mastering the FreeRTOS Real Time Kernel* (v1.1.0) | The Module 7 RTOS text, and the RTOS-variant sections of Modules 2/5/6 |
| White, *Making Embedded Systems* (2nd ed) | Architecture, peripherals, debugging, watchdogs — the "how to be an embedded engineer" companion |
| Grenning, *Test-Driven Development for Embedded C* | Dual-target testing: run the same C18 DSP kernels on the host against the Python reference |
| Seacord, *Effective C* (2nd ed) | The C17/C18 language reference for all firmware in `firmware/` |
| Harris & Harris, *Digital Design and Computer Architecture, ARM Edition* | What the silicon is doing under the HAL: logic → ARM ISA → microarchitecture → caches |
| Plantz, *Introduction to Computer Organization* (ARM A64) | AArch64 fundamentals for the Pi 5 / Jetson (both are A64 cores) |
| Smith, *Programming with 64-Bit ARM Assembly Language* | Hands-on A64 + NEON SIMD on the Raspberry Pi — reading and beating compiler output |
| Scherz & Monk, *Practical Electronics for Inventors* (4th ed) | The analog/bench companion (PEI) — Modules 0–1 and 4; already cited inline on those lab pages |
| Such, *Embedded AI: Intelligence at the Deep Edge* (No Starch, 2026 — published edition, 13 chapters / 32 projects) | Project-based Module 8 companion, cited for methods only (its own boards and sensors are not on this bench): EDA workflow (Ch 5), IMU preprocessing and the sensor-fusion ladder (Ch 7–8), sensor ML and fault detection (Ch 9), RNN noise suppression and PDM microphones (Ch 10), model quantization (Ch 11), hot-word feature extraction and evaluation (Ch 12), the embedded deep-learning process and CNNs (Ch 4) |
| Szeliski, *Computer Vision: Algorithms and Applications* (2nd ed; free PDF at szeliski.org — 1st-ed PDF in hand covers only classical detectors) | Recognition/object-detection theory for Lab 8.6 (Ch 6) |

## By module

**Modules 0–1, 4 (bench + analog)** — none of this shelf; stay with PEI and the scope/op-amp reading on the lab pages.

**Module 2 — digital timing & interrupts (labs 2.1–2.3)**
- Yiu: the exceptions/interrupts and NVIC material — interrupt entry/exit and latency are exactly what Lab 2.2's jitter histogram measures.
- White: her interrupt and timing coverage (what belongs in an ISR, what doesn't).
- Harris & Harris: sequential logic + microarchitecture chapters as background for what a hardware timer physically is.

**Module 3 — mixed-signal I/O over I²C (labs 3.1–3.5)**
- White: the reading-datasheets / peripheral bring-up material — apply it to the MCP4725 and ADS1115 datasheets before wiring.
- Seacord: integer types and conversions, for correct 12-/16-bit register packing.

**Module 5 — real-time acquisition (labs 5.1–5.4)**
- Yiu: memory system chapter (bus matrix, alignment, memory barriers) — relevant to DMA circular buffers in 5.3.
- Grenning: start dual-targeting here — half-buffer bookkeeping and ring buffers are ideal first host-side unit tests.

**Module 6 — DSP kernels on the M4 (labs 6.1–6.9)**
- Yiu: FPU and DSP-extension/CMSIS-DSP material — single-cycle MAC, SIMD, Q15/Q31 — the "why" behind every fixed-point subsection.
- Grenning: test each kernel off-target against the `host/` Python/SciPy reference before flashing (the repo's simulate-first workflow, formalized).
- Seacord: integer promotion/overflow rules — where fixed-point bugs actually come from.

**Module 7 — robustness & RTOS (labs 7.1–7.3)**
- Barry: task management, queue management, interrupt management (the `FromISR` deferred-handling pattern used throughout the RTOS variants), resource management/mutexes, task notifications; troubleshooting chapter for 7.3.
- Yiu: the fault-exceptions material — decoding the HardFault status registers in Lab 7.1.
- White: watchdog strategy and system-integrity design for 7.1.
- Also backs the *Same STM32: bare-metal vs RTOS* sections in labs 2.2, 5.2, 5.3, and 6.x.

**Modules 8–9 — edge targets (labs 8.1–8.6, 9.1–9.6)**
- Plantz then Smith: A64 assembly literacy for the Pi 5/Jetson — enough to read `objdump`/`perf` output of your C++20 builds; Smith's NEON chapters map directly to vectorizing the 9.4 image convolution.
- Harris & Harris: memory-hierarchy/cache chapter — why tiling and row-major access dominate 9.4/9.5 throughput.
- White: her performance/"doing more with less" material when reconciling the 8.5 benchmark results.
- Such: the per-chapter pairings above (8.2 ← Ch 12, 8.3 ← Ch 10, 8.4 ← Ch 9 #15 + Ch 5 #7 + Ch 7–8, 8.5 ← Ch 11 #19, 8.6 ← Ch 4, 6.6 ← Ch 8 #11–13, 5.4 ← Ch 6 #8) — always for the method, never for the book's hardware; every lab runs on the NUCLEO-L476RG, Pi 5, or Jetson Orin Nano.
- Szeliski (2nd ed) Ch 6: the detection theory — single- vs two-stage detectors, NMS, IoU/mAP — behind the Lab 8.6 TensorRT deployment.

**Everywhere:** Seacord for the C, Grenning for the workflow, White for the architecture instincts.
