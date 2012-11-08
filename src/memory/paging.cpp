#include "paging.h"
#include "kprintf.h"

bool initialized = false;



#ifdef PAGING_USE_BUDDY_ALLOCATOR
#include "buddyAllocator.h"

buddy::BuddyAllocator allocatorLow;
buddy::BuddyAllocator allocatorHigh;


void paging::initialize() {
  if (initialized)
    return;

  setupPagingInternals();

  // Now initialize the allocator for the rest of free memory:
  allocatorLow.initialize(getMemoryStart(), getMemorySize());
  allocatorHigh.initialize(lowToHigh(getMemoryStart()), getMemorySize());

  initialized = true;
}

void * paging::allocate(const size_t size) {
  if (initialized == false)
    initialize();

  return allocator->allocate(size);
}

void paging::free(void * const loc) {
  if (initialized == false)
    initialize();

  allocator->free(loc);
}
#else
void paging::initialize() {
  if (initialized)
    return;

  setupPagingInternals();

  initialized = true;
}

void * paging::allocate(const size_t) {
  if (initialized == false)
    initialize();

  return NULL;
}

void paging::free(void * const) {
  if (initialized == false)
    initialize();
}
#endif
