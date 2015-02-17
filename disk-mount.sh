#!/bin/bash
set -e

# Loop0 uses the whole disk
# Loop1 uses partition 1
# Loop2 uses partition 2
export LOOP0=`losetup -f`
sudo losetup $LOOP0 disk.img
export LOOP1=`losetup -f`
sudo losetup $LOOP1 disk.img -o 1048576
export LOOP2=`losetup -f`
sudo losetup $LOOP2 disk.img -o 134217728

export ROOTDIR=`pwd`/sysroot
export EFIDIR=$ROOTDIR/efi
mkdir -p "$ROOTDIR"
sudo mount $LOOP2 "$ROOTDIR"
sudo mkdir -p "$EFIDIR"
sudo mount $LOOP1 "$EFIDIR"

