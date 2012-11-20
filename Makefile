SHELL = /bin/bash
MAKEFLAGS += -rR

TOS_BUILDDIR = $(abspath ./build/)
TOS_INCLUDE := $(abspath ./include/)
TOS_BASEMAKE := $(abspath ./base.mk)
TOS_DEPCHECK := $(abspath ./depcheck.mk)

export TOS_DEPCHECK TOS_BASEMAKE TOS_INCLUDE TOS_BUILDDIR

.PHONY: all
.PHONY: boot include interrupts
.PHONY: src
.PHONY: images
.PHONY: compressed-img
.PHONY: clean
.PHONY: image-clean
.PHONY: hd

all: images

include $(TOS_BASEMAKE)

interrupts:
	$(MAKE) -C interrupts

boot: interrupts
	$(MAKE) -C boot

src:
	$(MAKE) -C src

hd.img: hd.img.xz
	xz -dfk hd.img.xz

images: boot src hd.img
	dd if=hd.img of=part1.img bs=1024 skip=1024 count=69536
	debugfs -w -f copy_image.debugfs
	dd if=part1.img of=hd.img bs=1024 seek=1024 count=69536
	$(RM) -fr part1.img

compressed-img:
	$(xz) -zfk hd.img

clean:
	$(MAKE) -C interrupts clean
	$(MAKE) -C boot clean
	$(MAKE) -C src clean
	$(RM) -fr $(TOS_BUILDDIR)

image-clean: compressed-img clean
	$(RM) -fr hd.img

