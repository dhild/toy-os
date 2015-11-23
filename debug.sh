#!/bin/bash

KERNEL_FILE=build/kernel/kernel.elf

START_ADDR=`objdump -x $KERNEL_FILE | grep "start address" | awk '{print $3}'`
KERNEL_MAIN_ADDR=0x`objdump -x $KERNEL_FILE | grep "kernel_main" | awk '{print $1}'`

sudo cp $KERNEL_FILE boot/kernel.bin

cat > .gdbinit << EOF
set architecture i386:x86-64:intel
target remote | qemu-system-x86_64 -S -gdb stdio -m 2048 -drive file=disk.img,format=raw -bios bios.bin
EOF
echo symbol-file $KERNEL_FILE >> .gdbinit
echo file $KERNEL_FILE >> .gdbinit
echo break *$START_ADDR >> .gdbinit
echo break kernel_main >> .gdbinit
echo continue >> .gdbinit

gdb
