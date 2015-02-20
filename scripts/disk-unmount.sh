#!/bin/bash
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"
set -v

sudo umount "$SYSROOT"

sudo losetup -D

