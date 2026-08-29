cmake_minimum_required(VERSION 3.22)

# Native host build of the MCU-independent kernels in ../shared/.
#
# This is the "simulate first, then C" bridge: write a DSP kernel once as
# portable C, test it here on the Mac under sanitizers against your NumPy/SciPy
# reference, then compile the same file into a module's firmware unchanged.
#
# Needs no ARM toolchain and no board.
#
#   cmake --preset debug && cmake --build --preset debug && ctest --preset debug

project(course3-host-kernels C)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

enable_testing()

file(GLOB_RECURSE SHARED_SRC CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/../shared/src/*.c")

# The kernel library. Empty until you write kernels — that is expected.
add_library(kernels STATIC ${SHARED_SRC})
target_include_directories(kernels PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../shared/include")
target_compile_options(kernels PRIVATE -Wall -Wextra -Wshadow -Wconversion)
if(NOT SHARED_SRC)
    # A STATIC library with no sources is a hard CMake error; keep the target
    # valid so `cmake --build` succeeds on a fresh clone.
    target_sources(kernels PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/empty.c")
    message(STATUS "course3/host: ../shared/src/ is empty — kernels library is a placeholder")
endif()

# Sanitizers on by default: these kernels handle buffers and fixed-point
# arithmetic, which is where the bugs live.
option(HOST_SANITIZE "Build with ASan + UBSan" ON)
if(HOST_SANITIZE)
    target_compile_options(kernels PUBLIC -fsanitize=address,undefined -fno-omit-frame-pointer)
    target_link_options(kernels PUBLIC -fsanitize=address,undefined)
endif()

# One test executable per tests/*.c — no list to maintain.
file(GLOB TEST_SRC CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.c")
foreach(_t IN LISTS TEST_SRC)
    get_filename_component(_name "${_t}" NAME_WE)
    add_executable(${_name} "${_t}")
    target_link_libraries(${_name} PRIVATE kernels)
    target_compile_options(${_name} PRIVATE -Wall -Wextra)
    add_test(NAME ${_name} COMMAND ${_name})
endforeach()

if(NOT TEST_SRC)
    message(STATUS "course3/host: tests/ is empty — add tests/test_<kernel>.c and re-configure")
endif()
