#include "addresses.h"

/* The bootloader will look at this image and start execution at the symbol
   designated at the entry point. */
ENTRY(_start)

/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	. = KERNEL_PHYSICAL_BASE;

	.early BLOCK(4K) : AT(KERNEL_PHYSICAL_BASE)
	{
                *(.multiboot2_signature)
		*(.multiboot2)
	}
        
	/* Higher-half kernel */
	. += KERNEL_VIRTUAL_BASE;

	/* Next we'll put the .text section. */
	.text BLOCK(4K) : AT(ADDR(.text) - KERNEL_VIRTUAL_BASE)
	{
		*(.text)
	}

	/* Read-only data. */
	.rodata BLOCK(4K) : AT(ADDR(.rodata) - KERNEL_VIRTUAL_BASE)
	{
		*(SORT(.ctor*))
		*(SORT(.dtor*))
		*(.eh_frame)
		*(.rodata)
		*(.gnu.linkonce.r*)
		*(.note*)
	}

	/* Read-write data (initialized) */
	.data BLOCK(4K) : AT(ADDR(.data) - KERNEL_VIRTUAL_BASE)
	{
		*(.data)
		*(.gnu.linkonce.d*)
	}

	/* Read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : AT(ADDR(.bss) - KERNEL_VIRTUAL_BASE)
	{
		*(COMMON)
		*(.bss)
		*(.gnu.linkonce.b*)
	}

	/* The compiler may produce other sections, put them in the proper place in
	   in this file, if you'd like to include them in the final kernel. */
}
