cmake_minimum_required(VERSION 3.25)
project(course2_mcu C)

# Bare-metal tier, Mac-side.  Two ways in, chosen by the preset:
#
#   m4 / m4-O0  — Apple clang, --target=thumbv7em-none-eabihf, freestanding:
#                 every src/<ex>/*.c becomes an object and `dis-<ex>` writes
#                 build/<preset>/<ex>/<ex>.lst.  Nothing links; this mode exists
#                 to be READ (what the compiler emitted for the Cortex-M4F).
#
#   qemu        — the GNU Arm Embedded toolchain: every src/<ex>/ is linked with
#                 the runtime in qemu/ (startup.c, semihost.c, stm32l4.ld) into
#                 build/qemu/<ex>.elf, with `run-<ex>` (QEMU b-l475e-iot01a,
#                 semihosting, exit status = main's return), `size-<ex>` and
#                 `dis-<ex>`.  printf works here through newlib-nano; peripherals
#                 QEMU does not emulate (I2C, SPI, ADC, DAC, DMA, TIMx) compile
#                 but are exercised on the NUCLEO through course3/firmware/.
#
# Sources under src/ compiled by BOTH presets must stay freestanding-safe
# (<stdint.h>, <stddef.h>, <stdbool.h> …); <stdio.h> is fine only for code
# that is only ever built by the qemu preset.
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)          # gnu17 — matches Course 3's firmware and the CMSIS headers
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(../cmake/warnings.cmake)

set(COURSE2_OPT "2" CACHE STRING "Optimization level: 0|1|2|3|s|g (default 2 — this tier exists to be read)")
add_compile_options(-O${COURSE2_OPT} -g)

# c/shared/ (recursive) is on every exercise's include path and compiled into
# every program — one kernel, three tiers (the Module 9 capstone driver).
set(COURSE2_SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../shared")
file(GLOB_RECURSE _shared_srcs CONFIGURE_DEPENDS "${COURSE2_SHARED_DIR}/*.c")

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  set(COURSE2_MODE "qemu")
  include(../cmake/qemu-runtime.cmake)
else()
  set(COURSE2_MODE "objects")
  find_program(LLVM_OBJDUMP NAMES llvm-objdump HINTS "$ENV{LLVM_DIR}/bin")
  if(NOT LLVM_OBJDUMP)
    execute_process(COMMAND xcrun --find llvm-objdump OUTPUT_VARIABLE LLVM_OBJDUMP
                    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
  endif()
  if(NOT LLVM_OBJDUMP)
    message(FATAL_ERROR "llvm-objdump not found (install the Xcode command-line tools: xcode-select --install)")
  endif()
endif()

add_custom_target(dis COMMENT "Disassemble every exercise")

# ---------------------------------------------------------------- objects --
function(course2_mcu_objects name srcs)
  add_library(${name} OBJECT ${srcs})
  target_include_directories(${name} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/${name}" "${COURSE2_SHARED_DIR}")
  target_compile_options(${name} PRIVATE ${COURSE2_WARNINGS})
  set(_lst "${CMAKE_CURRENT_BINARY_DIR}/${name}/${name}.lst")
  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${name}")
  add_custom_command(
    OUTPUT "${_lst}"
    COMMAND ${LLVM_OBJDUMP} -d --no-show-raw-insn -S "$<TARGET_OBJECTS:${name}>" > "${_lst}"
    DEPENDS ${name} COMMAND_EXPAND_LISTS
    COMMENT "objdump ${name} -> ${name}.lst" VERBATIM)
  add_custom_target(dis-${name} DEPENDS "${_lst}")
  add_dependencies(dis dis-${name})
endfunction()

# ------------------------------------------------------------------- qemu --
function(course2_mcu_program name srcs)
  course2_add_qemu_program(${name} ${srcs} ${_shared_srcs})
  target_include_directories(${name}.elf PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/${name}" "${COURSE2_SHARED_DIR}")
  target_compile_options(${name}.elf PRIVATE ${COURSE2_WARNINGS})
  add_dependencies(dis dis-${name})
endfunction()

# --------------------------------------------------------------- exercises --
set(_count 0)
if(COURSE2_MODE STREQUAL "qemu")
  # Proves the tier with zero exercises written: `cmake --build --preset smoke-qemu`
  course2_mcu_program(smoke-qemu "${CMAKE_CURRENT_SOURCE_DIR}/qemu/smoke.c")
elseif(_shared_srcs)
  course2_mcu_objects(shared "${_shared_srcs}")
endif()

file(GLOB _dirs LIST_DIRECTORIES true CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*")
foreach(_d IN LISTS _dirs)
  if(NOT IS_DIRECTORY "${_d}")
    continue()
  endif()
  get_filename_component(_name "${_d}" NAME)
  file(GLOB _srcs CONFIGURE_DEPENDS "${_d}/*.c")
  if(NOT _srcs)
    message(STATUS "  ${_name}: no .c files yet — skipped")
    continue()
  endif()
  if(COURSE2_MODE STREQUAL "qemu")
    course2_mcu_program(${_name} "${_srcs}")
    message(STATUS "  exercise ${_name}  (targets: ${_name}.elf, run-${_name}, size-${_name}, dis-${_name})")
  else()
    course2_mcu_objects(${_name} "${_srcs}")
    message(STATUS "  exercise ${_name}  (targets: ${_name}, dis-${_name})")
  endif()
  math(EXPR _count "${_count} + 1")
endforeach()
if(_count EQUAL 0)
  message(STATUS "  no exercises yet in src/ — create src/ex-M-N/ and add .c files")
endif()
message(STATUS "course2/c/mcu: ${COURSE2_MODE} mode via ${CMAKE_C_COMPILER}, -O${COURSE2_OPT}")
