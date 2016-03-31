#!/bin/bash

KERNEL_FILE=build/kernel/kernel.elf

OVMF_ZIP=http://downloads.sourceforge.net/project/edk2/OVMF/OVMF-X64-r15214.zip
OVMF_BINARY=OVMF.fd

if [ ! -f "$OVMF_BINARY" ]; then
  echo "Downloading UEFI bios image OVMF.fd"
  wget "$OVMF_ZIP" -O ovmf.zip
  unzip ovmf.zip $OVMF_BINARY
  rm ovmf.zip
fi

sudo cp $KERNEL_FILE sysroot/boot/kernel.bin
sudo sync
qemu-system-x86_64 -s -bios "$OVMF_BINARY" -drive file=disk.img,format=raw -m 2048

