SHELL = /bin/sh
BINDIR=/home/dhild/cross/bin
CC = $(BINDIR)/x86_64-elf-gcc
CXX = $(BINDIR)/x86_64-elf-g++
LD = $(BINDIR)/x86_64-elf-ld
AR = $(BINDIR)/x86_64-elf-ar
RANLIB = $(BINDIR)/x86_64-elf-ranlib
NASM = nasm
SUDO = sudo
MOUNT = $(SUDO) mount
UMOUNT = $(SUDO) umount

WARNING_FLAGS = -Wall -Wextra -Werror
STANDALONE_FLAGS = -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -ffreestanding
CONVENTION_FLAGS = -fno-exceptions -fno-stack-protector -mno-red-zone
MODE_FLAGS = -m64 -mcmodel=large -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow
CFLAGS = $(WARNING_FLAGS) $(STANDALONE_FLAGS) $(CONVENTION_FLAGS) $(MODE_FLAGS) -g
CXXFLAGS = $(CFLAGS) -fno-rtti
NASMFLAGS = -f elf64
LDFLAGS = -melf_x86_64 -nostdlib -nodefaultlibs -z max-page-size=0x1000

.SUFFIXES:
.SUFFIXES: .c .cpp .asm .o .d

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CXX) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

%.d: %.asm

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.o: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $<
