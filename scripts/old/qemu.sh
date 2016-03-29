#!/bin/bash
set -e
"$( dirname "${BASH_SOURCE[0]}" )/build.sh"
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"

export TRIPLET=$($( dirname "${BASH_SOURCE[0]}" )/target-triplet-to-arch.sh $HOST)

qemu-system-$TRIPLET -s -S "$DISKIMG" -bios /usr/share/ovmf/OVMF.fd
