default_target: all
.PHONY: default_target

# Export all variables to sub-makes:
export

SHELL = /bin/sh
TOOLCHAIN_BIN=~/toolchain/bin
TOOLCHAIN_PREFIX=x86_64-elf-

CC = clang
CXX = clang++
LD = $(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)ld
AR = $(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)ar
RANLIB = $(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)ranlib
OBJCOPY = $(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)objcopy
NASM = nasm -f elf64

CFLAGS = -Wall -Wextra -Werror -g
CFLAGS += -march=x86-64 -m64 -mcmodel=large
CXXFLAGS = $(CFLAGS) -fno-rtti -std=c++11 -fno-exceptions
NASMFLAGS = -Werror

DEPDIR := .d


.SUFFIXES:
.SUFFIXES: .c .cpp .nasm .o .d

.PHONY: all clean kernel qemu

all: kernel kernel.iso

kernel:
	$(MAKE) -C kernel

clean:
	$(MAKE) -C kernel clean
	rm -f kernel.iso

$(shell mkdir -p $(DEPDIR) >/dev/null)
%.o : %.c
%.o : %.c $(DEPDIR)/%.d
	$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td -c -o $@ $<
	mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

%.o : %.cpp
%.o : %.cpp $(DEPDIR)/%.d
	$(CXX) $(CXXFLAGS) -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td -c -o $@ $<
	mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

%.o: %.nasm
	$(NASM) $(NASMFLAGS) -o $@ $<

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(SRCS)))


kernel.iso: kernel grub.cfg
	rm -fr /tmp/toyos-isodir
	mkdir -p /tmp/toyos-isodir/boot/grub
	cp grub.cfg /tmp/toyos-isodir/boot/grub/grub.cfg
	cp kernel/kernel.bin /tmp/toyos-isodir/boot/kernel.bin
	grub-mkrescue -o kernel.iso /tmp/toyos-isodir

OVMF.fd:
	wget -O ovmf.zip http://downloads.sourceforge.net/project/edk2/OVMF/OVMF-X64-r15214.zip
	unzip ovmf.zip OVMF.fd

qemu: kernel.iso OVMF.fd
	qemu-system-x86_64 -d int -no-reboot -s -bios OVMF.fd -m 2048 -cdrom kernel.iso
