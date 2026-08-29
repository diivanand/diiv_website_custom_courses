cmake_minimum_required(VERSION 3.22)

# Module 3 — I²C mixed-signal: MCP4725 DAC, ADS1115 ADC
# Labs sharing this project: 3.1, 3.2, 3.3, 3.4, 3.5
#
# Build:  cmake --preset debug && cmake --build --preset debug
# See ../README.md for the CubeMX generation step this expects.

project(m3-mixed C CXX ASM)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)

stm32_add_firmware(m3-mixed
)
