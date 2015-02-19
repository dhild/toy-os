ENTRY(_start)
SECTIONS
{
 . = 0x100000;
 .early BLOCK(4K) : AT(0x100000)
 {
  *(.multiboot2)
 }
 . += 0xFFFFC00000000000;
 .text BLOCK(4K) : AT(ADDR(.text) - 0xFFFFC00000000000)
 {
  *(.text)
 }
 .rodata BLOCK(4K) : AT(ADDR(.rodata) - 0xFFFFC00000000000)
 {
  *(SORT(.ctor*))
  *(SORT(.dtor*))
  *(.eh_frame)
  *(.rodata)
  *(.gnu.linkonce.r*)
  *(.note*)
 }
 .data BLOCK(4K) : AT(ADDR(.data) - 0xFFFFC00000000000)
 {
  *(.data)
  *(.gnu.linkonce.d*)
 }
 .bss BLOCK(4K) : AT(ADDR(.bss) - 0xFFFFC00000000000)
 {
  *(COMMON)
  *(.bss)
  *(.gnu.linkonce.b*)
 }
}
