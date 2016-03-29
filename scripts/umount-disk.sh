#!/usr/bin/env bash
set -v

export SCRIPTS_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPTS_DIR/config.sh

sudo umount $EFIDIR
sudo umount $BOOTDIR
sudo umount $SYSROOT

sudo losetup -D

sudo rm -fr $SYSROOT $DISKIMG

