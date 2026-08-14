# Every labs/lab-M-N/ with a CMakeLists.txt is a target; folders holding only
# notes/captures are skipped automatically.
file(GLOB lab_dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/lab-*)
foreach(dir ${lab_dirs})
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/CMakeLists.txt)
    add_subdirectory(${dir})
  endif()
endforeach()
