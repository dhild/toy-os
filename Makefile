SHELL = /bin/bash
MAKEFLAGS += -rR

TOS_BUILDDIR = $(abspath ./build/)
TOS_INCLUDE := $(abspath ./include/)
TOS_BASEMAKE := $(abspath ./base.mk)
TOS_DEPCHECK := $(abspath ./depcheck.mk)
TOS_BUILDSUBDIR := .

export TOS_DEPCHECK TOS_BASEMAKE TOS_INCLUDE TOS_BUILDDIR

SUBDIRS = boot lib kernel

.PHONY: all
.PHONY: $(SUBDIRS)
.PHONY: src
.PHONY: images
.PHONY: compressed-img
.PHONY: clean
.PHONY: image-clean
.PHONY: hd

include $(TOS_BASEMAKE)

all: images

lib:
	$(MAKE) -C lib

kernel:
	$(MAKE) -C kernel

boot: lib kernel
	$(MAKE) -C boot

hd.img: hd.img.xz
	$(XZ) -dfk hd.img.xz

images: $(SUBDIRS) hd.img
	$(DD) if=hd.img of=part1.img bs=1024 skip=1024 count=69536
	$(DEBUGFS) -w -f copy_image.debugfs
	$(DD) if=part1.img of=hd.img bs=1024 seek=1024 count=69536
	$(RM) -fr part1.img

compressed-img:
	$(XZ) -zfk hd.img

clean:
	$(MAKE) -C kernel clean
	$(MAKE) -C boot clean
	$(MAKE) -C lib clean
	$(RM) -fr $(TOS_BUILDDIR)

image-clean: compressed-img clean
	$(RM) -fr hd.img

