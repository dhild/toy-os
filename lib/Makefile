TOS_BUILDSUBDIR = $(TOS_BUILDDIR)/lib

include $(TOS_BASEMAKE)

OBJS = string.o printf.o memory.o string2.o

OBJS := $(addprefix $(TOS_BUILDSUBDIR)/,$(OBJS))

LIB_ARCHIVE = $(TOS_BUILDDIR)/lib.a

all: $(LIB_ARCHIVE)

$(LIB_ARCHIVE): $(OBJS)
	@echo Creating standard library archive...
	$(TOS_AR) -cru $(LIB_ARCHIVE) $(OBJS)
	$(TOS_RANLIB) $(LIB_ARCHIVE)

clean:
	$(RM) -f $(OBJS) $(LIB_ARCHIVE)
