add_library(archkernel
        setup_long_mode.nasm
        setup_gdt.nasm
        setup_idt.nasm
        setup_paging.nasm
        crti.nasm
        crtn.nasm
        )
