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

fd.img: fd.img.xz
	xz -dfk fd.img.xz

hd: hd.img
	mkdir -pv hd
	$(MOUNT) -o sync,loop,offset=32256 hd.img hd

umount:
	$(UMOUNT) hd
	rmdir -v hd

images: $(SRCDIR) hd.img fd.img hd
	$(SUDO) cp -v src/kernel.elf hd/kernel.elf

compressed-img:
	xz -zfk hd.img
	xz -zfk fd.img

clean:
	make -C $(SRCDIR) clean BASEMAKE='$(BASEMAKE)'

image-clean: compressed-img clean
	rm -frv hd hd.img fd.img

