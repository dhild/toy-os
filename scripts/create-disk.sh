#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"
"$( dirname "${BASH_SOURCE[0]}" )/disk-unmount.sh"
set -v

rm -rfv "$DISKIMG" "$SYSROOT"

# 512 * 512 * 1024 = 256M
dd if=/dev/zero of="$DISKIMG" bs=512 count=512K
parted -s "$DISKIMG" mklabel gpt
parted -s "$DISKIMG" mkpart primary fat32 2048s 260096s
parted -s "$DISKIMG" mkpart primary ext4 262144s 522240s
parted -s "$DISKIMG" toggle 1 boot

# Loop0 uses the whole disk
# Loop1 uses partition 1
# Loop2 uses partition 2
export LOOP0=`losetup -f`
sudo losetup $LOOP0 "$DISKIMG"
export LOOP1=`losetup -f`
sudo losetup $LOOP1 "$DISKIMG" -o 1048576
export LOOP2=`losetup -f`
sudo losetup $LOOP2 "$DISKIMG" -o 134217728

sudo mkfs.fat $LOOP1
sudo mkfs.ext4 $LOOP2
export EFIDIR="$SYSROOT/efi"
mkdir "$SYSROOT"
sudo mount $LOOP2 "$SYSROOT"
sudo mkdir "$EFIDIR"
sudo mount $LOOP1 "$EFIDIR"

echo "Installing Grub to $SYSROOT"

sudo grub-install --root-directory="$SYSROOT" --efi-directory="$EFIDIR" --no-floppy --modules="normal iso9660 part_gpt ext2 multiboot2 elf" $LOOP0

sync

sudo mkdir "$SYSROOT/usr"
sudo chown -hR $USER "$SYSROOT/boot"
sudo chown -hR $USER "$SYSROOT/usr"

cat > "$SYSROOT/boot/grub/grub.cfg" << EOF
menuentry "toy-os" {
	multiboot2 /boot/toy-os.kernel
}
EOF

