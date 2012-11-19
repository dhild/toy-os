MAKEFLAGS += -rR

TOS_INCLUDE = $(realpath ./include)
TOS_BASEMAKE = $(realpath ./base.mk)
TOS_DEPCHECK = $(realpath ./depcheck.mk)

export TOS_DEPCHECK TOS_BASEMAKE TOS_INCLUDE

.PHONY: all
.PHONY: boot include
.PHONY: src
.PHONY: images
.PHONY: compressed-img
.PHONY: clean
.PHONY: image-clean
.PHONY: hd

all: images

include $(TOS_BASEMAKE)

boot:
	make -C boot

src:
	make -C src

hd.img: hd.img.xz
	xz -dfk hd.img.xz

images: boot src hd.img
	dd if=hd.img of=part1.img bs=1024 skip=1024 count=69536
	debugfs -w -f copy_image.debugfs
	dd if=part1.img of=hd.img bs=1024 seek=1024 count=69536
	rm -fr part1.img

compressed-img:
	xz -zfk hd.img

clean:
	make -C boot clean
	make -C src clean

image-clean: compressed-img clean
	rm -fr hd.img

