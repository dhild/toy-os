#!/usr/bin/env bash
set -v

export SCRIPTS_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPTS_DIR/config.sh

NEW_DISK=$(test -e $DISKIMG)

if $NEW_DISK; then

  mkdir -p $(dirname $DISKIMG)
  qemu-img create -f raw $DISKIMG 10g

  parted $DISKIMG mklabel gpt
  parted $DISKIMG mkpart C12A7328-F81F-11D2-BA4B-00A0C93EC93B fat32 ${EFI_START_S}s ${EFI_END_S}s
  parted $DISKIMG mkpart 0FC63DAF-8483-4772-8E79-3D69D8477DE4 ext2 ${BOOT_START_S}s ${BOOT_END_S}s
  parted $DISKIMG mkpart 0FC63DAF-8483-4772-8E79-3D69D8477DE4 ext2 ${ROOT_START_S}s ${ROOT_END_S}s

fi

export LOOP0=$(losetup -f)
sudo losetup $LOOP0 -o $EFI_START --sizelimit $EFI_SIZE disk.img
export LOOP1=$(losetup -f)
sudo losetup $LOOP1 -o $BOOT_START --sizelimit $BOOT_SIZE disk.img
export LOOP2=$(losetup -f)
sudo losetup $LOOP2 -o $ROOT_START --sizelimit $ROOT_SIZE disk.img
export LOOP3=$(losetup -f)
sudo losetup $LOOP3 disk.img

if $NEW_DISK; then

  sudo mkfs.vfat $LOOP0
  sudo mkfs.ext2 $LOOP1
  sudo mkfs.ext4 $LOOP2

fi

sudo mkdir -p $SYSROOT
sudo mount $LOOP2 $SYSROOT
sudo mkdir -p $BOOTDIR
sudo mount $LOOP1 $BOOTDIR
sudo mkdir -p $EFIDIR
sudo mount $LOOP0 $EFIDIR

sudo grub-install --boot-directory=$BOOTDIR --efi-directory=$EFIDIR $LOOP3

sudo mkdir $EFIDIR/EFI/boot
sudo cp $EFIDIR/EFI/ubuntu/grubx64.efi $EFIDIR/EFI/boot/bootx64.efi

cat > grub.cfg << EOF
set default="toy-os"
set timeout=1

insmod efi_gop
insmod efi_uga
insmod font

if loadfont \${prefix}/fonts/unicode.pf2
then
    insmod gfxterm
    set gfxmode=auto
    set gfxpayload=keep
    terminal_output gfxterm
fi

menuentry "toy-os" {
	multiboot (hd0,gpt1)/kernel.bin
        boot
}
EOF

sudo mv grub.cfg $BOOTDIR/grub/grub.cfg

