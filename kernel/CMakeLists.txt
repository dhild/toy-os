set(KERNEL_ARCH_DIR "arch/${TOY_OS_TARGET_ARCH}")

include_directories("include")

add_definitions(-D__is_toyos_kernel)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mno-red-zone -ffreestanding -fbuiltin -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mno-red-zone -ffreestanding -fbuiltin -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow")

set(CMAKE_CXX_STANDARD_LIBRARIES "")
set(CMAKE_C_STANDARD_LIBRARIES "")

add_subdirectory(${KERNEL_ARCH_DIR})

add_library(archcrt ${KERNEL_ARCH_CRTI_SRC} ${KERNEL_ARCH_CRTN_SRC})

execute_process(COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_C_FLAGS} ${CMAKE_LINK_FLAGS}
  -print-file-name=crtbegin.o
  OUTPUT_VARIABLE COMPILER_CRTBEGIN)
execute_process(COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_C_FLAGS} ${CMAKE_LINK_FLAGS}
  -print-file-name=crtend.o
  OUTPUT_VARIABLE COMPILER_CRTEND)

ADD_LIBRARY(
  crtfiles
  STATIC
  EXCLUDE_FROM_ALL
  ${COMPILER_CRTBEGIN} ${COMPILER_CRTEND}
)

SET_SOURCE_FILES_PROPERTIES(
  ${COMPILER_CRTBEGIN} ${COMPILER_CRTEND}
  PROPERTIES
  EXTERNAL_OBJECT true # to say that "this is actually an object file, so it should not be compiled, only linked"
  GENERATED true       # to say that "it is OK that the obj-files do not exist before build time"
  )
SET_TARGET_PROPERTIES(
  crtfiles
  PROPERTIES
  LINKER_LANGUAGE C # Or else we get an error message, because cmake can't figure out from the ".o"-suffix that it is a C-linker we need.
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib
  )

add_executable(kernel
  kernel/kernel.c
  ${KERNEL_ARCH_SRCS}
 
)

set_target_properties(kernel
  PROPERTIES
  SUFFIX ""
  LINK_FLAGS "-z max-page-size=0x1000 -nostdlib -lk"
)

target_link_libraries(kernel archcrt crtfiles)

