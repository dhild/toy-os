SHELL = /bin/bash
MAKEFLAGS += -rR

TOS_BUILDDIR = $(abspath ./build/)
TOS_INCLUDE := $(abspath ./include/)
TOS_BASEMAKE := $(abspath ./base.mk)
TOS_DEPCHECK := $(abspath ./depcheck.mk)
TOS_BUILDSUBDIR := .

export TOS_DEPCHECK TOS_BASEMAKE TOS_INCLUDE TOS_BUILDDIR

SUBDIRS = include lib kernel

TEMP_DD_FILE := $(shell mktemp -u)

.PHONY: all
.PHONY: $(SUBDIRS)
.PHONY: src
.PHONY: images
.PHONY: extracted-img
.PHONY: compressed-img
.PHONY: clean
.PHONY: image-clean
.PHONY: hd

ifeq ($(wildcard hd.img),)
EXTRACT := extracted-img
else
EXTRACT :=
endif

include $(TOS_BASEMAKE)

KERNEL_FILE = $(TOS_BUILDDIR)/kernel.elf
KERNEL_SYMBOL_FILE = $(TOS_BUILDDIR)/kernel.sym
KERNEL_SCRIPT_FILE = $(TOS_BUILDDIR)/kernel.ld
KERNEL_MAP_FILE = $(TOS_BUILDDIR)/kernel.map
KERNEL_SRCS := $(TOS_BUILDDIR)/kernel.a \
               $(TOS_BUILDDIR)/lib.a

all: hd.img
	$(MAKE) hd.img

$(KERNEL_FILE): $(KERNEL_SRCS) $(KERNEL_SCRIPT_FILE)
	$(TOS_LD) $(LDFLAGS) -T $(KERNEL_SCRIPT_FILE) -Map $(KERNEL_MAP_FILE) -o $(KERNEL_FILE) $(KERNEL_SRCS)
	$(TOS_OBJCOPY) --only-keep-debug $(KERNEL_FILE) $(KERNEL_SYMBOL_FILE)
	$(TOS_OBJCOPY) --strip-debug $(KERNEL_FILE)

$(TOS_BUILDDIR)/kernel.a: kernel

$(TOS_BUILDDIR)/lib.a: lib

include:
	$(MAKE) -C include

lib: include
	$(MAKE) -C lib

kernel: include
	$(MAKE) -C kernel

extracted-img: hd.img.xz
	$(XZ) -dfk hd.img.xz

hd.img: $(KERNEL_FILE) $(EXTRACT)
	$(DD) if=hd.img of=$(TEMP_DD_FILE) bs=1024 skip=1024 count=69536
	$(DEBUGFS) -w -f copy_image.debugfs $(TEMP_DD_FILE)
	$(DD) if=$(TEMP_DD_FILE) of=hd.img bs=1024 seek=1024 count=69536
	$(RM) -fr $(TEMP_DD_FILE)

compressed-img:
	$(XZ) -zfk hd.img

clean:
	$(MAKE) -C include clean
	$(MAKE) -C kernel clean
	$(MAKE) -C lib clean
	$(RM) -fr $(KERNEL_FILE) $(KERNEL_MAP_FILE) $(KERNEL_SCRIPT_FILE) $(KERNEL_SYMBOL_FILE)
	$(RM) -fr $(TOS_BUILDDIR)

image-clean: compressed-img clean
	$(RM) -fr hd.img

