# third_party/

Drop-in dependencies that are downloaded manually rather than fetched by CMake.

- `metal-cpp/` — Apple's C++ Metal bindings, distributed as a zip from
  https://developer.apple.com/metal/cpp/. Unzip here so `Metal/Metal.hpp` is at
  `third_party/metal-cpp/Metal/Metal.hpp`, then configure with
  `-DCOURSE4_ENABLE_METAL=ON`. The contents are gitignored; this README keeps
  the directory present on a fresh clone.
