#include "addresses.h"

/* The bootloader will look at this image and start execution at the symbol
   designated at the entry point. */
ENTRY(kernel_entry)

/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	. = KERNEL_PHYSICAL_BASE;
    kernel_physical_start = .          ;
    kernel_start = KERNEL_VIRTUAL_BASE ;
    kernel_virtual_offset = (kernel_start - kernel_physical_start) ;

    .header_signature : AT(KERNEL_PHYSICAL_BASE)
    {
        header_signature_addr = . ;
        *(.header_signature)
    }

	.text_early BLOCK(4K) :
	{
        *(.text_early)
	}
        
	/* Higher-half kernel */
	. += KERNEL_VIRTUAL_OFFSET;

	/* Next we'll put the .text section. */
	.text BLOCK(4K) : AT(ADDR(.text) - KERNEL_VIRTUAL_OFFSET)
	{
        *(.init)
        *(.fini)
		*(.text)
	}

	/* Read-only data. */
	.rodata BLOCK(4K) : AT(ADDR(.rodata) - KERNEL_VIRTUAL_OFFSET)
	{
		*(SORT(.ctor*))
		*(SORT(.dtor*))
		*(.eh_frame)
		*(.rodata)
		*(.gnu.linkonce.r*)
		*(.note*)
	}

	/* Read-write data (initialized) */
	.data BLOCK(4K) : AT(ADDR(.data) - KERNEL_VIRTUAL_OFFSET)
	{
		*(.data)
		*(.gnu.linkonce.d*)
	}

	kernel_bss_start = . - KERNEL_VIRTUAL_OFFSET ;

	/* Read-write data (uninitialized) */
	.bss BLOCK(4K) : AT(ADDR(.bss) - KERNEL_VIRTUAL_OFFSET)
	{
		*(COMMON)
		*(.bss)
		*(.gnu.linkonce.b*)
        
        /* Stack is virtually located before the kernel */
        stack_physical_start = (. - kernel_virtual_offset) ;
        . += (4 * 4096) ;
        stack_physical_end = (. - kernel_virtual_offset) ;
	}

    kernel_end = .          ;
    kernel_physical_end = . - KERNEL_VIRTUAL_OFFSET;
    kernel_size = kernel_end - kernel_start ;
}
