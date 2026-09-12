# Layout convention shared by host/ and linux/: one directory per exercise under
# src/; every .c file in it compiles into one executable named after the
# directory.  A directory that contains any test_*.c is also registered with
# CTest and linked against Unity (ThrowTheSwitch's C-only harness, fetched on
# first configure — Module 9's test-driven development runs on it).  Nothing
# here builds unless you create those directories — the exercises are yours.
#
#   src/ex-1-2/main.c                      -> build/<preset>/ex-1-2
#   src/ex-9-1/eventlog.c test_eventlog.c  -> build/<preset>/ex-9-1  (+ ctest "ex-9-1", Unity linked)
#
# Shared sources: everything under c/shared/ (recursively) is compiled once into
# the static library `course2_shared` and linked into every exercise, with
# c/shared/ on the include path — for code that several exercises, or the
# Module 9 capstone driver (c/shared/ads1115/), must share across tiers.

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
  list(LENGTH _srcs _n)
  message(STATUS "  c/shared: ${_n} source file(s) -> course2_shared")
endfunction()

# Unity is fetched lazily: only when some exercise directory has a test_*.c.
function(course2_add_unity)
  if(TARGET unity)
    return()
  endif()
  include(FetchContent)
  FetchContent_Declare(unity
    GIT_REPOSITORY https://github.com/ThrowTheSwitch/Unity.git
    GIT_TAG        v2.6.1
    GIT_SHALLOW    TRUE)
  FetchContent_MakeAvailable(unity)   # Unity's own CMakeLists defines the library target `unity`
  target_compile_definitions(unity PUBLIC UNITY_INCLUDE_DOUBLE UNITY_OUTPUT_COLOR)
  message(STATUS "  Unity ${unity_SOURCE_DIR} -> target `unity` (linked into every test_*.c exercise)")
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
    add_executable(${_name} ${_srcs})
    target_include_directories(${_name} PRIVATE "${_d}")
    target_compile_options(${_name} PRIVATE ${COURSE2_WARNINGS})
    if(TARGET course2_shared)
      target_link_libraries(${_name} PRIVATE course2_shared)
    endif()
    file(GLOB _tests CONFIGURE_DEPENDS "${_d}/test_*.c")
    if(_tests)
      course2_add_unity()
      target_link_libraries(${_name} PRIVATE unity)
      add_test(NAME ${_name} COMMAND ${_name})
      message(STATUS "  exercise ${_name}  (+ ctest, Unity)")
    else()
      message(STATUS "  exercise ${_name}")
    endif()
    math(EXPR _count "${_count} + 1")
  endforeach()
  if(_count EQUAL 0)
    message(STATUS "  no exercises yet in ${CMAKE_CURRENT_SOURCE_DIR}/src/ — create src/ex-M-N/ and add .c files")
  endif()
endfunction()
