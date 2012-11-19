#include <boot/addresses.h>

OUTPUT_FORMAT(elf64-x86-64)
ENTRY(__start)
SECTIONS
{
	. = KERNEL_PHYSICAL_BASE;

	.header :
	{
		*multiboot.o(.text*)
		*paging.o(.text*)
		. = ALIGN(4096);
	}

	. += KERNEL_VIRTUAL_BASE;

	.text : AT(ADDR(.text) - KERNEL_VIRTUAL_BASE)
	{
		*(.text*)
		*(.gnu.linkonce.t*)
		. = ALIGN(4096);
	}

	.rodata : AT(ADDR(.rodata) - KERNEL_VIRTUAL_BASE)
	{
		start_ctors = .;
		*(SORT(.ctor*))
		end_ctors = .;

		start_dtors = .;
		*(SORT(.dtor*))
		end_dtors = .;

		*(.rodata*)
		*(.gnu.linkonce.r*)

		. = ALIGN(4096);
	}

	.data : AT(ADDR(.data) - KERNEL_VIRTUAL_BASE)
	{
		*(.data*)
		*(.gnu.linkonce.d*)

		. = ALIGN(4096);
	}

        __kernel_data_end = . - KERNEL_VIRTUAL_BASE;

	.bss :  AT(ADDR(.bss) - KERNEL_VIRTUAL_BASE)
	{
		*(COMMON*)
		*(.bss*)
		*(.gnu.linkonce.b*)
	}

	 /DISCARD/ :
	 {
		*(.comment)
		*(.eh_frame) /* You should discard this unless you're implementing runtime support for C++ exceptions. */
	 }

         __kernel_end = . - KERNEL_VIRTUAL_BASE;

	 . = ASSERT((__kernel_end - __kernel_start) <= KERNEL_MAX_SIZE, "Size of kernel too large!")
}