# Module 1 — CUDA labs. Built only when COURSE4_ENABLE_CUDA=ON (the linux-*
# presets). check_language keeps configuration graceful on the Mac.
if(NOT COURSE4_ENABLE_CUDA)
  return()
endif()

include(CheckLanguage)
check_language(CUDA)
if(NOT CMAKE_CUDA_COMPILER)
  message(STATUS "course4: COURSE4_ENABLE_CUDA=ON but no CUDA toolkit found — skipping cuda/")
  return()
endif()
enable_language(CUDA)

foreach(lab 1_1 1_2 1_3 1_4 1_5)
  string(REPLACE "_" "-" dash ${lab})
  add_executable(lab_${lab}_cuda lab-${dash}/main.cu)
  target_compile_features(lab_${lab}_cuda PRIVATE cxx_std_20 cuda_std_20)
  set_target_properties(lab_${lab}_cuda PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
endforeach()
