HOST?=$(shell ../scripts/default-host.sh)
HOSTARCH:=$(shell ../scripts/target-triplet-to-arch.sh $(HOST))

CFLAGS?=-O2 -g
CPPFLAGS?=
LDFLAGS?=
LIBS?=

DESTDIR?=
PREFIX?=/usr/local
EXEC_PREFIX?=$(PREFIX)
BOOTDIR?=$(EXEC_PREFIX)/boot
INCLUDEDIR?=$(PREFIX)/include

CFLAGS:=$(CFLAGS) -ffreestanding -fbuiltin -Wall -Wextra -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow
CPPFLAGS:=$(CPPFLAGS) -D__is_toyos_kernel -Iinclude
LDFLAGS:=$(LDFLAGS) -z max-page-size=0x1000
LIBS:=$(LIBS) -nostdlib -lk -L../libc

ARCHDIR:=arch/$(HOSTARCH)

include $(ARCHDIR)/make.config

CFLAGS:=$(CFLAGS) $(KERNEL_ARCH_CFLAGS)
CPFLAGS:=$(CPPFLAGS) $(KERNEL_ARCH_CPPFLAGS)
LDFLAGS:=$(LDFLAGS) $(KERNEL_ARCH_LDFLAGS)
LIBS:=$(LIBS) $(KERNEL_ARCH_LIBS)

OBJS:=\
$(KERNEL_ARCH_OBJS) \
kernel/kernel.o \

CRTI_OBJ:=$(ARCHDIR)/crti.o
CRTBEGIN_OBJ:=$(shell $(HOST)-gcc $(CFLAGS) $(LDFLAGS) -print-file-name=crtbegin.o)
CRTEND_OBJ:=$(shell $(HOST)-gcc $(CFLAGS) $(LDFLAGS) -print-file-name=crtend.o)
CRTN_OBJ:=$(ARCHDIR)/crtn.o

ALL_OUR_OBJS:=\
$(CRTI_OBJ) \
$(OBJS) \
$(CRTN_OBJ) \

OBJ_LINK_LIST:=\
$(CRTI_OBJ) \
$(CRTBEGIN_OBJ) \
$(OBJS) \
$(CRTEND_OBJ) \
$(CRTN_OBJ) \

all: toy-os.kernel

.PHONY: all clean install install-headers install-kernel

$(ARCHDIR)/linker.ld: $(ARCHDIR)/linker.ld.S
	$(CPP) $< -o $@ $(CPPFLAGS) -P -D__ASSEMBLY__ -DLINKERSCRIPT

toy-os.kernel: $(OBJ_LINK_LIST) $(ARCHDIR)/linker.ld
	$(LD) -T $(ARCHDIR)/linker.ld -o $@ $(OBJ_LINK_LIST) $(LDFLAGS) $(LIBS)

%.o: %.c
	$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

%.o: %.cpp
	$(CXX) -c $< -o $@ $(CXXFLAGS) $(CFLAGS) $(CPPFLAGS)

%.o: %.S
	$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

%.o: %.asm
	$(NASM) $< -o $@

clean:
	rm -f toy-os.kernel $(ARCHDIR)/linker.ld $(OBJS) $(ALL_OUR_OBJS) *.o */*.o */*/*.o

install: install-headers install-kernel

install-headers:
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	cp -RTv include $(DESTDIR)$(INCLUDEDIR)

install-kernel: toy-os.kernel
	mkdir -p $(DESTDIR)$(BOOTDIR)
	cp toy-os.kernel $(DESTDIR)$(BOOTDIR)
