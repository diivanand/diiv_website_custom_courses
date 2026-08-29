cmake_minimum_required(VERSION 3.22)

# Module 9 — host-in-the-loop streaming DSP (921600 baud)
# Labs sharing this project: 9.1–9.6
#
# Build:  cmake --preset debug && cmake --build --preset debug
# See ../README.md for the CubeMX generation step this expects.

project(m9-media C CXX ASM)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)

stm32_add_firmware(m9-media
    CMSIS_DSP        # Module 6 onward: arm_math.h, linked with the FPU flags
)
