cmake_minimum_required(VERSION 3.22)

# Module 7 — watchdog/HardFault, FreeRTOS pipeline, capstone
# Labs sharing this project: 7.1, 7.2, 7.3
#
# Build:  cmake --preset debug && cmake --build --preset debug
# See ../README.md for the CubeMX generation step this expects.

project(m7-rtos C CXX ASM)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)

stm32_add_firmware(m7-rtos
    CMSIS_DSP        # Module 6 onward: arm_math.h, linked with the FPU flags
)
