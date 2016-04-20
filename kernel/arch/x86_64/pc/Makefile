# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

crti.o: crti.nasm
crtn.o: crtn.nasm

OBJS = setup_gdt.o
OBJS += setup_idt.o
OBJS += setup_long_mode.o
OBJS += setup_paging.o

all: archlib.a crti.o crtn.o
.PHONY: all clean

archlib.a: $(OBJS)
	$(AR) -crs archlib.a $(OBJS)

clean:
	rm -f crti.o crtn.o archlib.a $(OBJS)

%.o: %.nasm
	$(NASM) $(NASMFLAGS) -o $@ $<
