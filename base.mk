all: .depcheck

.SUFFIXES:
.SUFFIXES: .c .cpp .asm .o .d

CROSS_COMPILE = x86_64-elf-
TOS_CC = $(CROSS_COMPILE)gcc
TOS_CXX = $(CROSS_COMPILE)g++
TOS_LD = $(CROSS_COMPILE)ld
TOS_AR = $(CROSS_COMPILE)ar
TOS_RANLIB = $(CROSS_COMPILE)ranlib
TOS_NASM = nasm

WARNING_FLAGS = -Wall -Wextra -Werror
STANDALONE_FLAGS = -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -ffreestanding
CONVENTION_FLAGS = -fno-exceptions -fno-stack-protector -mno-red-zone
MODE_FLAGS = -m64 -mcmodel=large -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow
CFLAGS += $(WARNING_FLAGS) $(STANDALONE_FLAGS) $(CONVENTION_FLAGS) $(MODE_FLAGS) -g
CXXFLAGS += $(CFLAGS) -fno-rtti
NASMFLAGS += -f elf64 -Werror
LDFLAGS += -melf_x86_64 -nostdlib -nodefaultlibs -z max-page-size=0x1000

cmd_cc_o_c = $(TOS_CC) $(CFLAGS) -MMD -MP -MF $@.d -c -o $@ $<
cmd_cxx_o_cpp = $(TOS_CXX) $(CXXFLAGS) -MMD -MP -MF $@.d -c -o $@ $<
cmd_nasm_d_asm = $(TOS_NASM) $(NASMFLAGS) -M $< > $@.d
cmd_nasm_o_asm = $(TOS_NASM) $(NASMFLAGS) -o $@ $<

%.o: %.c
	$(cmd_cc_o_c)

%.o: %.cpp
	$(cmd_cxx_o_cpp)

%.o: %.asm
	$(cmd_nasm_d_asm)
	$(cmd_nasm_o_asm)

include $(TOS_DEPCHECK)

