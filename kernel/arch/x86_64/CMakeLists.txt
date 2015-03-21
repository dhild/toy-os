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