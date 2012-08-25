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
MEMORY_ARCHIVE = memory/memory.a

SUBDIRS = interrupts memory

.PHONY: all
.PHONY: $(SUBDIRS)
.PHONY: clean

all: $(KERNEL_FILE)

interrupts:
	make -C interrupts BASEMAKE='$(BASEMAKE)' DEPCHECK='$(DEPCHECK)'

memory:
	make -C memory BASEMAKE='$(BASEMAKE)' DEPCHECK='$(DEPCHECK)'

$(INTERRUPTS_ARCHIVE): interrupts
$(MEMORY_ARCHIVE): memory

$(KERNEL_FILE): $(OBJS)
$(KERNEL_FILE): $(INTERRUPTS_ARCHIVE)
$(KERNEL_FILE): $(MEMORY_ARCHIVE)
$(KERNEL_FILE): $(KERNEL_SCRIPT_FILE)
$(KERNEL_FILE):
	$(LD) $(LDFLAGS) -T $(KERNEL_SCRIPT_FILE) -Map $(KERNEL_MAP_FILE) -o $(KERNEL_FILE) $(OBJS) $(INTERRUPTS_ARCHIVE) $(MEMORY_ARCHIVE)

clean:
	rm -fr $(OBJS) $(KERNEL_FILE) $(KERNEL_MAP_FILE)
	make -C interrupts clean BASEMAKE='$(BASEMAKE)' DEPCHECK='$(DEPCHECK)'
	make -C memory clean BASEMAKE='$(BASEMAKE)' DEPCHECK='$(DEPCHECK)'

include $(DEPCHECK)
