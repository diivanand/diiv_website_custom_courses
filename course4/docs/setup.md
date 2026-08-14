# Course 4 setup notes

One-time environment steps per platform. Everything else is fetched by CMake.

## Mac (primary)

- **Toolchain:** `brew install cmake ninja`; full **Xcode** (Metal GPU capture
  needs it; command-line tools alone are not enough).
- **Vulkan runtime:** install the **LunarG Vulkan SDK** for macOS (MoltenVK ICD,
  validation layers, `glslc`, `vulkaninfo`). Source its `setup-env.sh` from the
  shell profile so `VULKAN_SDK` is set and `glslc` is on the PATH — the
  `compile_shaders` target appears automatically the next time you re-run the
  configure step (`cmake --preset …`) with `glslc` on the PATH.
  Sanity check: `vulkaninfo --summary` shows a MoltenVK-backed device.
- **metal-cpp (Module 4+):** download the metal-cpp zip from Apple's developer
  site (developer.apple.com/metal/cpp), unzip into `third_party/metal-cpp/`
  (so `third_party/metal-cpp/Metal/Metal.hpp` exists), then configure with
  `-DCOURSE4_ENABLE_METAL=ON`.
- **Tracy server:** build or download the Tracy profiler UI once (matching
  v0.11.x); captures land in each lab's `captures/`.

## Linux desktop (NVIDIA GeForce RTX 4090)

- **NVIDIA driver + CUDA Toolkit** (nvcc, Nsight Systems, Nsight Compute);
  power/thermals via `nvidia-smi` (`nvidia-smi dmon`, or
  `--query-gpu=power.draw,temperature.gpu`).
- **Vulkan:** `vulkan-tools` / SDK pieces via apt; `vulkaninfo --summary` should
  show the 4090 (discrete Ada Lovelace GPU).
- Configure with the `linux-release` / `linux-profile` presets
  (`CMAKE_CUDA_ARCHITECTURES=89` is pinned there).
- **RenderDoc:** install the Linux build for Vulkan frame debugging (Module 6).
- **Python track:** from the repo root, `uv add --group cuda numba cupy-cuda12x`
  once, then `uv run --group cuda python course4/cuda/python/lab_1_1.py`.

### Remote development from the Mac (CLion)

The working setup: code on the Mac laptop, build/run/debug on this box.
CLion's **remote toolchain** (Settings → Build, Execution, Deployment →
Toolchains → Remote Host over SSH) syncs the source and drives CMake on the
Linux machine; the checked-in `CMakePresets.json` works unchanged — pick the
`linux-*` presets in the CMake profile. GUI Vulkan labs render on the box's
display (or over X forwarding for quick checks); profiling runs (Nsight,
RenderDoc) happen on the box itself, with reports/captures synced back into
the lab's `captures/` folder.

## Asset sources (grows as labs need them)

| First needed | Asset | Source |
|---|---|---|
| Lab 2.4 | test textures (checkerboard, photo) | … record when downloaded |
| Lab 2.5 | glTF sample models | Khronos glTF-Sample-Assets repo |
| Lab 3.3 | HDR environment map(s) | … record when downloaded |
| Lab 5.3 | terrain heightmap(s) | … record when downloaded |
| Lab 5.5 | pretrained 3D Gaussian Splatting `.ply` scene | Kerbl et al. 2023 reference release |
