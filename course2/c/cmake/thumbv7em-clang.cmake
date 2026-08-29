# Toolchain file — Cortex-M4F cross-compilation with Apple clang, no ARM toolchain.
#
# clang targets thumbv7em-none-eabihf directly.  The target is bare-metal and
# has no libc in this sysroot, so this toolchain only ever produces OBJECT files
# (and their disassembly): it never links and never runs.  Real STM32 ELFs are
# linked by Course 3's firmware projects with arm-none-eabi-gcc and a CubeMX
# linker script — that is deliberately not duplicated here.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET thumbv7em-none-eabihf)
set(CMAKE_ASM_COMPILER clang)
set(CMAKE_ASM_COMPILER_TARGET thumbv7em-none-eabihf)

# No linker script, no libc: test-compile a static library, not an executable.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(STM32_CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(CMAKE_C_FLAGS_INIT "${STM32_CPU_FLAGS} -ffreestanding -ffunction-sections -fdata-sections")
set(CMAKE_ASM_FLAGS_INIT "${STM32_CPU_FLAGS}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
