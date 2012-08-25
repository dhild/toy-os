#include "paging.h"
#include "kprintf.h"

#ifdef PAGING_USE_BUDDY_ALLOCATOR
#include "buddyAllocator.h"
#endif

bool initialized = false;

#ifdef PAGING_USE_BUDDY_ALLOCATOR
buddy::BuddyAllocator* allocator;
#endif

void paging::initialize() {
  if (initialized)
    return;

  setupPagingInternals();

  // Now initialize the allocator for the rest of free memory:
#ifdef PAGING_USE_BUDDY_ALLOCATOR
  void * loc = (void *)((size_t)getMemoryStart() + sizeof(buddy::BuddyAllocator));
  allocator =
    new(getMemoryStart()) buddy::BuddyAllocator(loc, getMemorySize() - sizeof(buddy::BuddyAllocator));
#endif

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
