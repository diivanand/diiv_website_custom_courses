cmake_minimum_required(VERSION 3.22)

# Module 2 — GPIO timing, timer interrupts, UART decode
# Labs sharing this project: 2.1, 2.2, 2.3
#
# Build:  cmake --preset debug && cmake --build --preset debug
# See ../README.md for the CubeMX generation step this expects.

project(m2-timing C CXX ASM)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)

stm32_add_firmware(m2-timing
)
