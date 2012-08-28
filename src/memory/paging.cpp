#include "paging.h"
#include "kprintf.h"

#ifdef PAGING_USE_BUDDY_ALLOCATOR
#include "buddyAllocator.h"
#endif

bool initialized = false;

#ifdef PAGING_USE_BUDDY_ALLOCATOR
buddy::BuddyAllocator allocatorLow;
buddy::BuddyAllocator allocatorHigh;
#endif

void paging::initialize() {
  if (initialized)
    return;

  setupPagingInternals();

  // Now initialize the allocator for the rest of free memory:
#ifdef PAGING_USE_BUDDY_ALLOCATOR
  allocatorLow.initialize(getMemoryStart(), getMemorySize());
  allocatorHigh.initialize(lowToHigh(getMemoryStart()), getMemorySize());
#endif

  initialized = true;
}

void * paging::allocate(const size_t size) {
  if (initialized == false)
    initialize();

#ifdef PAGING_USE_BUDDY_ALLOCATOR
  return allocator->allocate(size);
#else
  return NULL;
#endif
}

void paging::free(void * const loc) {
  if (initialized == false)
    initialize();

#ifdef PAGING_USE_BUDDY_ALLOCATOR
  allocator->free(loc);
#endif
}
