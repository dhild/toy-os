add_library(archkernel
  crti.nasm
  crtn.nasm
  entry64.nasm
  idt.nasm
  interrupt_entries.nasm
  multiboot2.nasm
  multiboot_signature.cpp
)

