set architecture i386:x86-64:intel
target remote | qemu-system-x86_64 -S -gdb stdio -m 2048 -drive file=disk.img,format=raw -bios bios.bin
symbol-file build/kernel/kernel.elf
file build/kernel/kernel.elf
break *0x00000000001010c0
break kernel_main
continue
