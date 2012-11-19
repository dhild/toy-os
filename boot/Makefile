include $(TOS_BASEMAKE)

OBJS := multiboot.o paging.o

KERNEL_FILE := kernel.elf
KERNEL_SCRIPT_FILE := kernel.ld
KERNEL_MAP_FILE := kernel.map

KERNEL_SRCS := $(OBJS)

kernel_link := $(TOS_LD) $(LDFLAGS) \
               -T $(KERNEL_SCRIPT_FILE) \
               -Map $(KERNEL_MAP_FILE) \
               -o $(KERNEL_FILE) \
               $(KERNEL_SRCS)

.PHONY: all
.PHONY: clean

all: $(KERNEL_FILE)

$(KERNEL_FILE): $(KERNEL_SRCS) $(KERNEL_SCRIPT_FILE)
	$(kernel_link)

clean:
	rm -fr $(OBJS) $(KERNEL_FILE) $(KERNEL_MAP_FILE) $(KERNEL_SCRIPT_FILE)
