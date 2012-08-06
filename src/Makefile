CXX=g++
AS=nasm
LINK=ld

WARNINGS=-Wall -Wextra -Werror
STANDALONE=-nostdlib -fno-builtin -nostartfiles -nodefaultlibs
CFLAGS=-m64 $(WARNINGS) $(STANDALONE) \
	-fno-exceptions -fno-stack-protector -mno-red-zone \
	-I../include
CXXFLAGS=$(CFLAGS) -fno-rtti
ASFLAGS=-f elf64
LDFLAGS=-melf_x86_64 -nostdlib -nodefaultlibs -z max-page-size=0x1000

OBJS= 	multiboot.o \
	multiboot_header.o \
	string.o \
	boot.o \
	kmain.o \
	kprintf.o \
	idt.o \
	interrupts.o

TARGET=kernel.elf

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LINK) $(LDFLAGS) -T linkerScript -o $(TARGET) $(OBJS)

%.o: %.cpp
	$(CXX) -c -o $@ $< $(CFLAGS)

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)
