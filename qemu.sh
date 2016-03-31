#!/bin/bash

KERNEL_FILE=build/kernel/kernel.elf

sudo cp $KERNEL_FILE sysroot/boot/kernel.bin
sudo sync
qemu-system-x86_64 -s -bios ../seabios.bin -drive file=disk.img,format=raw -m 2048

