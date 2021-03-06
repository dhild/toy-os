Toy OS project
==============


Setup Information
-----------------

Arch linux ISO:

magnet:?xt=urn:btih:2ca62704bc6f0d23581ca3ed6eca611431b7a4c1&dn=archlinux-2015.11.01-dual.iso&tr=udp%3A%2F%2Ftracker.archlinux.org%3A6969&tr=http%3A%2F%2Ftracker.archlinux.org%3A6969%2Fannounce


qemu-img create -f raw disk.img 10g
qemu-system-x86_64 -hda disk.img -cdrom [path to Linux ISO] -m 1024 -bios [path to OVMF.fd]

livecd:# cfdisk /dev/sda
    1 partition for EFI, 550 mb
    2 partition for /boot, 1 g
    3 partition for /, remaining space

livecd:# mkfs.fat /dev/sda1
livecd:# mkfs.ext2 /dev/sda2
livecd:# mkfs.ext4 /dev/sda3
livecd:# mkdir /mnt/efi && mount /dev/sda1 /mnt/efi
livecd:# mkdir /mnt/boot && mount /dev/sda2 /mnt/boot
livecd:# grub-install --boot-directory=/mnt/boot --efi-directory=/mnt/efi /dev/sda
livecd:# umount /mnt/efi
livecd:# umount /mnt/boot

qemu-system-x86_64 -hda disk.img -m 2048 -bios [path to OVMF.fd]

    in EFI shell:
    FS0:
    cd EFI
    mkdir boot
    cp arch\grubx64.efi boot\bootx64.efi

fdisk disk.img

	Disk disk.img: 10 GiB, 10737418240 bytes, 20971520 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: gpt
	Disk identifier: EF5C9EC4-A5B2-42F7-8859-A1163C6FC635

	Device       Start      End  Sectors  Size Type
	disk.img1     2048  1128447  1126400  550M Linux filesystem
	disk.img2  1128448  3225599  2097152    1G Linux filesystem
	disk.img3  3225600 20971486 17745887  8.5G Linux filesystem

    p -> EFI partition -> start sector (2048) * 512 = 1048576
                       -> sectors (1126400) * 512 = 576716800
    p -> boot partition -> start sector (1128448) * 512 = 577765376
                        -> sectors (2097152) * 512 = 1073741824
    p -> root partition -> start sector (3225600) * 512 = 1651507200
                        -> sectors (17745887) * 512 = 9085894144

disk image mode = 'flat'
hd_size: 10737418240
geometry = 20805/16/63 (10240 MB)

export LOOP0=`losetup -f`
sudo losetup $LOOP0 -o 577765376 --sizelimit 1073741824 disk.img
export LOOP1=`losetup -f`
sudo losetup $LOOP1 -o 1651507200 --sizelimit 9085894144 disk.img

mkdir -p boot
mkdir -p disk
sudo mount $LOOP0 boot
sudo mount $LOOP1 disk


sudo nano boot/grub/grub.cfg

---- grub.cfg
set default="toy-os"
set timeout=1

insmod efi_gop
insmod efi_uga
insmod font

if loadfont ${prefix}/fonts/unicode.pf2
then
    insmod gfxterm
    set gfxmode=auto
    set gfxpayload=keep
    terminal_output gfxterm
fi

menuentry "toy-os" {
	multiboot (hd0,gpt2)/kernel.bin
        boot
}
---- end grub.cfg



