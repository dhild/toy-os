TOS_BUILDSUBDIR = $(TOS_BUILDDIR)/boot
OBJS = multiboot.o paging.o idt.o console.o interrupts.o
CPPFLAGS += -I.
include $(TOS_BASEMAKE)

KERNEL_FILE = $(TOS_BUILDDIR)/kernel.elf
KERNEL_SYMBOL_FILE = $(TOS_BUILDDIR)/kernel.sym
KERNEL_SCRIPT_FILE = $(TOS_BUILDSUBDIR)/kernel.ld
KERNEL_MAP_FILE = $(TOS_BUILDDIR)/kernel.map

KERNEL_SRCS = $(OBJS)
KERNEL_SRCS += $(TOS_BUILDDIR)/lib.a
KERNEL_SRCS += $(TOS_BUILDDIR)/kernel.a

kernel_link = $(TOS_LD) $(LDFLAGS) \
               -T $(KERNEL_SCRIPT_FILE) \
               -Map $(KERNEL_MAP_FILE) \
               -o $(KERNEL_FILE) \
               $(KERNEL_SRCS)

.PHONY: all
.PHONY: clean

all: $(KERNEL_FILE)

$(KERNEL_FILE): $(KERNEL_SRCS) $(KERNEL_SCRIPT_FILE)
	$(kernel_link)
	$(TOS_OBJCOPY) --only-keep-debug $(KERNEL_FILE) $(KERNEL_SYMBOL_FILE)
	$(TOS_OBJCOPY) --strip-debug $(KERNEL_FILE)

clean:
	$(RM) -fr $(OBJS) $(KERNEL_FILE) $(KERNEL_MAP_FILE) $(KERNEL_SCRIPT_FILE) $(KERNEL_SYMBOL_FILE)
