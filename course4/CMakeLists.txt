cmake_minimum_required(VERSION 3.28)

project(course4
  DESCRIPTION "Course 4 — Real-Time Rendering & GPU Engineering: lab workspace"
  LANGUAGES CXX)

# ---------------------------------------------------------------------------
# Options — flipped per-preset in CMakePresets.json, overridable at configure.
# ---------------------------------------------------------------------------
option(COURSE4_ENABLE_VULKAN "Build the Vulkan backend + Vulkan labs (needs no SDK to build; needs the LunarG SDK/ICD at runtime)" ON)
option(COURSE4_ENABLE_METAL  "Build the metal-cpp backend (Module 4+; requires third_party/metal-cpp — see docs/setup.md)" OFF)
option(COURSE4_SANITIZE      "Compile with ASan+UBSan (debug preset turns this on)" OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CompilerOptions)   # defines course4_options (warnings, C++20, sanitizers)
include(Dependencies)      # FetchContent: glm, glfw, tracy, benchmark, stb, tinygltf, volk, VMA

add_subdirectory(engine)
add_subdirectory(shaders)
add_subdirectory(labs)

# A one-line build summary so a fresh clone knows what it just configured.
message(STATUS "course4: vulkan=${COURSE4_ENABLE_VULKAN} metal=${COURSE4_ENABLE_METAL} sanitize=${COURSE4_SANITIZE} tracy=${TRACY_ENABLE}")
