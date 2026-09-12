# Course 2 — Modern Embedded C: C17/18 for Bare Metal, RTOS, and Embedded Linux

Coding workspace for [Course 2](https://www.diiv.io/course2/): modern C — C99 plus the useful
parts of C11, pinned as **C17/18** (`-std=gnu17`) — on three runtime tiers: bare metal (STM32
NUCLEO-L476RG, Cortex-M4F), FreeRTOS on the same board, and embedded Linux (Jetson Orin Nano,
Raspberry Pi 5). Everything is reasoned about from the Mac: host builds under the sanitizers,
Cortex-M4F objects read as disassembly, and real ELFs — including the FreeRTOS kernel — **run in
QEMU** (`b-l475e-iot01a`, an STM32L4 board, semihosting). Flashing the NUCLEO and building on the
Jetson are the optional last rungs.

The lesson and exercise statements live on the website. This repo holds only what working them
produces: your sources and your `mN/notes.md`.

## Requirements

| Tool | Reaches | Install |
|---|---|---|
| Xcode command-line tools (`clang`, `llvm-objdump`) | Host C builds under ASan/UBSan; Cortex-M4F cross-compilation to objects (Apple clang targets `thumbv7em-none-eabihf` directly) | `xcode-select --install` |
| `cmake` + `ninja` | Every project under `c/` | `brew install cmake ninja` |
| GNU Arm Embedded toolchain (`arm-none-eabi-gcc`) | Linking real Cortex-M4F ELFs for the `qemu` presets of `c/mcu` and `c/rtos`; Course 3's firmware projects use the same toolchain | `brew install --cask gcc-arm-embedded` (the .pkg needs sudo), **or** unpack Arm's macOS arm64 `.tar.xz` / `.pkg` payload under `~/opt/arm-gnu-toolchain-<ver>/` — the CMake toolchain file searches `~/opt/arm-gnu-toolchain-*/bin`, `/Applications/ArmGNUToolchain/*/arm-none-eabi/bin`, and `PATH` |
| QEMU (`qemu-system-arm`) | Runs the bare-metal and FreeRTOS ELFs — no hardware needed | `brew install qemu` |
| `cppcheck`, LLVM's `clang-tidy` / `scan-build` (optional, Modules 4 and 9) | Static analysis on the host | `brew install cppcheck`, `brew install llvm` |
| `arm-none-eabi-gdb` (optional) | Source-level debugging of a QEMU run (`-s -S`) | ships with the toolchain |

Linux-tier C is compiled **where it runs**: on the Jetson / Pi over SSH or CLion's remote toolchain
(see `../course3/docs/edge-setup.md`). The Linux project also configures on the Mac so the
POSIX-common subset can be iterated on locally.

## Toolchain check (works on an empty checkout)

```sh
cd course2/c/host  && cmake --preset debug   && cmake --build --preset debug && ctest --preset debug
cd ../mcu          && cmake --preset m4      && cmake --build --preset dis          # Cortex-M4F objects + .lst listings (Apple clang)
cd ../mcu          && cmake --preset qemu    && cmake --build --preset smoke-qemu   # links smoke-qemu.elf, boots it in QEMU, prints, exits 0
cd ../rtos         && cmake --preset qemu    && cmake --build --preset smoke-rtos   # fetches FreeRTOS-Kernel, boots two tasks in QEMU
cd ../linux        && cmake --preset release && cmake --build --preset release      # POSIX subset on the Mac; full build on the board
```

Every one of those succeeds with zero exercises written — the build systems exist so that none of
your time goes into configuration.

## Modules

Write-ups go in `mN/notes.md`; code goes in the tier workspaces under `c/`.

| Part | Notes | Module | Site pages |
|---|---|---|---|
| I · The language | `m0/` | Toolchains, targets, and the availability matrix | [lessons](https://www.diiv.io/course2/lessons-m0.html) · [exercises](https://www.diiv.io/course2/exercises-m0.html) |
| | `m1/` | The modern C subset I: dialect, types, integers, expressions, control flow | [lessons](https://www.diiv.io/course2/lessons-m1.html) · [exercises](https://www.diiv.io/course2/exercises-m1.html) |
| | `m2/` | The modern C subset II: initialization, functions, arrays, structs, compile-time contracts, preprocessor | [lessons](https://www.diiv.io/course2/lessons-m2.html) · [exercises](https://www.diiv.io/course2/exercises-m2.html) |
| II · Memory and the machine | `m3/` | Memory without a heap | [lessons](https://www.diiv.io/course2/lessons-m3.html) · [exercises](https://www.diiv.io/course2/exercises-m3.html) |
| | `m4/` | Undefined behavior and the optimizer | [lessons](https://www.diiv.io/course2/lessons-m4.html) · [exercises](https://www.diiv.io/course2/exercises-m4.html) |
| | `m5/` | Talking to hardware | [lessons](https://www.diiv.io/course2/lessons-m5.html) · [exercises](https://www.diiv.io/course2/exercises-m5.html) |
| III · Concurrency and runtimes | `m6/` | Interrupts and shared state | [lessons](https://www.diiv.io/course2/lessons-m6.html) · [exercises](https://www.diiv.io/course2/exercises-m6.html) |
| | `m7/` | FreeRTOS: tasks, queues, and time on the microcontroller | [lessons](https://www.diiv.io/course2/lessons-m7.html) · [exercises](https://www.diiv.io/course2/exercises-m7.html) |
| | `m8/` | Embedded Linux systems programming | [lessons](https://www.diiv.io/course2/lessons-m8.html) · [exercises](https://www.diiv.io/course2/exercises-m8.html) |
| IV · Engineering practice | `m9/` | Program structure, testing, and the quality gate + the capstone (the ADS1115 driver on three tiers) | [lessons](https://www.diiv.io/course2/lessons-m9.html) · [exercises](https://www.diiv.io/course2/exercises-m9.html) |

## Layout — by tier, not by module

A tier is a build configuration; a module is not. So the code trees are organized by tier and an
exercise is a per-tier program named `ex-M-N`. A cross-tier exercise has one entry in every tier it
touches; code that must be *the same file* on every tier goes in `c/shared/`.

```
course2/
  m0/ … m9/                 # notes.md per module (setup notes, predicted vs observed, reconciliation)
  c/
    cmake/                  # shared: warnings.cmake, exercises.cmake (host/linux exercise glob + Unity),
                            #   thumbv7em-clang.cmake (objects only), arm-none-eabi-gcc.cmake (real ELFs),
                            #   qemu-runtime.cmake + run-qemu.sh (link with the runtime, run in QEMU)
    shared/                 # sources compiled into EVERY exercise on every tier (the M9 capstone driver)
    host/                   # Apple clang, gnu17; presets debug (-O0 ASan+UBSan) / release (-O2)
      src/ex-M-N/*.c        #   one executable per directory; test_*.c ⇒ CTest + Unity linked
    mcu/                    # bare metal
      qemu/                 #   the runtime: startup.c, semihost.c/.h, stm32l4.ld, smoke.c
      src/ex-M-N/*.c        #   preset m4/m4-O0: objects + dis-<ex> listings (Apple clang)
                            #   preset qemu: <ex>.elf + run-<ex> / size-<ex> / dis-<ex> (arm-none-eabi-gcc)
    rtos/                   # FreeRTOS-Kernel (FetchContent, port GCC_ARM_CM4F) on the same runtime
      config/FreeRTOSConfig.h   # shared kernel configuration; an exercise may carry its own copy
      smoke/main.c          #   two tasks + idle hook — proves the tier
      src/ex-7-N/*.c        #   a main.c that creates tasks and starts the scheduler; run-<ex> in QEMU
    linux/                  # POSIX, gnu17, _GNU_SOURCE, pthreads, libgpiod via pkg-config when present
      src/ex-M-N/*.c        #   built on the Jetson / Pi (presets release / debug); POSIX-common subset on the Mac
```

### What QEMU emulates, and what it does not

The `b-l475e-iot01a` machine is an STM32L4 (STM32L475VG): the same Cortex-M4F core, flash and SRAM
map, SysTick, NVIC, EXTI, SYSCFG, RCC, USART, and GPIO register blocks as the NUCLEO's L476RG.
**I²C, SPI, ADC, DAC, DMA, and the general-purpose timers are not emulated** — code touching them
compiles for the target and is exercised on the NUCLEO through `../course3/firmware/`, or against a
fake. Semihosting console output comes out on QEMU's **stderr**; a program's return value from
`main` becomes QEMU's exit status, so `run-<ex>` fails when `main` returns non-zero. Inside QEMU,
tick durations are not wall-clock — reason about **order** there and measure durations on the board.

## Conventions

- **Dialect:** `-std=gnu17`, the course warning set (`c/cmake/warnings.cmake`) on every tier;
  material beyond C17/18 is not used.
- **Freestanding-safe** sources under `c/mcu/src/` and `c/shared/` (`<stdint.h>`, `<stddef.h>`,
  `<stdbool.h>`, `<string.h>` …); `<stdio.h>` only in code that is only ever built by a `qemu` preset,
  where newlib-nano supplies `printf` over semihosting.
- **Predicted before observed.** Every exercise page has a predicted-vs-observed table; the
  prediction is written in `notes.md` before the build runs.
- **Nothing here is a solution.** All `src/` directories ship empty by design.
