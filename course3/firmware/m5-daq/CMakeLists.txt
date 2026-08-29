cmake_minimum_required(VERSION 3.22)

# Module 5 — ADC acquisition: single, timer-triggered, DMA-circular
# Labs sharing this project: 5.1, 5.2, 5.3, 5.4
#
# Build:  cmake --preset debug && cmake --build --preset debug
# See ../README.md for the CubeMX generation step this expects.

project(m5-daq C CXX ASM)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)

stm32_add_firmware(m5-daq
)
