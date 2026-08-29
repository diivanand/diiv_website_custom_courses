cmake_minimum_required(VERSION 3.25)
project(course2_host C)

# Host tier: Apple clang, C17/18 with GNU extensions, the course warning set,
# ASan+UBSan in the debug preset.  This is where every C experiment that can run
# on the Mac runs — and where the sanitizers make undefined behavior visible.
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)          # gnu17 — matches Course 3's firmware and the labs' CMSIS headers
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(../cmake/warnings.cmake)
include(../cmake/exercises.cmake)

option(COURSE2_SANITIZE "AddressSanitizer + UndefinedBehaviorSanitizer" ON)
set(COURSE2_OPT "0" CACHE STRING "Optimization level: 0|1|2|3|s")

add_compile_options(-O${COURSE2_OPT} -g -fno-omit-frame-pointer)
if(COURSE2_SANITIZE)
  add_compile_options(-fsanitize=address,undefined -fno-sanitize-recover=all)
  add_link_options(-fsanitize=address,undefined)
endif()

enable_testing()
message(STATUS "course2/c/host: -O${COURSE2_OPT}, sanitizers ${COURSE2_SANITIZE}")
course2_add_exercises()
