 SHELL = /bin/bash
MAKEFLAGS += -rR

all: .depcheck

.SUFFIXES:
.SUFFIXES: .c .cpp .asm .o .d .ld .ld.S

Q := 
CROSS_COMPILE := x86_64-elf-
TOS_CPP = $(Q)$(CROSS_COMPILE)cpp
TOS_CC = $(Q)$(CROSS_COMPILE)gcc
TOS_CXX = $(Q)$(CROSS_COMPILE)g++
TOS_LD = $(Q)$(CROSS_COMPILE)ld
TOS_AR = $(Q)$(CROSS_COMPILE)ar
TOS_RANLIB = $(Q)$(CROSS_COMPILE)ranlib
TOS_NASM = $(Q)nasm
TOS_OBJCOPY = $(Q)$(CROSS_COMPILE)objcopy

RM = $(Q)rm
MKDIR = $(Q)mkdir
MAKE = $(Q)make
XZ = $(Q)xz
DD = $(Q)dd
DEBUGFS = $(Q)debugfs

WARNING_FLAGS := -Wall -Wextra -Werror -pedantic
STANDALONE_FLAGS := -nostdlib -nostartfiles -nodefaultlibs -ffreestanding
CONVENTION_FLAGS := -fno-exceptions -fno-stack-protector -mno-red-zone
MODE_FLAGS := -m64 -mcmodel=large -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow
COMMON_FLAGS := -pipe
DEBUGGING_FLAGS := -g
CPPFLAGS += $(WARNING_FLAGS) $(COMMON_FLAGS)
CPPFLAGS += -I $(TOS_INCLUDE)
CFLAGS += $(STANDALONE_FLAGS) $(CONVENTION_FLAGS) $(MODE_FLAGS) $(COMMON_FLAGS) $(DEBUGGING_FLAGS)
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

all: .pre .depcheck

.pre:
ifeq ($(wildcard $(TOS_BUILDSUBDIR)),)
	$(MKDIR) -p $(TOS_BUILDSUBDIR)
endif

OBJS := $(addprefix $(TOS_BUILDSUBDIR)/,$(OBJS))

$(TOS_BUILDSUBDIR)/%.o: %.c
	$(cmd_cc_o_c)

$(TOS_BUILDSUBDIR)/%.o: %.cpp
	$(cmd_cxx_o_cpp)

$(TOS_BUILDSUBDIR)/%.o: %.asm
	$(cmd_nasm_d_asm)
	$(cmd_nasm_o_asm)

$(TOS_BUILDSUBDIR)/%.ld: %.ld.S
	$(cmd_cpp_ld_ldS)

.depcheck:
	@echo "DEPFILES=\$$(wildcard \$$(addsuffix .d, \$${OBJS}))" >.dep.inc; \
	echo "ifneq (\$${DEPFILES},)" >>.dep.inc; \
	echo "include \$${DEPFILES}" >>.dep.inc; \
	echo "endif" >>.dep.inc;
.dep.inc: .depcheck

clean: .depclean
.depclean:
	$(RM) -fr .dep.inc $(wildcard $(addsuffix .d, ${OBJS}))

ifneq ($(wildcard .dep.inc),)
include .dep.inc
endif


