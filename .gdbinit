layout asm
layout regs
set architecture i386

#layout src
#layout regs
#set architecture i386:x86-64:intel

target remote localhost:1234

symbol-file kernel/kernel.sym
file kernel/kernel.bin

break *0x0000000000101094
continue
nexti
set architecture i386:x86-64:intel

#break *0x0000000000101000
#break cleanup_32
#break setup_idt
break kernel_main

break handle_page_fault

#continue
