cmake_minimum_required(VERSION 3.25)
project(course2_mcu C)

# Bare-metal tier, Mac-side: every .c in src/<ex>/ is compiled for the
# STM32L476's Cortex-M4F (thumbv7em-none-eabihf, freestanding, gnu17) into an
# object file, and each exercise gets a `dis-<ex>` target that disassembles
# those objects into build/<preset>/<ex>/*.lst.  Nothing links: there is no libc
# and no board here.  Sources must therefore be freestanding-safe (stdint.h,
# stddef.h, stdbool.h … — not stdio.h); keep the printf-using driver in
# c/host/ and the kernel in a file both tiers compile.
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(../cmake/warnings.cmake)

set(COURSE2_OPT "2" CACHE STRING "Optimization level: 0|1|2|3|s (default 2 — this tier exists to be read)")
add_compile_options(-O${COURSE2_OPT} -g)

find_program(LLVM_OBJDUMP NAMES llvm-objdump HINTS "$ENV{LLVM_DIR}/bin")
if(NOT LLVM_OBJDUMP)
  execute_process(COMMAND xcrun --find llvm-objdump OUTPUT_VARIABLE LLVM_OBJDUMP
                  OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
endif()
if(NOT LLVM_OBJDUMP)
  message(FATAL_ERROR "llvm-objdump not found (install the Xcode command-line tools: xcode-select --install)")
endif()

add_custom_target(dis COMMENT "Disassemble every exercise")

file(GLOB _dirs LIST_DIRECTORIES true CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*")
set(_count 0)
foreach(_d IN LISTS _dirs)
  if(NOT IS_DIRECTORY "${_d}")
    continue()
  endif()
  get_filename_component(_name "${_d}" NAME)
  file(GLOB _srcs CONFIGURE_DEPENDS "${_d}/*.c")
  if(NOT _srcs)
    message(STATUS "  ${_name}: no .c files yet — skipped")
    continue()
  endif()
  # OBJECT library = "compile, never link".
  add_library(${_name} OBJECT ${_srcs})
  target_include_directories(${_name} PRIVATE "${_d}")
  target_compile_options(${_name} PRIVATE ${COURSE2_WARNINGS})

  set(_lst_dir "${CMAKE_CURRENT_BINARY_DIR}/${_name}")
  file(MAKE_DIRECTORY "${_lst_dir}")
  set(_lsts)
  foreach(_src IN LISTS _srcs)
    get_filename_component(_base "${_src}" NAME_WE)
    set(_lst "${_lst_dir}/${_base}.lst")
    # $<TARGET_OBJECTS:...> is a list; pick this source's object via a small
    # per-object custom command instead, keyed on the object's known name.
    add_custom_command(
      OUTPUT "${_lst}"
      COMMAND ${LLVM_OBJDUMP} -d --no-show-raw-insn -S
              "$<TARGET_OBJECTS:${_name}>" > "${_lst}"
      DEPENDS ${_name}
      COMMAND_EXPAND_LISTS
      COMMENT "objdump ${_name} -> ${_base}.lst"
      VERBATIM)
    list(APPEND _lsts "${_lst}")
    break()   # one listing per exercise covers all its objects (objdump takes several files)
  endforeach()
  add_custom_target(dis-${_name} DEPENDS ${_lsts})
  add_dependencies(dis dis-${_name})
  math(EXPR _count "${_count} + 1")
  message(STATUS "  exercise ${_name}  (targets: ${_name}, dis-${_name})")
endforeach()
if(_count EQUAL 0)
  message(STATUS "  no exercises yet in src/ — create src/ex-M-N/ with freestanding-safe .c files")
endif()
message(STATUS "course2/c/mcu: thumbv7em-none-eabihf via ${CMAKE_C_COMPILER}, -O${COURSE2_OPT}, objdump ${LLVM_OBJDUMP}")
