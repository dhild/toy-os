set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mno-red-zone")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mno-red-zone")

add_library(archkernel
  crti.nasm
  crtn.nasm
  entry64.nasm
  idt.nasm
  interrupt_entries.nasm
  multiboot2.nasm
  tty.cpp
)

add_library(crtfiles STATIC
  EXCLUDE_FROM_ALL
  ${COMPILER_CRTBEGIN} ${COMPILER_CRTEND}
)

SET_SOURCE_FILES_PROPERTIES(${COMPILER_CRTBEGIN} ${COMPILER_CRTEND}
  PROPERTIES
  EXTERNAL_OBJECT true # to say that "this is actually an object file, so it should not be compiled, only linked"
  GENERATED true       # to say that "it is OK that the obj-files do not exist before build time"
  )
SET_TARGET_PROPERTIES(crtfiles
  PROPERTIES
  LINKER_LANGUAGE C # Or else we get an error message, because cmake can't figure out from the ".o"-suffix that it is a C-linker we need.
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib
  )
