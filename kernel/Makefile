TOS_BUILDSUBDIR = $(TOS_BUILDDIR)/kernel

include $(TOS_BASEMAKE)

OBJS = kmain.o

OBJS := $(addprefix $(TOS_BUILDSUBDIR)/,$(OBJS))

KERN_ARCHIVE = $(TOS_BUILDDIR)/kernel.a

all: $(KERN_ARCHIVE)

$(KERN_ARCHIVE): $(OBJS)
	@echo Creating kernel code archive...
	$(TOS_AR) -cru $(KERN_ARCHIVE) $(OBJS)
	$(TOS_RANLIB) $(KERN_ARCHIVE)

clean:
	$(RM) -f $(OBJS) $(KERN_ARCHIVE)
