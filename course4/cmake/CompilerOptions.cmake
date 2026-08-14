# course4_options — the interface target every course target links.
# Usage requirements only; no global flags anywhere in this tree.

add_library(course4_options INTERFACE)

target_compile_features(course4_options INTERFACE cxx_std_20)

# The GLM switches the course's coordinate conventions depend on. Compile
# definitions, not header #defines: every TU that includes glm — directly or
# transitively — must agree, or matrix layouts silently diverge across TUs.
target_compile_definitions(course4_options INTERFACE
  GLM_FORCE_RADIANS GLM_FORCE_DEPTH_ZERO_TO_ONE)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU|AppleClang")
  target_compile_options(course4_options INTERFACE
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion)

  if(COURSE4_SANITIZE)
    target_compile_options(course4_options INTERFACE
      -fsanitize=address,undefined -fno-omit-frame-pointer)
    target_link_options(course4_options INTERFACE
      -fsanitize=address,undefined)
  endif()
endif()
