# Layout convention shared by host/ and linux/: one directory per exercise under
# src/; every .c file in it compiles into one executable named after the
# directory.  A directory whose only sources are test_*.c (or that contains any
# test_*.c) is also registered with CTest.  Nothing here builds unless you create
# those directories — the exercises are yours to write.
#
#   src/ex-1-2/main.c                 -> build/<preset>/ex-1-2
#   src/ex-4-3/pool.c  test_pool.c    -> build/<preset>/ex-4-3   (+ ctest "ex-4-3")

function(course2_add_exercises)
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
    file(GLOB _tests CONFIGURE_DEPENDS "${_d}/test_*.c")
    if(_tests)
      add_test(NAME ${_name} COMMAND ${_name})
    endif()
    math(EXPR _count "${_count} + 1")
    message(STATUS "  exercise ${_name}")
  endforeach()
  if(_count EQUAL 0)
    message(STATUS "  no exercises yet in ${CMAKE_CURRENT_SOURCE_DIR}/src/ — create src/ex-M-N/ and add .c files")
  endif()
endfunction()
