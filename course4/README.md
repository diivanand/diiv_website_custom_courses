# Course 4 — Real-Time Rendering & GPU Engineering: lab workspace

Code workspace for [Course 4 on diiv.io](https://www.diiv.io/course4/) — modern
C++20/CMake, Vulkan + Metal, CUDA, one folder per lab. The build system is fully
set up: clone, configure a preset, build, and every stub target compiles — the
only thing left to write is the code the labs are about.

## Quick start (Mac)

```bash
cmake --preset release          # fetches all pinned deps on first configure
cmake --build --preset release  # builds engine + all lab stubs (+ shaders, once glslc is installed)
./build/release/labs/lab-0-1/lab_0_1   # prints "build OK"
```

Presets: `debug` (ASan+UBSan), `release`, `profile` (Tracy on), and
`linux-release` / `linux-profile` (the Linux/4090 box: adds the Module 1 CUDA labs, arch 89).
The Metal/Swift lab apps build separately: `cd metal-swift && swift build`
(open the folder in Xcode for GPU capture). The metal-cpp backend (Module 4+)
needs a one-time download — see `docs/setup.md`.

## Layout

```
engine/          core/ vulkan/ metal/ — the C++20 engine, grown lab by lab
labs/lab-M-N/    notes.md, captures/, benchmarks/ (results), and (where C++)
                 src/ + target; lab-0-2 also has bench/ for benchmark sources
shaders/         glsl/ (glslc → SPIR-V via the compile_shaders target), msl/
metal-swift/     SwiftPM package: the Module 0/2/3 Metal apps (Lab04 … Lab34)
cuda/            Module 1 CUDA C++ labs + python/ (Numba/CuPy, root uv env)
assets/          gitignored downloads (sources recorded in docs/setup.md)
docs/            setup notes (SDKs, metal-cpp, the Linux/4090 box, asset sources)
third_party/     metal-cpp lands here (gitignored contents)
```

Per-lab convention matches the Course 2/3 workspaces: a lab is *done* when its
`notes.md` has every Measured cell filled and `captures/` holds the profiler
evidence. All notes/measurements/code are written by hand — the scaffolding here
only removes build friction.
