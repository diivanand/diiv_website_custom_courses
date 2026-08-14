# stm32_firmware.cmake — the one helper every module project uses.
#
#   include(${CMAKE_CURRENT_LIST_DIR}/../cmake/stm32_firmware.cmake)
#   stm32_add_firmware(m6-dsp)
#
# It collects the module's sources, applies the course-wide settings (C18, the
# Cortex-M4F flags, CMSIS-DSP when asked), links against the CubeMX-generated
# linker script, and emits .hex/.bin plus a size report after every build.

include_guard(GLOBAL)

# C18 everywhere.  CubeMX writes CMAKE_C_STANDARD 11; this is the course's
# override, applied centrally so no generated file needs hand-editing.
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ---------------------------------------------------------------------------
# stm32_add_firmware(<target>
#     [SOURCES <extra sources>...]
#     [INCLUDES <extra include dirs>...]
#     [DEFINES <extra -D>...]
#     [CMSIS_DSP]                # link CMSIS-DSP (Module 6 onward)
#     [LINKER_SCRIPT <path>]     # default: the one CubeMX generated
# )
function(stm32_add_firmware TARGET)
  cmake_parse_arguments(ARG "CMSIS_DSP" "LINKER_SCRIPT" "SOURCES;INCLUDES;DEFINES" ${ARGN})

  # --- sources ------------------------------------------------------------
  # Core/ and Drivers/ are CubeMX's output; src/ and include/ are yours.
  # A CMSIS-DSP clone lives under Drivers/ too — keep it out of this sweep
  # (it is added separately, and only when CMSIS_DSP is requested).
  file(GLOB_RECURSE _cube_c   CONFIGURE_DEPENDS "Core/*.c" "Drivers/*.c")
  list(FILTER _cube_c EXCLUDE REGEX "/CMSIS-DSP/")
  # Startup .s sits in Core/ or at the project root; a bare recursive "*.s"
  # would also sweep build/ and Drivers/, so root stays non-recursive.
  file(GLOB_RECURSE _cube_asm CONFIGURE_DEPENDS "Core/*.s")
  file(GLOB _root_asm CONFIGURE_DEPENDS "*.s")
  list(APPEND _cube_asm ${_root_asm})
  file(GLOB_RECURSE _own_c    CONFIGURE_DEPENDS "src/*.c")

  # ../shared/ holds MCU-independent kernels (no HAL, no CMSIS): the same .c
  # files the host harness compiles and tests natively.  Write the algorithm
  # once, test it on the Mac, run it here.
  file(GLOB_RECURSE _shared_c CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/../shared/src/*.c")

  set(_srcs ${_cube_c} ${_cube_asm} ${_own_c} ${_shared_c} ${ARG_SOURCES})

  if(NOT _srcs)
    message(FATAL_ERROR
      "\n[${TARGET}] no sources found.\n"
      "  This module has not been generated yet.  Run STM32CubeMX, choose the\n"
      "  NUCLEO-L476RG board, set Toolchain/IDE = CMake, and generate into:\n"
      "    ${CMAKE_CURRENT_SOURCE_DIR}\n"
      "  Then put your own code in src/ and re-configure.\n"
      "  Full walkthrough: firmware/README.md\n")
  endif()

  add_executable(${TARGET} ${_srcs})

  # --- includes -----------------------------------------------------------
  target_include_directories(${TARGET} PRIVATE
    Core/Inc
    include
    "${CMAKE_CURRENT_SOURCE_DIR}/../shared/include"
    ${ARG_INCLUDES})
  foreach(_d IN ITEMS
      Drivers/STM32L4xx_HAL_Driver/Inc
      Drivers/STM32L4xx_HAL_Driver/Inc/Legacy
      Drivers/CMSIS/Device/ST/STM32L4xx/Include
      Drivers/CMSIS/Include)
    if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_d}")
      target_include_directories(${TARGET} PRIVATE ${_d})
    endif()
  endforeach()

  target_compile_definitions(${TARGET} PRIVATE
    USE_HAL_DRIVER
    STM32L476xx
    ${ARG_DEFINES})

  target_compile_options(${TARGET} PRIVATE
    -Wall -Wextra -Wshadow
    $<$<CONFIG:Debug>:-Og -g3>
    $<$<CONFIG:Release>:-O2 -g>)

  # --- CMSIS-DSP (Module 6 onward) ---------------------------------------
  if(ARG_CMSIS_DSP)
    set(_dsp "${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS-DSP")
    if(NOT IS_DIRECTORY "${_dsp}")
      message(FATAL_ERROR
        "\n[${TARGET}] CMSIS_DSP requested but Drivers/CMSIS-DSP/ is missing.\n"
        "  git clone --depth 1 https://github.com/ARM-software/CMSIS-DSP \\\n"
        "      ${_dsp}\n")
    endif()
    target_include_directories(${TARGET} PRIVATE "${_dsp}/Include" "${_dsp}/PrivateInclude")
    # CMSIS-DSP ships each function group twice: per-function files
    # (arm_fir_f32.c, …) AND a unity file per group (FilteringFunctions.c)
    # that #includes all of them.  Compiling both duplicates every symbol,
    # so compile only the unity files — the layout CMSIS-DSP's own build uses.
    set(_dsp_src "")
    file(GLOB _dsp_groups RELATIVE "${_dsp}/Source" "${_dsp}/Source/*")
    foreach(_g IN LISTS _dsp_groups)
      foreach(_f IN ITEMS "${_dsp}/Source/${_g}/${_g}.c" "${_dsp}/Source/${_g}/${_g}F16.c")
        if(EXISTS "${_f}")
          list(APPEND _dsp_src "${_f}")
        endif()
      endforeach()
    endforeach()
    target_sources(${TARGET} PRIVATE ${_dsp_src})
    # ARM_MATH_CM4 selects the Cortex-M4 code paths; __FPU_PRESENT enables the
    # single-precision hardware routines the DSP labs are timed against.
    target_compile_definitions(${TARGET} PRIVATE ARM_MATH_CM4 __FPU_PRESENT=1U ARM_MATH_LOOPUNROLL)
  endif()

  # --- linker script ------------------------------------------------------
  if(ARG_LINKER_SCRIPT)
    set(_ld "${ARG_LINKER_SCRIPT}")
  else()
    # Prefer the FLASH script over the RAM one CubeMX also emits.
    file(GLOB _ld_found "${CMAKE_CURRENT_SOURCE_DIR}/*FLASH.ld")
    if(NOT _ld_found)
      file(GLOB _ld_found "${CMAKE_CURRENT_SOURCE_DIR}/*.ld")
    endif()
    set(_ld "")
    if(_ld_found)
      list(GET _ld_found 0 _ld)
    endif()
  endif()
  if(NOT _ld OR NOT EXISTS "${_ld}")
    message(FATAL_ERROR
      "\n[${TARGET}] no linker script (*.ld) found in ${CMAKE_CURRENT_SOURCE_DIR}.\n"
      "  CubeMX generates STM32L476RGTX_FLASH.ld alongside the project.\n")
  endif()
  target_link_options(${TARGET} PRIVATE
    -T${_ld}
    -Wl,-Map=$<TARGET_FILE_DIR:${TARGET}>/${TARGET}.map,--cref
    -Wl,--print-memory-usage)
  set_target_properties(${TARGET} PROPERTIES LINK_DEPENDS "${_ld}" SUFFIX ".elf")

  # --- post-build artefacts ----------------------------------------------
  add_custom_command(TARGET ${TARGET} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${TARGET}>
    COMMAND ${CMAKE_OBJCOPY} -O ihex   $<TARGET_FILE:${TARGET}> $<TARGET_FILE_DIR:${TARGET}>/${TARGET}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${TARGET}> $<TARGET_FILE_DIR:${TARGET}>/${TARGET}.bin
    COMMENT "Size report + ${TARGET}.hex / ${TARGET}.bin")

  # --- flash convenience --------------------------------------------------
  add_custom_target(flash-${TARGET}
    COMMAND STM32_Programmer_CLI -c port=SWD -w $<TARGET_FILE:${TARGET}> -rst
    COMMENT "Flashing ${TARGET} over ST-LINK (needs STM32CubeProgrammer on PATH)")
  add_dependencies(flash-${TARGET} ${TARGET})
endfunction()
