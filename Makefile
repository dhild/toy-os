SHELL = /bin/sh
SRCDIR = $(realpath src)
BASEMAKE = $(realpath ./base.mk)

include $(BASEMAKE)

.PHONY: all
.PHONY: $(SRCDIR)
.PHONY: images
.PHONY: umount
.PHONY: compressed-img
.PHONY: clean
.PHONY: image-clean
.PHONY: hd

all: images

$(SRCDIR):
	make -C $(SRCDIR) BASEMAKE='$(BASEMAKE)'

hd.img: hd.img.xz
	xz -dfk hd.img.xz

hd: hd.img
	mkdir -pv hd
	$(MOUNT) -o sync,loop,offset=32256 hd.img hd

umount:
	$(UMOUNT) hd
	rmdir -v hd

images: $(SRCDIR) hd.img hd
	$(SUDO) cp -v src/kernel.elf hd/kernel.elf

compressed-img:
	xz -zfk hd.img

clean:
	make -C $(SRCDIR) clean BASEMAKE='$(BASEMAKE)'

image-clean: compressed-img clean
	rm -frv hd hd.img
