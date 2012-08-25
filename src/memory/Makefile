include $(BASEMAKE)

CFLAGS += -I..

OBJS = \
	buddyAllocator.o \
	paging.o

MEMORY_ARCHIVE = memory.a

all: $(MEMORY_ARCHIVE)

$(MEMORY_ARCHIVE): $(OBJS)
	$(AR) -cruv $(MEMORY_ARCHIVE) $(OBJS)
	$(RANLIB) $(MEMORY_ARCHIVE)

clean:
	rm -frv $(OBJS) $(MEMORY_ARCHIVE)

include $(DEPCHECK)
