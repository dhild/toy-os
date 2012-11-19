all: .depcheck

.SUFFIXES:
.SUFFIXES: .c .cpp .asm .o .d .ld .ld.S

CROSS_COMPILE := x86_64-elf-
TOS_CPP = $(CROSS_COMPILE)cpp
TOS_CC = $(CROSS_COMPILE)gcc
TOS_CXX = $(CROSS_COMPILE)g++
TOS_LD = $(CROSS_COMPILE)ld
TOS_AR = $(CROSS_COMPILE)ar
TOS_RANLIB = $(CROSS_COMPILE)ranlib
TOS_NASM = nasm

WARNING_FLAGS := -Wall -Wextra -Werror -pedantic
STANDALONE_FLAGS := -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -ffreestanding
CONVENTION_FLAGS := -fno-exceptions -fno-stack-protector -mno-red-zone
MODE_FLAGS := -m64 -mcmodel=large -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow
CPPFLAGS += $(WARNING_FLAGS)
CPPFLAGS += -I $(TOS_INCLUDE)
CFLAGS += $(STANDALONE_FLAGS) $(CONVENTION_FLAGS) $(MODE_FLAGS) -g
CXXFLAGS += $(CFLAGS) -fno-rtti
NASMARCH = elf64
NASMFLAGS += -f $(NASMARCH) -Werror
LDARCH = elf_x86_64
LDFLAGS += -m$(LDARCH) -nostdlib -nodefaultlibs -z max-page-size=0x1000
DEPSFLAGS = -MMD -MP -MF $@.d

cmd_cc_o_c = $(TOS_CC) $(CPPFLAGS) $(CFLAGS) $(DEPSFLAGS) -c -o $@ $<
cmd_cxx_o_cpp = $(TOS_CXX) $(CPPFLAGS) $(CXXFLAGS) $(DEPSFLAGS) -c -o $@ $<
cmd_nasm_d_asm = $(TOS_NASM) $(NASMFLAGS) -M $< > $@.d
cmd_nasm_o_asm = $(TOS_NASM) $(NASMFLAGS) -o $@ $<
cmd_cpp_ld_ldS = $(TOS_CPP) $(CPPFLAGS) -P -D__ASSEMBLY__ -DLINKERSCRIPT \
                  $(DEPSFLAGS) -o $@ $<

%.o: %.c
	$(cmd_cc_o_c)

%.o: %.cpp
	$(cmd_cxx_o_cpp)

%.o: %.asm
	$(cmd_nasm_d_asm)
	$(cmd_nasm_o_asm)

%.ld: %.ld.S
	$(cmd_cpp_ld_ldS)

include $(TOS_DEPCHECK)

