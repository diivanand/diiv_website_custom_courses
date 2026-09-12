cmake_minimum_required(VERSION 3.25)
project(course2_rtos C)

# RTOS tier: the FreeRTOS kernel (fetched from source by CMake) on the same
# Cortex-M4F runtime as c/mcu — qemu/startup.c, semihost.c, stm32l4.ld — built
# with arm-none-eabi-gcc and run in QEMU's b-l475e-iot01a machine, where the
# emulated SysTick and NVIC drive the scheduler.  Every src/<ex>/ (a main.c that
# creates tasks and starts the scheduler, plus whatever it needs) becomes
# build/qemu/<ex>.elf with run-<ex>, size-<ex>, dis-<ex>.  Timing inside QEMU is
# about ORDER, not durations; the NUCLEO build (CubeMX, CMSIS-RTOS2) lives in
# course3/firmware/m7-rtos/.
#
#   config/FreeRTOSConfig.h  — the kernel configuration every exercise shares
#                              (1 kHz tick, configASSERT, static + dynamic
#                              allocation, stack-overflow checking).  An
#                              exercise that needs a different configuration
#                              puts its own FreeRTOSConfig.h in its directory;
#                              that copy wins (the exercise dir is searched first).
#   smoke/main.c             — two tasks and the idle hook; proves the tier.
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
  message(FATAL_ERROR "course2/c/rtos builds only with the GNU Arm toolchain: use `cmake --preset qemu`")
endif()

include(../cmake/warnings.cmake)
include(../cmake/qemu-runtime.cmake)

set(COURSE2_OPT "2" CACHE STRING "Optimization level: 0|1|2|3|s|g")
add_compile_options(-O${COURSE2_OPT} -g)

# ---- the kernel ---------------------------------------------------------
set(FREERTOS_KERNEL_TAG "V11.2.0" CACHE STRING "FreeRTOS-Kernel git tag")
set(FREERTOS_PORT "GCC_ARM_CM4F" CACHE STRING "" FORCE)
set(FREERTOS_HEAP "4" CACHE STRING "" FORCE)   # heap_4: coalescing; exercises switch to static allocation

include(FetchContent)
FetchContent_Declare(freertos_kernel
  GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
  GIT_TAG        ${FREERTOS_KERNEL_TAG}
  GIT_SHALLOW    TRUE)

# The kernel's CMake requires an INTERFACE target `freertos_config` that carries
# the FreeRTOSConfig.h include path.  A per-exercise override directory is
# added in course2_rtos_program() ahead of config/.
add_library(freertos_config INTERFACE)
target_include_directories(freertos_config SYSTEM INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/config")
target_compile_definitions(freertos_config INTERFACE projCOVERAGE_TEST=0)

FetchContent_MakeAvailable(freertos_kernel)

# c/shared/ — one kernel, three tiers (the Module 9 capstone driver).
set(COURSE2_SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../shared")
file(GLOB_RECURSE _shared_srcs CONFIGURE_DEPENDS "${COURSE2_SHARED_DIR}/*.c")

add_custom_target(dis COMMENT "Disassemble every exercise")

function(course2_rtos_program name dir)
  file(GLOB _srcs CONFIGURE_DEPENDS "${dir}/*.c")
  course2_add_qemu_program(${name} ${_srcs} ${_shared_srcs})
  # exercise dir first, so a local FreeRTOSConfig.h overrides config/
  target_include_directories(${name}.elf BEFORE PRIVATE "${dir}")
  target_include_directories(${name}.elf PRIVATE "${COURSE2_SHARED_DIR}")
  target_compile_options(${name}.elf PRIVATE ${COURSE2_WARNINGS})
  target_link_libraries(${name}.elf PRIVATE freertos_kernel freertos_kernel_port)
  add_dependencies(dis dis-${name})
endfunction()

course2_rtos_program(smoke-rtos "${CMAKE_CURRENT_SOURCE_DIR}/smoke")

set(_count 0)
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
  course2_rtos_program(${_name} "${_d}")
  message(STATUS "  exercise ${_name}  (targets: ${_name}.elf, run-${_name}, size-${_name}, dis-${_name})")
  math(EXPR _count "${_count} + 1")
endforeach()
if(_count EQUAL 0)
  message(STATUS "  no exercises yet in src/ — create src/ex-7-N/ with a main.c that starts the scheduler")
endif()
message(STATUS "course2/c/rtos: FreeRTOS-Kernel ${FREERTOS_KERNEL_TAG}, port ${FREERTOS_PORT}, heap_${FREERTOS_HEAP}, -O${COURSE2_OPT}")
