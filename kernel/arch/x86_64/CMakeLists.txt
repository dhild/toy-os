set(KERNEL_ARCH_CRTI_SRC "${CMAKE_CURRENT_SOURCE_DIR}/crti.nasm" PARENT_SCOPE)
set(KERNEL_ARCH_CRTN_SRC "${CMAKE_CURRENT_SOURCE_DIR}/crtn.nasm" PARENT_SCOPE)

set(KERNEL_ARCH_SRCS
  "${CMAKE_CURRENT_SOURCE_DIR}/entry64.nasm"
  "${CMAKE_CURRENT_SOURCE_DIR}/idt.nasm"
  "${CMAKE_CURRENT_SOURCE_DIR}/interrupt_entries.nasm"
  "${CMAKE_CURRENT_SOURCE_DIR}/multiboot2.nasm"
  "${CMAKE_CURRENT_SOURCE_DIR}/tty.cpp"
  
  PARENT_SCOPE
)

add_compile_options(-mno-red-zone)
