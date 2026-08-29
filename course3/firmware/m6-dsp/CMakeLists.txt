cmake_minimum_required(VERSION 3.22)

# Module 6 — real-time DSP: FIR, IIR, FFT, PSD, Goertzel, Kalman, matched filter, LMS, CFAR
# Labs sharing this project: 6.1–6.9
#
# Build:  cmake --preset debug && cmake --build --preset debug
# See ../README.md for the CubeMX generation step this expects.

project(m6-dsp C CXX ASM)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)

stm32_add_firmware(m6-dsp
    CMSIS_DSP        # Module 6 onward: arm_math.h, linked with the FPU flags
)
