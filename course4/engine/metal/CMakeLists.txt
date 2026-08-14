# metal-cpp backend (Module 4+). metal-cpp is distributed by Apple as a zip —
# download it once into third_party/metal-cpp (see docs/setup.md), then
# configure with -DCOURSE4_ENABLE_METAL=ON.
set(METAL_CPP_DIR "${PROJECT_SOURCE_DIR}/third_party/metal-cpp")
if(NOT EXISTS "${METAL_CPP_DIR}/Metal/Metal.hpp")
  message(FATAL_ERROR "COURSE4_ENABLE_METAL is ON but ${METAL_CPP_DIR} is missing — see docs/setup.md")
endif()

add_library(engine_metal
  mtl_stub.cpp)
target_include_directories(engine_metal PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)
target_include_directories(engine_metal SYSTEM PUBLIC ${METAL_CPP_DIR})
target_link_libraries(engine_metal PUBLIC engine_core
  "-framework Metal" "-framework Foundation" "-framework QuartzCore")
