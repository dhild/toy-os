layout asm
layout regs
set architecture i386

#layout src
#layout regs
#set architecture i386:x86-64:intel

target remote localhost:1234

symbol-file kernel/kernel.sym
file kernel/kernel.bin

break *0x0000000000101000
#break *0x000000000010107c
#break kernel_main

#continue
