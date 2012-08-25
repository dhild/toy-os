SHELL = /bin/sh
SRCDIR = $(realpath src)
BASEMAKE = $(realpath ./base.mk)
DEPCHECK = $(realpath ./depcheck.mk)

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
	make -C $(SRCDIR) BASEMAKE='$(BASEMAKE)' DEPCHECK='$(DEPCHECK)'

hd.img: hd.img.xz
	xz -dfk hd.img.xz

images: $(SRCDIR) hd.img
	dd if=hd.img of=part1.img bs=1024 skip=1024 count=69536
	debugfs -w -f copy_image.debugfs
	dd if=part1.img of=hd.img bs=1024 seek=1024 count=69536
	rm -frv part1.img

compressed-img:
	xz -zfk hd.img

clean:
	make -C $(SRCDIR) clean BASEMAKE='$(BASEMAKE)' DEPCHECK='$(DEPCHECK)'

image-clean: compressed-img clean
	rm -frv hd.img

include $(DEPCHECK)
