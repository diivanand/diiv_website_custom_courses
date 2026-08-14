# Course 3 — Computer Architecture, ARM Assembly & Modern Embedded C

Coding workspace for [Course 3](https://www.diiv.io/course3/). Everything here builds and
runs **natively on an Apple Silicon Mac** — A64 assembly, C, and Cortex-M cross-disassembly. No
board, no `arm-none-eabi` toolchain, nothing to install beyond the Xcode command-line tools.

The lesson and exercise statements live on the website. This repo holds only what working them
produces: your sources and your `notes.md`.

## Requirements

Xcode command-line tools, and nothing else:

```sh
xcode-select --install
```

Verify any module is ready — this needs no source files:

```sh
cd m3 && make check
```

```
module m3 toolchain check
  clang                 Apple clang version 21.0.0 (clang-2100.1.1.101)
  llvm-objdump          /Applications/Xcode.app/.../llvm-objdump
  host target           arm64-apple-darwin25.6.0
  thumb target          thumbv7em-none-eabihf OK
  OK
```

## Modules

| Dir | Module | Site pages |
|---|---|---|
| `m0/` | Toolchain & first program | [lessons](https://www.diiv.io/course3/lessons-m0.html) · [exercises](https://www.diiv.io/course3/exercises-m0.html) |
| `m1/` | Bits, logic, and arithmetic circuits | [lessons](https://www.diiv.io/course3/lessons-m1.html) · [exercises](https://www.diiv.io/course3/exercises-m1.html) |
| `m2/` | ISA & microarchitecture | [lessons](https://www.diiv.io/course3/lessons-m2.html) · [exercises](https://www.diiv.io/course3/exercises-m2.html) |
| `m3/` | A64 essentials | [lessons](https://www.diiv.io/course3/lessons-m3.html) · [exercises](https://www.diiv.io/course3/exercises-m3.html) |
| `m4/` | Functions, the stack, and the C boundary | [lessons](https://www.diiv.io/course3/lessons-m4.html) · [exercises](https://www.diiv.io/course3/exercises-m4.html) |
| `m5/` | Multiply, floating point, and NEON | [lessons](https://www.diiv.io/course3/lessons-m5.html) · [exercises](https://www.diiv.io/course3/exercises-m5.html) |
| `m6/` | The Cortex-M bridge | [lessons](https://www.diiv.io/course3/lessons-m6.html) · [exercises](https://www.diiv.io/course3/exercises-m6.html) |
| `m7/` | Modern C after K&R (C99/C11/C17-18) | [lessons](https://www.diiv.io/course3/lessons-m7.html) · [exercises](https://www.diiv.io/course3/exercises-m7.html) |
| `m8/` | Embedded C in practice | [lessons](https://www.diiv.io/course3/lessons-m8.html) · [exercises](https://www.diiv.io/course3/exercises-m8.html) |

## How a module is laid out

**One directory per exercise** under `src/`. Every `.c` and `.s` file in that directory links into a
single executable named after the directory. That is the whole convention — there is no per-exercise
Makefile to write and no file list to maintain.

```
m4/
  Makefile            # sets MODULE (m7/m8 also default SAN=1), includes ../common.mk
  notes.md            # your predicted-vs-observed write-up
  src/
    ex-4-1/
      main.c          #  -> build/ex-4-1
    ex-4-2/
      driver.c        #  -\
      routine.s       #  -/ both link into build/ex-4-2
```

Mixing C and assembly in one exercise is the normal case from Module 4 onward: write the driver in
C, the routine in `.s`, and they link together automatically.

## Working an exercise

```sh
cd m4
make new NAME=ex-4-2      # creates src/ex-4-2/
# ...write src/ex-4-2/driver.c and src/ex-4-2/routine.s...
make run-ex-4-2           # build and run
make dis-ex-4-2           # disassemble the linked binary (A64)
```

### All targets

| Target | Does |
|---|---|
| `make` | build every exercise in `src/` |
| `make list` | list the exercises it found |
| `make check` | verify the toolchain (works with zero sources) |
| `make new NAME=ex-4-2` | scaffold an empty exercise directory |
| `make run-<ex>` | build and run one exercise |
| `make dis-<ex>` | disassemble it, A64 |
| `make ll-<ex>` | emit LLVM IR (`.ll`) for its C sources |
| `make thumb-<ex>` | cross-compile its C to Cortex-M4 Thumb-2 and disassemble |
| `make clean` | remove `build/` |
| `make help` | the same list, from the shell |

### Knobs

| Knob | Default | Why you'd change it |
|---|---|---|
| `OPT=0\|1\|2\|3\|s` | `0` | Several exercises only show what they're meant to at `-O0` — at `-O2` the compiler folds the very construction under study. Others exist to be read at `-O2`. Switch freely: `make OPT=2 dis-ex-1-3` — changing `OPT=` or `SAN=` rebuilds the module from scratch, so what you disassemble is always what you asked for. |
| `SAN=1` | off (on for m7/m8) | AddressSanitizer + UndefinedBehaviorSanitizer, with `-fno-sanitize-recover` so the first violation aborts. Modules 7–8 default it on; turn it off with `make SAN=0`. |
| `VERBOSE=1` | off | Echo full compiler command lines instead of `CC file.c`. |

## The two cross-target notes

**`make thumb-<ex>` needs no `arm-none-eabi` toolchain.** Apple's clang targets
`thumbv7em-none-eabihf` directly, which is how the "one algorithm, two ARMs" comparison in Module 6
is built. It compiles to an object file and disassembles it — it never links and never runs, because
there is no board.

**It is bare-metal, so there is no libc.** clang supplies `<stdint.h>` and `<stddef.h>`, but
`<stdio.h>` does not exist for that target. Factor the routine you want to compare into its own
`.c` file that includes only the freestanding headers, and keep the `printf`-using driver in a
separate file. `make thumb-<ex>` compiles what it can, skips the rest, and tells you which is which.

## What is deliberately not here

No exercise solutions and no starter implementations. `src/` starts empty in every module, and each
`notes.md` starts as a skeleton whose "Observed" entries are filled in only by working the exercises
by hand (m0's is already worked). That is the coursework — the build system exists so that none of
your time goes into makefiles.
