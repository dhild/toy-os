#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"

if [ ! -f "$DISKIMG" ]; then
    "$( dirname "${BASH_SOURCE[0]}" )/create-disk.sh"
else

# Loop0 uses the whole disk
# Loop1 uses partition 1
# Loop2 uses partition 2
if losetup -a | grep -q "$DISKIMG"; then
    exit 0
fi
export LOOP0=`losetup -f`
sudo losetup $LOOP0 "$DISKIMG"
export LOOP1=`losetup -f`
sudo losetup $LOOP1 "$DISKIMG" -o 1048576
export LOOP2=`losetup -f`
sudo losetup $LOOP2 "$DISKIMG" -o 134217728

export EFIDIR="$SYSROOT/efi"
mkdir -p "$SYSROOT"
sudo mount $LOOP2 "$SYSROOT"
sudo mkdir -p "$SYSROOT"
sudo mount $LOOP1 "$SYSROOT"

fi

