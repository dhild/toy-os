TOS_BUILDSUBDIR = $(TOS_BUILDDIR)/interrupts

include $(TOS_BASEMAKE)

OBJS = interrupts.o

OBJS := $(addprefix $(TOS_BUILDSUBDIR)/,$(OBJS))

INTERRUPTS_ARCHIVE = $(TOS_BUILDDIR)/interrupts.a

all: $(INTERRUPTS_ARCHIVE)

$(INTERRUPTS_ARCHIVE): $(OBJS)
	@echo Creating interrupts archive...
	$(TOS_AR) -cru $(INTERRUPTS_ARCHIVE) $(OBJS)
	$(TOS_RANLIB) $(INTERRUPTS_ARCHIVE)

clean:
	$(RM) -f $(OBJS) $(INTERRUPTS_ARCHIVE)

