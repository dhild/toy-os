#layout asm
#layout regs
#set architecture i386

layout src
layout regs
set architecture i386:x86-64:intel

target remote localhost:1234

symbol-file build/kernel/kernel.elf
file build/kernel/kernel.elf

#break *0x0000000000101008
#break *0x000000000010107c
break kernel_main

continue
