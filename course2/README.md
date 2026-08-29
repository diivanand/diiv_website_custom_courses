# Course 2 — Programming Foundations: Scientific Python, Modern Embedded C & Embedded Rust

Coding workspace for [Course 2](https://www.diiv.io/course2/): language and library fundamentals
in **scientific Python**, **modern embedded C (C17/18)**, and **embedded Rust** — algorithms are
implemented in Python first, then written in C or Rust for three runtime tiers: bare metal (STM32
NUCLEO-L476RG), an RTOS (FreeRTOS / RTIC / Embassy on the same board), and embedded Linux (Jetson
Orin Nano, Raspberry Pi 5). Everything is reasoned about from the Mac: Python in the repo-root uv
project, C under sanitizers and cross-compiled to Thumb-2 for disassembly, Rust built for every
target and run in **QEMU** for the bare-metal tier, and only optionally flashed to the NUCLEO or
built on the Jetson.

The lesson and exercise statements live on the website. This repo holds only what working them
produces: your sources and your `mN/notes.md`.

## Requirements

| Tool | Reaches | Install |
|---|---|---|
| Xcode command-line tools (`clang`, `llvm-objdump`) | Host C builds; Cortex-M4F cross-compilation (**no ARM toolchain needed** — Apple clang targets `thumbv7em-none-eabihf` directly) | `xcode-select --install` |
| `cmake` + `ninja` | The `c/` projects | `brew install cmake ninja` |
| `rustup` + stable toolchain | Everything under `rust/` — `rust-toolchain.toml` pulls the components and targets on first build | `curl https://sh.rustup.rs -sSf \| sh` |
| `cargo-binutils` | `cargo size` / `cargo objdump` / `cargo nm` on any target | `cargo install cargo-binutils --locked` (the `llvm-tools` component comes via `rust-toolchain.toml`) |
| QEMU | Runs the `rust/qemu` crate's binaries — Cortex-M3 board, semihosting, no hardware | `brew install qemu` |
| `probe-rs` (optional) | Flashing the NUCLEO-L476RG and reading `defmt` logs over RTT | `brew tap probe-rs/probe-rs && brew install probe-rs` |
| `arm-none-eabi-gcc` (optional) | Only Course 3's firmware projects link real STM32 ELFs; nothing here needs it | `brew install --cask gcc-arm-embedded` |
| Miri (optional, Module 7) | Undefined-behavior detection in `unsafe` Rust | `rustup component add miri` |
| `uv` (repo root) | Modules 1–3: NumPy/SciPy/Matplotlib/pandas/scikit-learn/pytest; `--group ml` adds torch/torchaudio/torchvision/onnx/onnxruntime | `brew install uv`, then `uv sync` at the repo root |

Linux-tier C is compiled **where it runs**: on the Jetson / Pi over SSH or CLion's remote toolchain
(see `../course3/docs/edge-setup.md`). Linux-tier Rust is `cargo check`ed for `aarch64` on the Mac
and built natively on the board.

## Toolchain check (works on an empty checkout)

```sh
uv sync && uv run pytest course2/python/tests               # repo root: Python stack
uv run python course2/python/src/smoke.py                   # versions + torch device (if --group ml synced)

cd course2/rust
cargo build && cargo test                                   # host + linux crates, on the Mac
cargo run --bin smoke-host                                  # "course2/rust/host OK — aarch64 macos"
cargo check -p linux --target aarch64-unknown-linux-gnu     # Linux tier, compile-only
(cd qemu && cargo run --release --bin smoke-qemu)           # boots QEMU, prints, exits 0
(cd mcu  && cargo build --release --bin smoke-mcu)          # STM32L476 blinky, no board needed to build
cargo size -p mcu --bin smoke-mcu --release --target thumbv7em-none-eabihf -- -A

cd ../c/host  && cmake --preset debug && cmake --build --preset debug && ctest --preset debug
cd ../mcu     && cmake --preset m4    && cmake --build --preset dis
cd ../linux   && cmake --preset release && cmake --build --preset release
```

Every one of those succeeds with zero exercises written — the build systems exist so that none of
your time goes into configuration.

## Modules

Write-ups go in `mN/notes.md`; code goes in the workspaces below (`python/` for M1–M3, `c/` and
`rust/` for M4–M12).

| Part | Notes | Module | Site pages |
|---|---|---|---|
| I · Toolchains and scientific Python | `m0/` | Toolchains, targets, and the availability matrix | [lessons](https://www.diiv.io/course2/lessons-m0.html) · [exercises](https://www.diiv.io/course2/exercises-m0.html) |
| | `m1/` | Scientific Python core: NumPy, SciPy, Matplotlib, and the notebook workflow | [lessons](https://www.diiv.io/course2/lessons-m1.html) · [exercises](https://www.diiv.io/course2/exercises-m1.html) |
| | `m2/` | Processing, statistics, and classical ML libraries; bridging Python to C and Rust | [lessons](https://www.diiv.io/course2/lessons-m2.html) · [exercises](https://www.diiv.io/course2/exercises-m2.html) |
| | `m3/` | PyTorch: tensors, autograd, training, and deployment to the edge | [lessons](https://www.diiv.io/course2/lessons-m3.html) · [exercises](https://www.diiv.io/course2/exercises-m3.html) |
| II · The C subset and the Rust core | `m4/` | The modern C subset: C99 → C17/18 | [lessons](https://www.diiv.io/course2/lessons-m4.html) · [exercises](https://www.diiv.io/course2/exercises-m4.html) |
| | `m5/` | The Rust core for embedded work | [lessons](https://www.diiv.io/course2/lessons-m5.html) · [exercises](https://www.diiv.io/course2/exercises-m5.html) |
| III · Memory and the machine | `m6/` | Memory without a heap | [lessons](https://www.diiv.io/course2/lessons-m6.html) · [exercises](https://www.diiv.io/course2/exercises-m6.html) |
| | `m7/` | Undefined behavior and `unsafe` | [lessons](https://www.diiv.io/course2/lessons-m7.html) · [exercises](https://www.diiv.io/course2/exercises-m7.html) |
| | `m8/` | Talking to hardware | [lessons](https://www.diiv.io/course2/lessons-m8.html) · [exercises](https://www.diiv.io/course2/exercises-m8.html) |
| IV · Concurrency | `m9/` | Interrupts and shared state | [lessons](https://www.diiv.io/course2/lessons-m9.html) · [exercises](https://www.diiv.io/course2/exercises-m9.html) |
| | `m10/` | RTOS and async: FreeRTOS, RTIC, and Embassy | [lessons](https://www.diiv.io/course2/lessons-m10.html) · [exercises](https://www.diiv.io/course2/exercises-m10.html) |
| | `m11/` | Embedded Linux systems programming | [lessons](https://www.diiv.io/course2/lessons-m11.html) · [exercises](https://www.diiv.io/course2/exercises-m11.html) |
| V · Engineering practice | `m12/` | Program structure, testing, interop, and the quality gate + capstone (Python → C17 → Rust) | [lessons](https://www.diiv.io/course2/lessons-m12.html) · [exercises](https://www.diiv.io/course2/exercises-m12.html) |

## Layout — by tier, not by module

A tier is a build configuration; a module is not. So the code trees are organized by tier and an
exercise is a per-tier program named `ex-M-N`. A cross-tier exercise has one entry in every tier it
touches, and `mM/notes.md` holds the comparison.

```
course2/
  README.md
  m0/ … m12/                # notes.md per module
  python/                   # M1–M3 · repo-root uv project · src/ex-M-N.py, notebooks/ex-M-N.ipynb, tests/test_ex_M_N.py
  c/
    cmake/                  # warnings.cmake (the course warning set), exercises.cmake, thumbv7em-clang.cmake
    host/                   # clang · gnu17 · -O0 + ASan/UBSan (preset debug) or -O2 (release) · one exe per src/ex-M-N/
    mcu/                    # clang --target=thumbv7em-none-eabihf · freestanding · objects + disassembly per src/ex-M-N/
    linux/                  # POSIX C · built on the Jetson/Pi (macOS builds the POSIX-common subset)
  rust/
    Cargo.toml              # one workspace; `default-members` = host + linux (the crates that build for the Mac)
    rust-toolchain.toml     # stable + clippy/rustfmt/llvm-tools/rust-src + the three cross targets
    .cargo/config.toml      # runners: thumbv7m → QEMU, thumbv7em → probe-rs; link args for cortex-m-rt / defmt
    host/                   # std · unit tests · Miri · Clippy             · src/bin/ex-M-N.rs
    qemu/                   # no_std · thumbv7m-none-eabi · lm3s6965evb    · src/bin/ex-M-N.rs · own .cargo (default target)
    mcu/                    # no_std · thumbv7em-none-eabihf · STM32L476RG · src/bin/ex-M-N.rs · own .cargo (default target)
    linux/                  # std + nix + gpiod + linux-embedded-hal       · src/bin/ex-M-N.rs
  archive/                  # the previous (A64 assembly) course's worked m0 notes, kept for reference
```

### Python: one script or notebook per exercise

```sh
uv run python course2/python/src/ex-1-3.py     # from the repo root
uv run jupyter lab                             # notebooks in course2/python/notebooks/
uv run pytest course2/python/tests             # test_ex_M_N.py; conftest.py adds src/ to sys.path
```

See `python/README.md`. Every Python exercise ends by saving the reference artifact (`.npy`/`.npz`
+ tolerance) that the C and Rust versions in later modules are checked against.

### C: one directory per exercise

Every `.c` file in `c/<tier>/src/ex-M-N/` compiles into one program named `ex-M-N` (host and
linux) or into objects plus a disassembly listing (mcu). A directory containing any `test_*.c`
is also registered with CTest. There is no per-exercise CMake file to write.

```sh
cd c/host
mkdir -p src/ex-4-2 && $EDITOR src/ex-4-2/main.c
cmake --preset debug && cmake --build --preset debug     # re-globs src/ on every build
./build/debug/ex-4-2
ctest --preset debug                                     # runs every ex-* that has a test_*.c
```

| Project | Presets | Knobs (`-D` at configure time) | Notes |
|---|---|---|---|
| `c/host` | `debug` (-O0, ASan+UBSan), `release` (-O2) | `COURSE2_OPT=0\|1\|2\|3\|s`, `COURSE2_SANITIZE=ON\|OFF` | Where every C experiment that can run on the Mac runs |
| `c/mcu` | `m4` (-O2), `m4-O0`; build preset `dis` = disassemble everything | `COURSE2_OPT` | Targets per exercise: `ex-M-N` (objects), `dis-ex-M-N` → `build/m4/ex-M-N/*.lst` |
| `c/linux` | `release` (-O2), `debug` (-O0, sanitizers) | `COURSE2_OPT`, `COURSE2_SANITIZE` | Links `pthread`; links `libgpiod` when `pkg-config` finds it (`apt install libgpiod-dev` on the board) |

### Rust: one binary per exercise

```sh
cd rust
$EDITOR host/src/bin/ex-5-3.rs   && cargo run --bin ex-5-3                # host
$EDITOR qemu/src/bin/ex-9-2.rs   && (cd qemu && cargo run --bin ex-9-2)   # boots QEMU
$EDITOR mcu/src/bin/ex-8-4.rs    && (cd mcu  && cargo run --release --bin ex-8-4)   # flashes the NUCLEO (probe-rs)
$EDITOR linux/src/bin/ex-11-1.rs && cargo check -p linux --target aarch64-unknown-linux-gnu   # then build on the board
```

`qemu/` and `mcu/` carry their own `.cargo/config.toml` with a `[build] target`, so commands run
from inside those directories pick the right target automatically. From the workspace root the
equivalent is explicit: `cargo run -p qemu --target thumbv7m-none-eabi --bin ex-9-2`. A bare
`cargo build` / `cargo test` / `cargo clippy` at the root covers only the host-target crates
(`default-members`); lint the embedded crates with

```sh
cargo clippy -p qemu --target thumbv7m-none-eabi   --lib --bins -- -D warnings
cargo clippy -p mcu  --target thumbv7em-none-eabihf --lib --bins -- -D warnings
```

(`--all-targets` would try to build a test harness, which does not exist without `std`.)

Lint policy is in each crate's `Cargo.toml` `[lints]`: `unsafe_op_in_unsafe_fn` denied
everywhere, `missing_docs` warned, and in the board crates `clippy::unwrap_used` /
`clippy::expect_used` **denied** — a `Result` is handled, never unwrapped, in code that runs on the
board. The release profile keeps symbols (`debug = 2`) for `probe-rs` and `cargo objdump`, with
`opt-level = "s"`, `lto = true`, `codegen-units = 1`.

Pinned crate set (edition 2024): `cortex-m` 0.7 (`critical-section-single-core`), `cortex-m-rt`
0.7, `cortex-m-semihosting` 0.5, `panic-halt` 1, `embassy-stm32` 0.6 (`stm32l476rg`,
`memory-x`, `time-driver-any`, `exti`, `defmt`), `embassy-executor` 0.10 (`platform-cortex-m`,
`executor-thread`, `defmt`), `embassy-time` 0.5, `embassy-sync` 0.8, `embedded-hal` 1.0,
`heapless` 0.9, `critical-section` 1.2, `static_cell` 2, `defmt` 1, `defmt-rtt` 1, `panic-probe`
1, `nix` 0.31, `gpiod` 0.3, `linux-embedded-hal` 0.5, `libc` 0.2.

## The two cross-target notes

**`c/mcu` never links.** Apple's clang compiles for `thumbv7em-none-eabihf` directly, but that
sysroot has no libc: sources there must be freestanding-safe (`<stdint.h>`, `<stddef.h>`,
`<stdbool.h>`, … — not `<stdio.h>`). Factor the kernel into a file both `c/host` and `c/mcu`
compile, keep the `printf`-using driver in `c/host`, and read the Cortex-M4 code in the `.lst`.
Linking a real STM32 ELF (startup file, CubeMX linker script, newlib-nano) is Course 3's firmware
projects' job and is deliberately not duplicated here.

**`rust/linux` is compile-only on the Mac.** There is no `aarch64-linux` cross linker installed;
`cargo check --target aarch64-unknown-linux-gnu` proves the code compiles for the board and
`cargo build --release` on the Jetson / Pi produces the binary. The Linux-only crates (`nix`
Linux features, `gpiod`, `linux-embedded-hal`) are gated behind `cfg(target_os = "linux")` so the
crate also builds natively on macOS for the POSIX-common subset.

## What is deliberately not here

No exercise solutions and no starter implementations. Every `src/bin/` holds only the `smoke-*`
toolchain check, `python/src/` holds only `smoke.py`, every `c/*/src/` ships empty, and each `mN/notes.md` starts as a skeleton whose
"Observed" cells are filled in only by working the exercises by hand. That is the coursework — the
build system exists so that none of your time goes into configuration.
