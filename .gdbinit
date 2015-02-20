set architecture i386:x86-64:intel
symbol-file kernel/toy-os.elf
target remote localhost:1234
break *0x1000d0
break *0xffffffff801061a0
continue
