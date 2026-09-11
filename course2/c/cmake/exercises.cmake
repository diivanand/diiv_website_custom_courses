# Layout convention shared by host/ and linux/: one directory per exercise under
# src/; every .c file in it compiles into one executable named after the
# directory.  A directory whose only sources are test_*.c (or that contains any
# test_*.c) is also registered with CTest.  A directory whose name starts with
# "lib" is built as a SHARED library instead — sanitizer-free, so that Python can
# dlopen it through ctypes/cffi (Module 2's bridge exercises).  Nothing here
# builds unless you create those directories — the exercises are yours to write.
#
#   src/ex-1-2/main.c                 -> build/<preset>/ex-1-2
#   src/ex-4-3/pool.c  test_pool.c    -> build/<preset>/ex-4-3   (+ ctest "ex-4-3")
#   src/lib-ex-2-6/fir.c dot.c        -> build/<preset>/lib-ex-2-6.dylib|.so
#
# Shared sources: everything under c/shared/ (recursively) is compiled once into
# the static library `course2_shared` and linked into every exercise, with
# c/shared/ on the include path — for code that several exercises, or the
# Module 12 capstone driver (c/shared/ads1115/), must share across tiers.

function(course2_add_shared)
  set(_shared "${CMAKE_CURRENT_SOURCE_DIR}/../shared")
  if(NOT IS_DIRECTORY "${_shared}")
    return()
  endif()
  file(GLOB_RECURSE _srcs CONFIGURE_DEPENDS "${_shared}/*.c")
  if(NOT _srcs)
    message(STATUS "  c/shared: no .c files yet — nothing shared")
    return()
  endif()
  add_library(course2_shared STATIC ${_srcs})
  target_include_directories(course2_shared PUBLIC "${_shared}")
  target_compile_options(course2_shared PRIVATE ${COURSE2_WARNINGS})
  # Sanitizer-free twin for the shared-library ("lib*") targets: a dylib that
  # Python loads must not reference the sanitizer runtime anywhere.
  add_library(course2_shared_nosan STATIC ${_srcs})
  target_include_directories(course2_shared_nosan PUBLIC "${_shared}")
  target_compile_options(course2_shared_nosan PRIVATE ${COURSE2_WARNINGS} -fno-sanitize=all)
  list(LENGTH _srcs _n)
  message(STATUS "  c/shared: ${_n} source file(s) -> course2_shared (+ course2_shared_nosan)")
endfunction()

function(course2_add_exercises)
  course2_add_shared()
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
    if(_name MATCHES "^lib")
      add_library(${_name} SHARED ${_srcs})
      set_target_properties(${_name} PROPERTIES PREFIX "")
      # A sanitizer-instrumented library cannot be loaded into a plain Python
      # process; the bridge exercises need a clean build regardless of preset.
      target_compile_options(${_name} PRIVATE -fno-sanitize=all)
      target_link_options(${_name} PRIVATE -fno-sanitize=all)
    else()
      add_executable(${_name} ${_srcs})
      file(GLOB _tests CONFIGURE_DEPENDS "${_d}/test_*.c")
      if(_tests)
        add_test(NAME ${_name} COMMAND ${_name})
      endif()
    endif()
    target_include_directories(${_name} PRIVATE "${_d}")
    target_compile_options(${_name} PRIVATE ${COURSE2_WARNINGS})
    if(TARGET course2_shared)
      if(_name MATCHES "^lib")
        target_link_libraries(${_name} PRIVATE course2_shared_nosan)
      else()
        target_link_libraries(${_name} PRIVATE course2_shared)
      endif()
    endif()
    math(EXPR _count "${_count} + 1")
    message(STATUS "  exercise ${_name}")
  endforeach()
  if(_count EQUAL 0)
    message(STATUS "  no exercises yet in ${CMAKE_CURRENT_SOURCE_DIR}/src/ — create src/ex-M-N/ and add .c files")
  endif()
endfunction()
