# Toolchain file — the GNU Arm Embedded toolchain (arm-none-eabi-gcc) for the
# Course 2 bare-metal and RTOS tiers: real Cortex-M4F ELFs, linked against the
# runtime in c/mcu/qemu/ and run in QEMU (b-l475e-iot01a) or flashed to the
# NUCLEO-L476RG.  Companion of thumbv7em-clang.cmake, which compiles-only.
#
# Discovery order: ARM_TOOLCHAIN_DIR (cache/-D), then PATH, then the two places
# Arm's macOS release lands — a user-space unpack under ~/opt and the .pkg
# installer's /Applications/ArmGNUToolchain — then STM32CubeCLT's bundled copy.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

file(GLOB _arm_candidates
     "$ENV{HOME}/opt/arm-gnu-toolchain-*/bin"
     "/Applications/ArmGNUToolchain/*/arm-none-eabi/bin"
     "/opt/ST/STM32CubeCLT*/GNU-tools-for-STM32/bin")
if(DEFINED ARM_TOOLCHAIN_DIR)
  list(PREPEND _arm_candidates "${ARM_TOOLCHAIN_DIR}" "${ARM_TOOLCHAIN_DIR}/bin")
endif()
find_program(ARM_GCC arm-none-eabi-gcc HINTS ${_arm_candidates})

if(NOT ARM_GCC)
  message(FATAL_ERROR
    "\n"
    "arm-none-eabi-gcc was not found.\n"
    "\n"
    "  Install Arm's GNU toolchain for macOS (arm64) — either\n"
    "    brew install --cask gcc-arm-embedded              # needs sudo for the .pkg\n"
    "  or unpack the .tar.xz / .pkg payload under ~/opt/arm-gnu-toolchain-<ver>/\n"
    "  and re-run.  Or point at a copy:  cmake --preset qemu -DARM_TOOLCHAIN_DIR=/path/to/bin\n"
    "\n"
    "  The m4 / m4-O0 presets (Apple clang, objects + disassembly) do not need it.\n")
endif()

get_filename_component(_arm_bin "${ARM_GCC}" DIRECTORY)
set(_p "${_arm_bin}/arm-none-eabi-")
set(CMAKE_C_COMPILER   "${_p}gcc")
set(CMAKE_ASM_COMPILER "${_p}gcc")
set(CMAKE_OBJCOPY      "${_p}objcopy" CACHE FILEPATH "objcopy")
set(CMAKE_SIZE         "${_p}size"    CACHE FILEPATH "size")
set(CMAKE_OBJDUMP      "${_p}objdump" CACHE FILEPATH "objdump")
set(CMAKE_NM           "${_p}nm"      CACHE FILEPATH "nm")

# A runnable ELF needs the linker script, which is not in play during compiler
# detection — test-compile a static library instead.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(STM32_CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(CMAKE_C_FLAGS_INIT   "${STM32_CPU_FLAGS} -ffunction-sections -fdata-sections -fno-common")
set(CMAKE_ASM_FLAGS_INIT "${STM32_CPU_FLAGS} -x assembler-with-cpp")
set(CMAKE_EXE_LINKER_FLAGS_INIT
    "${STM32_CPU_FLAGS} -nostartfiles -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
