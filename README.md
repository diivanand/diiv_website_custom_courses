# Diiv.io — Custom Course Workspaces

> ## NOTE on AI use — read this first
>
> **No AI writes any solution in this repo.** I have a strong no-AI policy for everything that counts as the actual work: every exercise solution, every line of firmware, DSP, assembly, shader, and analysis code, every measurement, every write-up in a `notes.md`, and every reconciliation of predicted vs. measured. All of that is mine, worked by hand.
>
> **AI helped with exactly two things, both of which are scaffolding rather than substance:**
>
> 1. **The build system and configuration setup** — the Makefiles, `CMakeLists.txt` files, CMake presets and toolchain files, the SwiftPM package, the uv project, and the empty notebook skeletons. In other words, the plumbing that decides *how* code gets compiled and run, never the code itself.
> 2. **These README and setup docs** — this file and the per-course READMEs that explain how to build and run each module.
>
> The whole point of this repo is for me to learn. Having AI generate the code, the analysis, or the reports would completely defeat that purpose. The build scaffolding exists precisely so that none of my time goes into config files and all of it goes into the engineering.
>
> Every `src/` directory ships empty and every "Measured" cell starts as `…`. That is deliberate — it's the coursework, and a green build never means anything has been solved.

Companion repository for the lab-based courses on [diiv.io](https://www.diiv.io) — one top-level folder per course, all peers:

| Folder | Course | What's in it |
|---|---|---|
| [`course2/`](course2/) | [Course 2 — Embedded DSP](https://www.diiv.io/course2/) | 45 bench labs: instruments → mixed-signal I/O → STM32 real-time DSP firmware → edge ML → host-in-the-loop media |
| [`course3/`](course3/) | [Course 3 — Computer Architecture, ARM Assembly & Modern Embedded C](https://www.diiv.io/course3/) | Per-module A64 assembly + modern-C workspaces (Makefiles, sources, notes) |
| [`course4/`](course4/) | [Course 4 — Real-Time Rendering & GPU Engineering](https://www.diiv.io/course4/) | A self-contained C++20/CMake project: Vulkan + Metal engine, Swift Metal apps, CUDA labs — build scaffolding fully set up (see [`course4/README.md`](course4/README.md)) |

**Lab instructions live on the website, not here** — this repo holds what working the labs produces: notes, code, captures, benchmarks, models. Like the site, it's expanded on weekends when I have time, so it may not be complete for a long while. But it's my weekend hobby project when I'm not dealing with work stuff that spills into weeks or family things with my wife (and I guess kids if that happens). My main priorities are my full-time job and my family, but I hope to have this fully complete at some point, enjoy the incremental progress as it updates, and hope it's useful to others.

## Hardware targets

| Target | Used by |
|---|---|
| **Apple Silicon Mac (M-series)** | Course 3 (A64 assembly, host clang/lldb); Course 4 (Metal natively, Vulkan via MoltenVK, Xcode GPU capture) |
| **NUCLEO-L476RG** (STM32L476RG, Cortex-M4F @ 80 MHz) | Course 2 real-time firmware (Modules 2–3, 5–7, 9); Course 3 cross-disassembly target |
| **Raspberry Pi 5** | Course 2 edge Linux target (Modules 8–9) |
| **NVIDIA Jetson Orin Nano** | Course 2 edge GPU (Modules 8–9) |
| **Linux desktop (NVIDIA RTX 4090)** | Course 4 native Vulkan + CUDA + Nsight — driven remotely from the Mac via CLion's SSH toolchain |

Plus the Course 2 bench: PSU, Fluke DMM, LCR meter, Siglent scope, Saleae logic analyzer.

## Build & run — every module, one page

Each course's README has the detail; this is the map. **Everything marked ✅ builds on the Mac with
nothing beyond the Xcode command-line tools and `uv`.**

| What | Where | Command | Works today |
|---|---|---|---|
| Python (all courses) | repo root | `uv sync`, then `uv run jupyter lab` | ✅ |
| Course 3 — any module | `course3/m0` … `m8` | `make check`, then `make run-<ex>` | ✅ |
| Course 4 — C++ / Vulkan | `course4/` | `cmake --preset release && cmake --build --preset release` | ✅ (~100 build steps) |
| Course 4 — Swift / Metal | `course4/metal-swift/` | `swift build` | ✅ |
| Course 2 — portable DSP kernels | `course2/firmware/host/` | `cmake --preset debug && cmake --build --preset debug && ctest --preset debug` | ✅ |
| Course 4 — CUDA | `course4/` | `cmake --preset linux-release` | needs the RTX 4090 box |
| Course 2 — STM32 firmware | `course2/firmware/m*/` | `cmake --preset debug && cmake --build --preset debug` | needs `arm-none-eabi-gcc` + CubeMX generation |

Two things are deliberately *not* buildable on the Mac, and both say so plainly when you try:

- **STM32 firmware** needs `brew install --cask gcc-arm-embedded` plus a one-time CubeMX generation
  per module. Configuring without the toolchain prints the install commands rather than a wall of
  CMake compiler-detection errors. See [`course2/firmware/README.md`](course2/firmware/README.md).
- **CUDA** exists only on the Linux desktop; the Mac presets don't include it.

### First run from a fresh clone

```bash
uv sync                                              # Python, all courses

cd course3/m0 && make check && cd ../..              # assembly/C toolchain check

cd course4 && cmake --preset release \
           && cmake --build --preset release         # fetches deps, ~100 build steps
cd metal-swift && swift build && cd ../..            # Swift/Metal lab apps

cd course2/firmware/host \
  && cmake --preset debug && cmake --build --preset debug   # portable-kernel harness
```

Every one of those succeeds on an empty checkout — the build systems are written to work before any
exercise exists, so a green build never means "you already wrote something."

## Python: one uv project for the whole repo

A single [uv](https://docs.astral.sh/uv/) project at the repo root, pinned to **Python 3.13** (`.python-version`), shared by every course's Python work — Course 2's simulate-first prototypes and analysis notebooks, and Course 4's CUDA-Python track:

```bash
uv sync                 # core: numpy/scipy/matplotlib/jupyter/pyserial/…
uv sync --group ml      # Course 2 Module 8: torch/onnx/onnxruntime/tensorflow
uv run jupyter lab
```

Device-side Python on the Pi/Jetson (CuPy, TensorRT, tflite-runtime, smbus2) is platform-specific — see `course2/docs/edge-setup.md`; Course 4's Linux-desktop CUDA group (`numba`, `cupy-cuda12x`) is described in `course4/docs/setup.md`.

## Layout

```
diiv_website_custom_courses/
  README.md
  pyproject.toml              # shared uv project (all courses' Python work)
  course2/                    # ── Embedded DSP labs ──────────────────────────
    docs/                     #   reading-map.md, edge-setup.md (Pi 5 / Jetson + C++20 CMake template)
    firmware/                 #   STM32 CMake projects (C18), one per module with firmware (m2,m3,m5–m7,m9)
    labs/lab-<M>-<N>/         #   one folder per lab: notes.md, host/, captures/, edge/ (M8–9)
    media/in|out/             #   Module 9 host-in-the-loop test media
    hardware/                 #   breadboard photos, LTspice .asc schematics, datasheets
  course3/                    # ── Computer architecture & ARM assembly ───────
    m0/ … m8/                 #   one folder per module: Makefile, src/<exercise>/ (.c/.s), notes.md
  course4/                    # ── Rendering & GPU engineering ────────────────
    CMakeLists.txt            #   self-contained C++20 CMake project (presets: debug/release/profile/linux-*)
    engine/  shaders/  cuda/  #   the growing engine, GLSL/MSL shaders, CUDA C++ + python/
    metal-swift/              #   SwiftPM package for the Swift/Metal lab apps
    labs/lab-<M>-<N>/         #   notes.md, captures/, benchmarks/, src/ (C++ labs)
```

**Naming convention (all courses):** everything a lab produces lives in its folder — e.g. `course2/labs/lab-2-1/notes.md`, `course4/labs/lab-5-2/captures/`. A lab is **done** when its `notes.md` has every Measured cell filled and its `captures/` folder holds the raw evidence.

## Course 2 toolchains

- **STM32 firmware** — CMake projects targeting **C18** (`-std=gnu17`; arm-none-eabi-gcc has full C17/C18 support). One project per module that has firmware — m2, m3, m5, m6, m7, m9 — shared by that module’s labs, generated via STM32CubeMX's CMake toolchain option with HAL/LL drivers; CMSIS-DSP for the math, FreeRTOS for Module 7. See `course2/firmware/README.md`.
- **Pi 5 / Jetson C++** — CMake projects targeting **C++20** (OpenCV, ALSA/PortAudio, and on the Jetson CUDA/cuFFT/TensorRT). See `course2/docs/edge-setup.md`.
- **Workflow: simulate in Python first.** Every algorithm is prototyped and verified in Python (NumPy/SciPy, Jupyter) in the lab's `host/` folder **before** any C or C++ is written; the compiled implementation is then validated against the Python reference, measured on real hardware, and reconciled in the lab's `notes.md`.

## Math in write-ups

Bench notes and reports use standard LaTeX math in Markdown — `$f_c = \frac{1}{2\pi RC}$` inline, `$$ … $$` display. GitHub renders this natively (MathJax), and Jupyter notebooks render it in Markdown cells out of the box. For a PDF report, export with `uv run jupyter-nbconvert --to pdf <notebook>` (note the hyphen — `uv run jupyter nbconvert` does not resolve the subcommand) or `pandoc --katex` (Markdown notes).
