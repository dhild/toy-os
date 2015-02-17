#!/bin/bash
set -e

export ROOTDIR=`pwd`/sysroot
export EFIDIR=$ROOTDIR/efi
sudo umount "$EFIDIR"
sudo umount "$ROOTDIR"

sudo losetup -D

