#!/bin/bash

KERNEL_FILE=build/kernel/kernel.elf

sudo cp $KERNEL_FILE boot/kernel.bin
qemu-system-x86_64 -s -bios bios.bin -drive file=disk.img,format=raw -m 2048

