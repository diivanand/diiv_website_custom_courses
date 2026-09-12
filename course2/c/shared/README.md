# c/shared — sources compiled into every C exercise, on every tier

Anything under this directory (recursively) is built into every exercise of `../host` and
`../linux` (as the static library `course2_shared`, linked automatically), `../mcu` (compiled
into every `qemu`-preset ELF; as the pseudo-exercise `shared` with a `dis-shared` listing under
the `m4` presets) and `../rtos` (compiled into every ELF), with this directory on the include
path. Put here the code that must be the *same file* on every tier — the Module 9 capstone's
`ads1115/` driver (`ads1115.h`/`ads1115.c` over an injected I²C transport) is the intended
occupant; a Q15 kernel that `c/host` tests and `c/mcu` disassembles is another. Sources must
therefore be freestanding-safe (`<stdint.h>`, `<stddef.h>`, `<stdbool.h>`, `<string.h>` — never
`<stdio.h>`) and heap-free. Ships empty on purpose: the contents are the coursework.
