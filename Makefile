COMPRESS=xz -zfk
DECOMPRESS=xz -dfk
SUDO=sudo
MOUNT=$(SUDO) mount
UMOUNT=$(SUDO) umount

all:
	make -C src
	make images

hd.img: hd.img.xz
	$(DECOMPRESS) hd.img.xz

fd.img: fd.img.xz
	$(DECOMPRESS) fd.img.xz

hd: hd.img
	mkdir -pv hd
	$(MOUNT) -o sync,loop,offset=32256 hd.img hd

umount:
	$(UMOUNT) hd
	rmdir -v hd

images: hd.img fd.img hd
	$(SUDO) cp -v src/kernel.elf hd/kernel.elf

compressed-img:
	$(COMPRESS) hd.img
	$(COMPRESS) fd.img

clean:
	make -C src clean

dist-clean: compressed-img
	make -C src dist-clean
	rm -frv hd hd.img fd.img