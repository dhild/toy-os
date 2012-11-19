MAKEFLAGS += -rR

TOS_BASEMAKE = $(realpath ./base.mk)
TOS_DEPCHECK = $(realpath ./depcheck.mk)

export TOS_DEPCHECK TOS_BASEMAKE

.PHONY: all
.PHONY: src
.PHONY: images
.PHONY: umount
.PHONY: compressed-img
.PHONY: clean
.PHONY: image-clean
.PHONY: hd

all: images

include $(TOS_BASEMAKE)

src:
	make -C src

hd.img: hd.img.xz
	xz -dfk hd.img.xz

images: src hd.img
	dd if=hd.img of=part1.img bs=1024 skip=1024 count=69536
	debugfs -w -f copy_image.debugfs
	dd if=part1.img of=hd.img bs=1024 seek=1024 count=69536
	rm -fr part1.img

compressed-img:
	xz -zfk hd.img

clean:
	make -C src clean

image-clean: compressed-img clean
	rm -fr hd.img

