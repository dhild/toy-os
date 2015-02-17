#!/bin/bash
set -e
set -v

rm -fr disk.img sysroot

# 512 * 512 * 1024 = 256M
dd if=/dev/zero of=disk.img bs=512 count=512K
parted -s disk.img mklabel gpt
parted -s disk.img mkpart primary fat32 2048s 260096s
parted -s disk.img mkpart primary ext4 262144s 522240s
parted -s disk.img toggle 1 boot

# Loop0 uses the whole disk
# Loop1 uses partition 1
# Loop2 uses partition 2
export LOOP0=`losetup -f`
sudo losetup $LOOP0 disk.img
export LOOP1=`losetup -f`
sudo losetup $LOOP1 disk.img -o 1048576
export LOOP2=`losetup -f`
sudo losetup $LOOP2 disk.img -o 134217728

sudo mkfs.fat $LOOP1
sudo mkfs.ext4 $LOOP2
export ROOTDIR=`pwd`/sysroot
export EFIDIR=$ROOTDIR/efi
mkdir "$ROOTDIR"
sudo mount $LOOP2 "$ROOTDIR"
sudo mkdir "$EFIDIR"
sudo mount $LOOP1 "$EFIDIR"

echo "Installing Grub to $ROOTDIR"

sudo grub-install --root-directory="$ROOTDIR" --efi-directory="$EFIDIR" --no-floppy --modules="normal iso9660 part_gpt ext2 multiboot2 elf" $LOOP0

sync

sudo mkdir "$ROOTDIR/usr"
sudo chown -hR $USER "$ROOTDIR/boot"
sudo chown -hR $USER "$ROOTDIR/usr"

cat > "$ROOTDIR/boot/grub/grub.cfg" << EOF
menuentry "toy-os" {
	multiboot2 /boot/toy-os.kernel
}
EOF

. ./headers.sh

sudo umount "$EFIDIR"
sudo umount "$ROOTDIR"
sudo losetup -d $LOOP2
sudo losetup -d $LOOP1
sudo losetup -d $LOOP0

