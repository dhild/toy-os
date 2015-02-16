#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/toy-os.kernel isodir/boot/toy-os.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "toy-os" {
	multiboot /boot/toy-os.kernel
}
EOF
grub-mkrescue -o toy-os.iso isodir
