include $(BASEMAKE)

OBJS = \
	multiboot.o \
	paging.o \
	idt.o \
	printing.o \
	kprintf.o \
	kmain.o

KERNEL_FILE = kernel.elf
KERNEL_SCRIPT_FILE = linkerScript
KERNEL_MAP_FILE = kernel.map

INTERRUPTS_ARCHIVE = interrupts/interrupts.a

.PHONY: all
.PHONY: $(SUBDIRS)
.PHONY: $(INTERRUPTS_ARCHIVE)
.PHONY: clean

all: $(KERNEL_FILE)

$(INTERRUPTS_ARCHIVE):
	make -C interrupts BASEMAKE='$(BASEMAKE)'

$(KERNEL_FILE): $(OBJS)
$(KERNEL_FILE): $(INTERRUPTS_ARCHIVE)
$(KERNEL_FILE): $(KERNEL_SCRIPT_FILE)
$(KERNEL_FILE): $(SUBDIRS)
	$(LD) $(LDFLAGS) -T $(KERNEL_SCRIPT_FILE) -Map $(KERNEL_MAP_FILE) -o $(KERNEL_FILE) $(OBJS) $(INTERRUPTS_ARCHIVE)

clean:
	rm -frv $(OBJS) $(KERNEL_FILE) $(KERNEL_MAP_FILE)
	make -C interrupts clean BASEMAKE='$(BASEMAKE)'

