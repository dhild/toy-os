#!/usr/bin/env bash

export TOPDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

export DISKIMG="$TOPDIR/disk.img"
export SYSROOT="$TOPDIR/sysroot"
export BOOTDIR="$SYSROOT/boot"
export EFIDIR="$BOOTDIR/efi"

export EFI_SIZE=$(expr 512 \* 1024 \* 1024)
export BOOT_SIZE=$EFI_SIZE
export ROOT_SIZE=$(expr 5 \* 1024 \* 1024 \* 1024)

export EFI_START=$(expr 1024 \* 1024)
export BOOT_START=$(expr $EFI_START + $EFI_SIZE)
export ROOT_START=$(expr $BOOT_START + $BOOT_SIZE)
export ROOT_END=$(expr $ROOT_START + $ROOT_SIZE)

export EFI_START_S=$(expr $EFI_START / 512)
export BOOT_START_S=$(expr $BOOT_START / 512)
export ROOT_START_S=$(expr $ROOT_START / 512)
export EFI_END_S=$(expr $BOOT_START_S - 1)
export BOOT_END_S=$(expr $ROOT_START_S - 1)
export ROOT_END_S=$(expr $ROOT_END / 512)

