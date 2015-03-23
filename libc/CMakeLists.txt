add_subdirectory(stdio)
add_subdirectory(stdlib)
add_subdirectory(string)

add_library(kernel_libc
  $<TARGET_OBJECTS:libc_stdio>
  $<TARGET_OBJECTS:libc_stdlib>
  $<TARGET_OBJECTS:libc_string>
)