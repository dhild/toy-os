set(KERNEL_ARCH_DIR "arch/${TOY_OS_TARGET_ARCH}")

include_directories("include")

add_definitions(-D__is_toyos_kernel)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mno-red-zone -ffreestanding -fbuiltin -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mno-red-zone -ffreestanding -fbuiltin -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow")

set(CMAKE_CXX_STANDARD_LIBRARIES "")
set(CMAKE_C_STANDARD_LIBRARIES "")

add_subdirectory(${KERNEL_ARCH_DIR})
add_subdirectory(kernel)

add_executable(kernel
  $<TARGET_OBJECTS:kernelCommon>
)

set_target_properties(kernel
  PROPERTIES
  SUFFIX ""
  LINK_FLAGS "-z max-page-size=0x1000 -nostdlib -lk"
)

target_link_libraries(kernel archkernel crtfiles)

