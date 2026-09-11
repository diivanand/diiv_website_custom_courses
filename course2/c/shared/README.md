# c/shared — sources compiled into every C exercise, on every tier

Anything under this directory (recursively) is built into every exercise of `../host`,
`../linux` (as the static library `course2_shared`, linked automatically) and `../mcu`
(as the pseudo-exercise `shared`: objects plus a `dis-shared` listing), with this
directory on the include path. Put here the code that must be the *same file* on three
tiers — the Module 12 capstone's `ads1115/` driver is the intended occupant; a Q15
kernel that `c/host` tests and `c/mcu` disassembles is another. Sources must therefore
be freestanding-safe (`<stdint.h>`, `<stddef.h>`, `<stdbool.h>` — never `<stdio.h>`).
Ships empty on purpose: the contents are the coursework.
