include $(TOS_BASEMAKE)

OBJS := multiboot.o paging.o idt.o printing.o kprintf.o kmain.o

KERNEL_FILE = kernel.elf
KERNEL_SCRIPT_FILE = linkerScript
KERNEL_MAP_FILE = kernel.map
EXTRA_LDFLAGS := -T $(KERNEL_SCRIPT_FILE)
EXTRA_LDFLAGS += -Map $(KERNEL_MAP_FILE)
EXTRA_LDFLAGS += -o $(KERNEL_FILE)

INTERRUPTS_ARCHIVE = interrupts/interrupts.a
MEMORY_ARCHIVE = memory/memory.a
KERNEL_SRCS = $(OBJS) $(INTERRUPTS_ARCHIVE) $(MEMORY_ARCHIVE)
KERNEL_DEPS = $(KERNEL_SRCS) $(KERNEL_SCRIPT_FILE)

kernel_link = $(TOS_LD) $(LDFLAGS) $(EXTRA_LDFLAGS)  $(KERNEL_SRCS)

SUBDIRS = interrupts memory

.PHONY: all
.PHONY: $(SUBDIRS)
.PHONY: clean

all: $(KERNEL_FILE)

interrupts:
	make -C interrupts

memory:
	make -C memory

$(INTERRUPTS_ARCHIVE): interrupts
$(MEMORY_ARCHIVE): memory

$(KERNEL_FILE): $(KERNEL_DEPS)
	$(kernel_link)

clean:
	rm -fr $(OBJS) $(KERNEL_FILE) $(KERNEL_MAP_FILE)
	make -C interrupts clean
	make -C memory clean

