#!/bin/bash
set -e
. "$( dirname "${BASH_SOURCE[0]}" )/config.sh"
"$( dirname "${BASH_SOURCE[0]}" )/disk-unmount.sh"
set -v

rm -rfv "$DISKIMG" "$SYSROOT"

# 512 * 512 * 1024 = 256M
dd if=/dev/zero of="$DISKIMG" bs=512 count=512K
parted -s "$DISKIMG" mklabel msdos
parted -s "$DISKIMG" mkpart primary ext4 2048s 522240s
parted -s "$DISKIMG" toggle 1 boot

# Loop0 uses the whole disk
# Loop1 uses partition 1
export LOOP0=`losetup -f`
sudo losetup $LOOP0 "$DISKIMG"
export LOOP1=`losetup -f`
sudo losetup $LOOP1 "$DISKIMG" -o 1048576

sudo mkfs.ext4 $LOOP1
mkdir "$SYSROOT"
sudo mount $LOOP1 "$SYSROOT"

echo "Installing Grub to $SYSROOT"
sleep 5

cat > "$OSDIR/device.map" << EOF
(hd0) $LOOP0
EOF
sudo mkdir -p "$SYSROOT/boot/grub"
sudo mv "$OSDIR/device.map" "$SYSROOT/boot/grub/device.map"
sync
sudo grub-install --root-directory="$SYSROOT" \
                  --no-floppy \
                  --grub-mkdevicemap="$SYSROOT/boot/grub/device.map" \
                  --target=i386-pc \
                  $LOOP0
#                  -d ~/.local/lib/grub/i386-pc \

sync

sudo mkdir "$SYSROOT/usr"
sudo chown -hR $USER "$SYSROOT/boot"
sudo chown -hR $USER "$SYSROOT/usr"

cat > "$SYSROOT/boot/grub/grub.cfg" << EOF
set default="toy-os"
set timeout=1
menuentry "toy-os" {
	multiboot2 /boot/toy-os.kernel
        boot
}
EOF

