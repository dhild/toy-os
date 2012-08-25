SHELL = /bin/sh
CC = x86_64-elf-gcc
CXX = x86_64-elf-g++
LD = x86_64-elf-ld
AR = x86_64-elf-ar
RANLIB = x86_64-elf-ranlib
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
NASMFLAGS = -f elf64 -Werror
LDFLAGS = -melf_x86_64 -nostdlib -nodefaultlibs -z max-page-size=0x1000

all: .depcheck

.SUFFIXES:
.SUFFIXES: .c .cpp .asm .o .d

%.o: %.c
	$(CC) $(CFLAGS) -MMD -MP -MF $@.d -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -MMD -MP -MF $@.d -c -o $@ $<

%.o: %.asm
	$(NASM) $(NASMFLAGS) -M $< > $@.d
	$(NASM) $(NASMFLAGS) -o $@ $<
