CFLAGS += -I..

include $(TOS_BASEMAKE)

OBJS := buddyAllocator.o paging.o pagingInternals.o
OBJS += buddyAllocatorTest.o

MEMORY_ARCHIVE = memory.a

all: $(MEMORY_ARCHIVE)

$(MEMORY_ARCHIVE): $(OBJS)
	$(TOS_AR) -cruv $(MEMORY_ARCHIVE) $(OBJS)
	$(TOS_RANLIB) $(MEMORY_ARCHIVE)

clean:
	rm -fr $(OBJS) $(MEMORY_ARCHIVE)

