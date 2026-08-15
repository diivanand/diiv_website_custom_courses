# firmware/ — STM32 CMake projects (C18)

One CMake project per module, targeting the **NUCLEO-L476RG** (STM32L476RG, Cortex-M4F, hard FP,
80 MHz). Labs within a module share that module's project — never one project per lab.

| Project | Modules / labs |
|---|---|
| `m2-timing/` | Module 2 — GPIO timing, timer interrupts, UART |
| `m3-mixed/`  | Module 3 — I²C DAC/ADC (MCP4725, ADS1115) |
| `m5-daq/`    | Module 5 — ADC single / timer-triggered / DMA-circular acquisition |
| `m6-dsp/`    | Module 6 — FIR, IIR, FFT, PSD, Goertzel, Kalman, matched filter, LMS, CFAR |
| `m7-rtos/`   | Module 7 — watchdog/HardFault, FreeRTOS pipeline, capstone |
| `m9-media/`  | Module 9 — host-in-the-loop streaming DSP (921600 baud) |

Plus two things that are **not** MCU projects:

| Dir | What |
|---|---|
| `shared/` | MCU-independent kernels — portable C, no HAL, no CMSIS. Compiled into every module project *and* by the host harness. |
| `host/`   | Native build + test of `shared/`. **Works today, no ARM toolchain, no board.** |

## Prerequisites

The ARM toolchain is **not** installed on this machine. Everything else in the repo builds without
it — only the six MCU projects need it:

```sh
brew install --cask gcc-arm-embedded      # Arm's official GNU toolchain
# or
brew install arm-none-eabi-gcc
```

Already have STM32CubeCLT? Point CMake at its copy instead of installing a second one:

```sh
cmake --preset debug -DARM_TOOLCHAIN_DIR=/opt/ST/STM32CubeCLT/GNU-tools-for-STM32/bin
```

Configuring without a toolchain fails immediately with these instructions rather than a wall of
CMake compiler-detection errors.

For flashing: **STM32CubeProgrammer** (`STM32_Programmer_CLI` on PATH) — used by the
`flash-<module>` build target (see *Build and flash* below).

## Start here: `host/` — the part that works right now

The course's rule is *simulate in Python first, then write C*. `shared/` + `host/` is the bridge
between those two: write the kernel once as portable C, test it natively on the Mac under
sanitizers against your NumPy reference, then compile that same unmodified file into the module's
firmware.

```sh
cd host
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

- Every `.c` in `../shared/src/` goes into a `kernels` static library.
- Every `tests/*.c` becomes its own test executable, registered with CTest. No list to maintain —
  add a file, re-configure, it runs.
- **ASan + UBSan are on** in the debug preset. These kernels do buffer arithmetic and fixed-point
  saturation, which is exactly where the bugs are. `--preset release` turns them off for timing.

Both directories start empty, and the build is designed to succeed that way on a fresh clone.

## The MCU projects

### One-time generation with CubeMX

The HAL drivers, startup code, linker script, and `Core/` tree are CubeMX's output, not something
this repo carries.

1. **STM32CubeMX** → New Project → board **NUCLEO-L476RG**.
2. Configure clocks and peripherals per the lab's *Project & environment setup* table on the course
   page (80 MHz system clock throughout).
3. Project Manager → Toolchain/IDE = **CMake** → generate **into the module folder**
   (e.g. `firmware/m5-daq/`).
4. CubeMX writes its own `CMakeLists.txt` (and `CMakePresets.json`) **over** the ones already in
   the module folder. Restore this repo's versions afterwards:
   `git checkout -- CMakeLists.txt CMakePresets.json`. Everything CubeMX generates under `Core/`
   and `Drivers/` is picked up automatically by glob.

You do *not* need to hand-edit the generated files. In particular the usual "CubeMX emits
`CMAKE_C_STANDARD 11`, bump it to 17" chore is already handled centrally in
`cmake/stm32_firmware.cmake`.

### Build and flash

```sh
cd m5-daq
cmake --preset debug            # or: --preset release
cmake --build --preset debug
cmake --build --preset debug --target flash-m5-daq
```

Every build prints a `size` report and the linker's memory-usage summary, and emits `.hex` and
`.bin` next to the `.elf`. A `.map` file is written for every link.

| Preset | Flags |
|---|---|
| `debug` | `-Og -g3` — the default; steps cleanly in a debugger |
| `release` | `-O2 -g` — what you benchmark against with the DWT cycle counter |

(Labs that ask for a literal `-O0` comparison: add a one-off profile/configure passing
`-DCMAKE_C_FLAGS_DEBUG="-O0 -g3"`.)

### Working in CLion

These are plain CMake projects, so CLion opens them directly — no plugin-specific project format:

1. **Open** the module folder (e.g. `m5-daq/`). CLion reads `CMakeLists.txt` + `CMakePresets.json`;
   enable the **debug** and **release** profiles when prompted.
2. **Build/flash** with the normal build action or the `flash-<module>` target (same commands as
   above; add `-DARM_TOOLCHAIN_DIR=…` in the profile's CMake options if you use the CubeCLT
   toolchain copy).
3. **Debug** over the on-board ST-LINK with OpenOCD (`brew install openocd`): *Run → Edit
   Configurations → + → OpenOCD Download & Run*, board config **`board/st_nucleo_l4.cfg`**, target =
   the module executable. Breakpoints, stepping, and register views work as expected.
4. **Board stuck in a watchdog reset loop** (Lab 7.1): connect under reset —
   `STM32_Programmer_CLI -c port=SWD mode=UR` — then reflash.

CubeMX remains the owner of the `.ioc` (regenerate after peripheral changes; your `src/`/`include/`
are untouched). STM32CubeIDE still works if preferred — generate with Toolchain/IDE = STM32CubeIDE
instead — but the repo's presets, `shared/`+`host/` harness, and flash targets assume CMake.

### Where your code goes

```
m6-dsp/
  CMakeLists.txt        # yours, already written — usually never edited
  CMakePresets.json     # debug / release
  Core/  Drivers/       # CubeMX output (generated, not hand-edited)
  src/                  # your module code            <- write here
  include/              # your headers                <- and here
  *.ld                  # CubeMX linker script
```

`src/` and `../shared/src/` are globbed with `CONFIGURE_DEPENDS` (and `include/` is on the include
path), so adding a file and rebuilding is enough — CMake re-runs itself.

## Libraries

- **HAL/LL drivers** — generated per project by CubeMX.
- **CMSIS-DSP** (`arm_math.h`) — from Module 6 on. `m6-dsp`, `m7-rtos`, and `m9-media` already pass
  `CMSIS_DSP` to `stm32_add_firmware()`; **each of the three** needs its own copy of the sources
  under its `Drivers/`:

  ```sh
  for m in m6-dsp m7-rtos m9-media; do
    git clone --depth 1 https://github.com/ARM-software/CMSIS-DSP $m/Drivers/CMSIS-DSP
  done
  ```

  The build defines `ARM_MATH_CM4`, `__FPU_PRESENT=1U`, and `ARM_MATH_LOOPUNROLL`, and compiles with
  the hard-float flags. If the directory is missing you get a one-line error with that clone command.
- **FreeRTOS** (Module 7, and the bare-metal-vs-RTOS comparison labs) — CubeMX Middleware →
  FREERTOS, interface **CMSIS_V2**. Set the HAL timebase to a spare timer — course convention is
  **TIM6** — never SysTick.
- **DWT cycle counter** — the course's benchmarking convention (`DWT->CYCCNT` at 80 MHz).

## What `stm32_add_firmware()` does

`cmake/stm32_firmware.cmake` holds the single helper each module calls, so each of the six
`CMakeLists.txt` files is nothing but `project()` + one `stm32_add_firmware()` call. It sets C18/C++20, globs `Core/ Drivers/ src/ ../shared/src/`, adds the
HAL and CMSIS include paths that exist, defines `USE_HAL_DRIVER` and `STM32L476xx`, finds the
CubeMX linker script, adds `-Wall -Wextra -Wshadow`, and attaches the size report, hex/bin
conversion, and `flash-<module>` target. Optional `CMSIS_DSP` wires in the DSP library.

Each failure mode it can hit — no sources, no linker script, missing CMSIS-DSP — reports what to do
about it rather than failing obscurely.
