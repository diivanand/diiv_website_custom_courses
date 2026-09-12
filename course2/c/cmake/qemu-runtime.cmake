# The Course 2 bare-metal runtime for QEMU / the NUCLEO, shared by c/mcu and
# c/rtos when built with arm-none-eabi-gcc: startup.c (vector table, reset,
# weak handlers), semihost.c (printf and exit over semihosting), stm32l4.ld.
#
#   course2_add_qemu_runtime()               -> static library `course2_runtime`
#   course2_add_qemu_program(<name> <srcs>…) -> <name>.elf + <name>.map,
#                                               run-<name>, size-<name>, dis-<name>
#
# Console output from semihosting comes out on QEMU's stderr.  A program's
# return value from main() becomes QEMU's exit status (SYS_EXIT_EXTENDED), so
# `run-<name>` fails when main returns non-zero — CTest-friendly.
set(COURSE2_QEMU_DIR "${CMAKE_CURRENT_LIST_DIR}/../mcu/qemu")
set(COURSE2_QEMU_MACHINE "b-l475e-iot01a" CACHE STRING "QEMU machine (an STM32L4 board)")
set(COURSE2_QEMU_TIMEOUT "60" CACHE STRING "Seconds before a run-<name> target is killed")

find_program(QEMU_SYSTEM_ARM qemu-system-arm HINTS /opt/homebrew/bin /usr/local/bin)
if(NOT QEMU_SYSTEM_ARM)
  message(STATUS "  qemu-system-arm not found — ELFs still build; install with `brew install qemu` to run them")
endif()

function(course2_add_qemu_runtime)
  if(TARGET course2_runtime)
    return()
  endif()
  add_library(course2_runtime STATIC
              "${COURSE2_QEMU_DIR}/startup.c"
              "${COURSE2_QEMU_DIR}/semihost.c")
  target_include_directories(course2_runtime PUBLIC "${COURSE2_QEMU_DIR}")
  target_compile_options(course2_runtime PRIVATE ${COURSE2_WARNINGS})
endfunction()

function(course2_add_qemu_program name)
  course2_add_qemu_runtime()
  add_executable(${name}.elf ${ARGN})
  target_link_libraries(${name}.elf PRIVATE course2_runtime)
  # The vector table lives in the runtime library and nothing references it by
  # name; --whole-archive is the honest way to keep it (KEEP() in the linker
  # script only protects sections that the linker actually pulled in).
  target_link_options(${name}.elf PRIVATE
                      "-T${COURSE2_QEMU_DIR}/stm32l4.ld"
                      "-Wl,-Map=$<TARGET_FILE_DIR:${name}.elf>/${name}.map"
                      "-Wl,--whole-archive" "$<TARGET_FILE:course2_runtime>" "-Wl,--no-whole-archive")
  add_dependencies(${name}.elf course2_runtime)

  add_custom_target(size-${name}
    COMMAND ${CMAKE_SIZE} -A -x "$<TARGET_FILE:${name}.elf>"
    COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${name}.elf>"
    DEPENDS ${name}.elf COMMENT "size ${name}.elf" VERBATIM)
  add_custom_target(dis-${name}
    COMMAND ${CMAKE_OBJDUMP} -d --no-show-raw-insn -S "$<TARGET_FILE:${name}.elf>"
            > "$<TARGET_FILE_DIR:${name}.elf>/${name}.lst"
    DEPENDS ${name}.elf COMMENT "objdump ${name}.elf -> ${name}.lst" VERBATIM)
  if(QEMU_SYSTEM_ARM)
    add_custom_target(run-${name}
      COMMAND ${CMAKE_COMMAND} -E env COURSE2_QEMU_TIMEOUT=${COURSE2_QEMU_TIMEOUT}
              "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/run-qemu.sh" "${QEMU_SYSTEM_ARM}"
              "${COURSE2_QEMU_MACHINE}" "$<TARGET_FILE:${name}.elf>"
      DEPENDS ${name}.elf USES_TERMINAL
      COMMENT "qemu-system-arm -machine ${COURSE2_QEMU_MACHINE} ${name}.elf" VERBATIM)
  endif()
endfunction()
