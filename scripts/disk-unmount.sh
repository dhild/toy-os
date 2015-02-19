#!/bin/bash
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"
set -v

export EFIDIR="$SYSROOT/efi"
sudo umount "$EFIDIR"
sudo umount "$SYSROOT"

sudo losetup -D

