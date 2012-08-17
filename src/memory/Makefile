include $(BASEMAKE)

OBJS = \
	buddyAllocator.o \
	stackAllocator.o \
	paging.o

MEMORY_ARCHIVE = memory.a

all: $(MEMORY_ARCHIVE)

$(OBJS): memory.h
buddyAllocator.o: buddyAllocator.cpp buddyAllocator.h
stackAllocator.o: stackAllocator.cpp
paging.o: paging.cpp paging.h


$(MEMORY_ARCHIVE): $(OBJS)
	$(AR) -cruv $(MEMORY_ARCHIVE) $(OBJS)
	$(RANLIB) $(MEMORY_ARCHIVE)

clean:
	rm -frv $(OBJS) $(MEMORY_ARCHIVE)
