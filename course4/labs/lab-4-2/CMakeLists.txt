if(NOT TARGET engine_vulkan)
  return()
endif()
add_executable(lab_4_2 src/main.cpp)
target_link_libraries(lab_4_2 PRIVATE course4_options engine_vulkan)

# Module 4 is the metal-cpp port: link the Metal backend too when it is
# enabled (-DCOURSE4_ENABLE_METAL=ON + third_party/metal-cpp present).
if(TARGET engine_metal)
  target_link_libraries(lab_4_2 PRIVATE engine_metal)
endif()
