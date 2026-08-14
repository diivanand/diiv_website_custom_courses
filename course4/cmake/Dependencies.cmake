# All third-party dependencies, fetched by the build and pinned to verified
# tags/commits. Nothing here needs a manual install; the Vulkan *runtime*
# (LunarG SDK / MoltenVK ICD) is the one runtime-only exception — see
# docs/setup.md.

include(FetchContent)

# --- always available -------------------------------------------------------

FetchContent_Declare(glm
  GIT_REPOSITORY https://github.com/g-truc/glm.git
  GIT_TAG 1.0.1 GIT_SHALLOW ON)

# Tracy: TRACY_ENABLE is Tracy's own switch — the `profile` preset turns it ON;
# debug/release compile it out so instrumentation macros cost nothing.
if(NOT DEFINED TRACY_ENABLE)
  set(TRACY_ENABLE OFF CACHE BOOL "Tracy instrumentation" FORCE)
endif()
FetchContent_Declare(tracy
  GIT_REPOSITORY https://github.com/wolfpld/tracy.git
  GIT_TAG v0.11.1 GIT_SHALLOW ON)

set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(BENCHMARK_INSTALL_DOCS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(benchmark
  GIT_REPOSITORY https://github.com/google/benchmark.git
  GIT_TAG v1.9.1 GIT_SHALLOW ON)

FetchContent_Declare(stb
  GIT_REPOSITORY https://github.com/nothings/stb.git
  GIT_TAG 2c980bb59875b0d32144a71867fbdebb2f77cd20)  # pinned master commit

set(TINYGLTF_BUILD_LOADER_EXAMPLE OFF CACHE BOOL "" FORCE)
set(TINYGLTF_INSTALL OFF CACHE BOOL "" FORCE)
set(TINYGLTF_HEADER_ONLY ON CACHE BOOL "" FORCE)
FetchContent_Declare(tinygltf
  GIT_REPOSITORY https://github.com/syoyo/tinygltf.git
  GIT_TAG v2.9.3 GIT_SHALLOW ON)

FetchContent_MakeAvailable(glm tracy benchmark stb tinygltf)

# stb ships no CMake — wrap it in an interface target.
add_library(stb INTERFACE)
target_include_directories(stb SYSTEM INTERFACE ${stb_SOURCE_DIR})

# --- Vulkan stack (COURSE4_ENABLE_VULKAN) -----------------------------------
# Headers + volk + VMA are build-time only: volk dlopens the loader at runtime,
# so this tree configures and builds on a machine with no Vulkan SDK at all.

if(COURSE4_ENABLE_VULKAN)
  FetchContent_Declare(vulkan-headers
    GIT_REPOSITORY https://github.com/KhronosGroup/Vulkan-Headers.git
    GIT_TAG v1.3.290 GIT_SHALLOW ON)

  FetchContent_Declare(volk
    GIT_REPOSITORY https://github.com/zeux/volk.git
    GIT_TAG vulkan-sdk-1.3.290.0 GIT_SHALLOW ON)

  FetchContent_Declare(vma
    GIT_REPOSITORY https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git
    GIT_TAG v3.1.0 GIT_SHALLOW ON)

  set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
  set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
  set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
  set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
  FetchContent_Declare(glfw
    GIT_REPOSITORY https://github.com/glfw/glfw.git
    GIT_TAG 3.4 GIT_SHALLOW ON)

  FetchContent_MakeAvailable(vulkan-headers volk vma glfw)
endif()
