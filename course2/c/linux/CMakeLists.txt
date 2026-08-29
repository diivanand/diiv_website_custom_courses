cmake_minimum_required(VERSION 3.25)
project(course2_linux C)

# Embedded-Linux tier: POSIX C for the Jetson Orin Nano / Raspberry Pi 5.
# Built WHERE IT RUNS — clone the repo on the board (or use CLion's remote
# toolchain, see course3/docs/edge-setup.md) and `cmake --preset release`.
# It also configures and builds on the Mac so that the macOS-common POSIX subset
# (pthreads, clock_gettime, sockets, termios) can be iterated on locally;
# Linux-only APIs (timerfd, epoll, signalfd, libgpiod, i2c-dev) simply won't
# compile here, which is itself the Module 8 availability lesson.
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(../cmake/warnings.cmake)
include(../cmake/exercises.cmake)

set(COURSE2_OPT "2" CACHE STRING "Optimization level: 0|1|2|3|s")
option(COURSE2_SANITIZE "AddressSanitizer + UndefinedBehaviorSanitizer (debug preset)" OFF)
add_compile_options(-O${COURSE2_OPT} -g)
add_compile_definitions(_GNU_SOURCE)
if(COURSE2_SANITIZE)
  add_compile_options(-fsanitize=address,undefined -fno-sanitize-recover=all)
  add_link_options(-fsanitize=address,undefined)
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
link_libraries(Threads::Threads)

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(GPIOD IMPORTED_TARGET libgpiod)
endif()
if(GPIOD_FOUND)
  link_libraries(PkgConfig::GPIOD)
  add_compile_definitions(COURSE2_HAVE_GPIOD=1)
  message(STATUS "course2/c/linux: libgpiod ${GPIOD_VERSION} (v1 and v2 have different APIs — check the version)")
else()
  message(STATUS "course2/c/linux: libgpiod not found — GPIO exercises build only on the board (apt install libgpiod-dev)")
endif()
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  message(STATUS "course2/c/linux: configuring on ${CMAKE_SYSTEM_NAME} — only the POSIX subset common to macOS will build here")
endif()

enable_testing()
course2_add_exercises()
