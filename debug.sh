#!/bin/bash

KERNEL_FILE=build/kernel/kernel.elf

START_ADDR=`objdump -x $KERNEL_FILE | grep "setupLongMode" | awk '{print $1}'`
CLEANUP_ADDR=0x`objdump -x $KERNEL_FILE | grep "cleanup_32" | awk '{print $1}'`
KERNEL_MAIN_ADDR=0x`objdump -x $KERNEL_FILE | grep "kernel_main" | awk '{print $1}'`

sudo cp $KERNEL_FILE boot/kernel.bin

sudo sync

cat > .gdbinit << EOF
layout asm
#set architecture i386:x86-64:intel
set architecture i386
target remote localhost:1234
EOF
echo symbol-file $KERNEL_FILE >> .gdbinit
echo file $KERNEL_FILE >> .gdbinit
set disasemble-next-line on
echo break *0x$START_ADDR >> .gdbinit
echo break *$CLEANUP_ADDR >> .gdbinit
echo break kernel_main >> .gdbinit
echo continue >> .gdbinit
gdb -tui
