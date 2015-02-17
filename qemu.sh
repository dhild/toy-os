#!/bin/sh
set -e
. ./build.sh

qemu-system-$(./target-triplet-to-arch.sh $HOST) disk.img -bios /usr/share/ovmf/OVMF.fd

