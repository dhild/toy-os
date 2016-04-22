# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

CFLAGS += -ffreestanding -fno-builtin -nostdlib -nostdinc -mno-red-zone
CXXFLAGS += -ffreestanding -fno-builtin -nostdlib -nostdinc -mno-red-zone -nostdinc++
CFLAGS += -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow
CXXFLAGS += -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow

LDFLAGS = -melf_x86_64 -nostdlib -nodefaultlibs -z max-page-size=0x1000 --warn-common
AR += --target elf64-x86-64


CRTBEGIN_OBJ := $(shell $(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)g++ $(CFLAGS) -print-file-name=crtbegin.o)
CRTEND_OBJ := $(shell $(TOOLCHAIN_BIN)/$(TOOLCHAIN_PREFIX)g++ $(CFLAGS) -print-file-name=crtend.o)
# These are built by the archlib target
CRTI_OBJ = arch/x86_64/pc/crti.o
CRTN_OBJ = arch/x86_64/pc/crtn.o

KERNEL_OBJS = $(CRTI_OBJ) $(CRTBEGIN_OBJ)
KERNEL_OBJS += arch/x86_64/pc/archlib.a
KERNEL_OBJS += kernel/kernellib.a
KERNEL_OBJS += $(CRTEND_OBJ) $(CRTN_OBJ)

all: kernel.elf
.PHONY: all clean arch kernel

arch:
	$(MAKE) -C arch/x86_64/pc archlib.a crti.o crtn.o

kernel:
	$(MAKE) -C kernel kernellib.a

linker.ld: arch/x86_64/pc/linker.ld.S
	$(CC) $(CFLAGS) arch/x86_64/pc/linker.ld.S -o linker.ld -E -P -D__ASSEMBLY__ -DLINKERSCRIPT

kernel.elf: linker.ld arch kernel
	$(LD) $(LDFLAGS) -T linker.ld -o kernel.elf $(KERNEL_OBJS)
	$(OBJCOPY) --only-keep-debug kernel.elf kernel.sym
	$(OBJCOPY) --strip-debug kernel.elf kernel.bin

clean:
	$(MAKE) -C arch/x86_64/pc clean
	$(MAKE) -C kernel clean
	rm -f linker.ld kernel.elf
