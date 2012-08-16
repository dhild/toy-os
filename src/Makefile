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

SUBDIRS = interrupts

.PHONY: all
.PHONY: $(SUBDIRS)
.PHONY: $(INTERRUPTS_ARCHIVE)
.PHONY: clean

all: $(KERNEL_FILE)

multiboot.o: multiboot.asm $(KERNEL_SCRIPT_FILE)
paging.o: paging.asm multiboot.asm
idt.o: idt.asm
printing.o: printing.asm multiboot.asm
kprintf.o: kprintf.cpp types.h main.h kprintf.h
kmain.o: kmain.cpp types.h main.h kprintf.h multiboot.h

interrupts:
	make -C interrupts BASEMAKE='$(BASEMAKE)'

$(INTERRUPTS_ARCHIVE): interrupts

$(KERNEL_FILE): $(OBJS)
$(KERNEL_FILE): $(INTERRUPTS_ARCHIVE)
$(KERNEL_FILE): $(KERNEL_SCRIPT_FILE)
$(KERNEL_FILE): $(SUBDIRS)
	$(LD) $(LDFLAGS) -T $(KERNEL_SCRIPT_FILE) -Map $(KERNEL_MAP_FILE) -o $(KERNEL_FILE) $(OBJS) $(INTERRUPTS_ARCHIVE)

clean:
	rm -frv $(OBJS) $(KERNEL_FILE) $(KERNEL_MAP_FILE)
	make -C interrupts clean BASEMAKE='$(BASEMAKE)'

