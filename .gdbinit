file build/kernel.elf build/kernel.sym
target remote localhost:1234
break kmain
continue
