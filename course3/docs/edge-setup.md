# Edge targets — Pi 5 + Jetson Orin Nano setup

Device-side work lives in each lab's own folder as `labs/lab-<M>-<N>/edge/`. Originally that meant Modules 8–9 only; since the 2026-08-14 Jetson-procedure pass on the site, **any lab with a "Jetson Orin Nano — detailed procedure" section uses an `edge/` folder too** (Modules 2, 3, 6, 7, and 9.1's transport). Everything is prototyped in Python first (`labs/lab-<M>-<N>/host/`, or on-device for GPU-only paths), then ported to **C++20 CMake** where the lab calls for a compiled implementation. The one-time board configuration (packages, groups, header map, timing knobs) is on the course site under *Jetson Orin Nano setup essentials*; this file keeps the repo-side quick reference.

## Bench I/O quick reference (40-pin header)

Both boards are assumed flashed, on the LAN, and reachable over SSH. One-time bench packages/permissions:

```sh
sudo apt install i2c-tools libgpiod-dev gpiod python3-libgpiod rt-tests \
                 build-essential cmake ninja-build
sudo usermod -aG i2c,gpio $USER          # then log out/in once
pip install smbus2 Jetson.GPIO           # (Jetson; Pi: gpiozero/RPi.GPIO-compatible libs)
```

| Thing | Jetson Orin Nano | Pi 5 | Course convention |
|---|---|---|---|
| I²C on pins 3/5 | `/dev/i2c-7` (`i2cdetect -y -r 7`) | `/dev/i2c-1` | verify with `i2cdetect -l`, never assume |
| GPIO | `libgpiod` (find lines via `gpioinfo`); `Jetson.GPIO` BOARD mode | `libgpiod`; `rppal` for the fast mmap path | marker pin = **physical pin 7**, second marker **29**, third **31** |
| UART on pins 8/10 | `/dev/ttyTHS*` (typically `ttyTHS1`) | `/dev/ttyAMA0` (enable in `raspi-config`) | 3.3 V domain, tap-don't-drive |
| Timing runs | `sudo nvpmodel -m 0 && sudo jetson_clocks`; `tegrastats` | `performance` governor | `taskset -c 3 chrt -f 80 <bin>`, `cyclictest -t1 -p 90 -i 100` baseline, record `uname -v` |

## Remote dev loop

Two equally good loops — pick per task:

- **CLion remote toolchain over SSH** (Settings → Build, Execution, Deployment → Toolchains → + Remote Host, point at the board): edit on the Mac, build/run/debug on the device. Same workflow as Course 4's remote RTX box.
- **Terminal**: `rsync`/`git pull` the lab folder, `cmake -B build && cmake --build build -j`, run under `chrt` as above.

## C++20 CMake template

Each lab that gets a compiled implementation carries its own `CMakeLists.txt` inside its `edge/` folder:

```cmake
cmake_minimum_required(VERSION 3.22)
project(lab_9_5_video_pipeline CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenCV REQUIRED)                    # image/video labs
# find_package(CUDAToolkit REQUIRED)             # Jetson: cuFFT etc. → CUDA::cufft
# find_package(ALSA REQUIRED)                    # audio I/O (or PortAudio)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${OpenCV_LIBS})
```

Build on-device: `cmake -B build && cmake --build build -j`.

## Device setup

**Both devices** — system packages for the C++ side, uv for Python:

```sh
sudo apt install build-essential cmake libopencv-dev libasound2-dev portaudio19-dev
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Raspberry Pi 5** (device-side Python, per lab as needed):

```sh
uv venv && uv pip install numpy scipy opencv-python pillow soundfile sounddevice \
    tflite-runtime onnxruntime smbus2
```

**Jetson Orin Nano** — CUDA, cuDNN, and **TensorRT come from JetPack** (not pip). Device-side Python extras:

```sh
uv venv --system-site-packages     # so the JetPack-provided CUDA/TensorRT python bindings are visible
uv pip install numpy scipy opencv-python soundfile cupy-cuda12x pycuda
```

GPU paths: CuPy (`cupyx.scipy.*`) for drop-in NumPy/SciPy on the GPU, cuFFT via CuPy or `CUDA::cufft` from C++, TensorRT for deployed models (ONNX → engine with `trtexec`).

Models exported by the Module 8 training notebooks (`uv sync --group ml`, notebooks in `labs/lab-8-N/host/`) land in the same lab's `edge/` folder (`.onnx` / `.tflite` / TensorRT `.engine`).
