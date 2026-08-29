# Toolchain file — STM32L476RG (Cortex-M4F, single-precision hard FP), C18.
#
# Used by every module project:
#   cmake --preset debug        (the presets point CMAKE_TOOLCHAIN_FILE here)
#
# If arm-none-eabi-gcc is not installed this fails immediately with install
# instructions, rather than 40 lines of CMake compiler-detection noise.

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# --------------------------------------------------------------- discovery --
# Honour ARM_TOOLCHAIN_DIR if the owner installed the toolchain somewhere the
# PATH does not cover (e.g. the ST-bundled copy inside STM32CubeCLT).
if(DEFINED ARM_TOOLCHAIN_DIR)
  set(_arm_hint HINTS "${ARM_TOOLCHAIN_DIR}" "${ARM_TOOLCHAIN_DIR}/bin" NO_DEFAULT_PATH)
else()
  set(_arm_hint)
endif()

find_program(ARM_GCC arm-none-eabi-gcc ${_arm_hint})

if(NOT ARM_GCC)
  message(FATAL_ERROR
    "\n"
    "arm-none-eabi-gcc was not found on PATH.\n"
    "\n"
    "  Install it with one of:\n"
    "    brew install --cask gcc-arm-embedded          # Arm's official GNU toolchain\n"
    "    brew install arm-none-eabi-gcc                # Homebrew formula\n"
    "  or install STM32CubeCLT (ships its own copy) and re-run with:\n"
    "    cmake --preset debug -DARM_TOOLCHAIN_DIR=/opt/ST/STM32CubeCLT/GNU-tools-for-STM32/bin\n"
    "\n"
    "  Nothing else in this repo needs it: Course 2, Course 4, and the Python\n"
    "  host work all build without it.  See firmware/README.md.\n")
endif()

get_filename_component(_arm_bin "${ARM_GCC}" DIRECTORY)
set(_p "${_arm_bin}/arm-none-eabi-")

set(CMAKE_C_COMPILER   "${_p}gcc")
set(CMAKE_CXX_COMPILER "${_p}g++")
set(CMAKE_ASM_COMPILER "${_p}gcc")
set(CMAKE_OBJCOPY      "${_p}objcopy" CACHE FILEPATH "objcopy")
set(CMAKE_SIZE         "${_p}size"    CACHE FILEPATH "size")
set(CMAKE_OBJDUMP      "${_p}objdump" CACHE FILEPATH "objdump")

# A runnable ELF needs the linker script, which is not in play during compiler
# detection — test-compile a static library instead.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ------------------------------------------------------------------- flags --
set(STM32_CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")

set(CMAKE_C_FLAGS_INIT   "${STM32_CPU_FLAGS} -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS_INIT "${STM32_CPU_FLAGS} -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti")
set(CMAKE_ASM_FLAGS_INIT "${STM32_CPU_FLAGS} -x assembler-with-cpp")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${STM32_CPU_FLAGS} -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
