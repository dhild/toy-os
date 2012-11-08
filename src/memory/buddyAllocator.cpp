#include "buddyAllocator.h"
#include "kprintf.h"

using namespace buddy;

BuddyAllocator::BuddyAllocator(void * loc, size_t size) : start((qword)loc) {
  for (size_t i = 0; i < BUDDY_MAX_ORDER; i++)
    blocks[i].nextFree = NULL;

  while (size > BUDDY_PAGE_SIZE(0)) {
    size_t order = size / BUDDY_PAGE_SIZE(0);
    if (order >= BUDDY_MAX_ORDER)
      order = BUDDY_MAX_ORDER - 1;

    insertFreePage(loc, order);
    loc = (void*)((size_t)loc + BUDDY_PAGE_SIZE(order));
    size -= BUDDY_PAGE_SIZE(order);
  }

  size_t count = size / BUDDY_PAGE_SIZE(0);
  size_t alloc_size = count * sizeof(size_t);
  for (size_t i = 0; i < BUDDY_MAX_ORDER; i++)
    if (alloc_size <= BUDDY_PAGE_SIZE(i))
      allocations = (size_t*)(allocatePage(i));
  allocations[((qword)allocations - (qword)start) / BUDDY_PAGE_SIZE(0)] = alloc_size;
}

void BuddyAllocator::insertFreePage(void* location, const size_t order) {
  PageList* nextFree = &(blocks[order]);
  PageList* loc = (PageList*)location;

  // Handle the case where the blocks[] entry is NULL.
  if (nextFree->nextFree == NULL) {
    loc->nextFree = NULL;
    blocks[order].nextFree = loc;
    return;
  }

  // Step through until we find the "proper" place in the free blocks.
  while ((qword)(nextFree->nextFree) < (qword)loc) {
    // If we encounter the end of the list, handle it.
    if (nextFree->nextFree == NULL) {
      loc->nextFree = NULL;
      nextFree->nextFree = loc;
      return;
    }
    // Otherwise, search the next element.
    nextFree = nextFree->nextFree;
  }
  // If we get here, then the next item is past the location given.
  loc->nextFree = nextFree->nextFree;
  nextFree->nextFree = loc;
}

bool BuddyAllocator::compactFromOrder(const size_t order) {
  if (order >= (BUDDY_MAX_ORDER - 1))
    return false;

  bool compacted = false;

  PageList* next = &(blocks[order]);

  while ((next->nextFree != NULL) && ((qword)(next->nextFree) != NULL)) {
    if ((qword)next->nextFree == ((qword)(next->nextFree->nextFree) ^ BUDDY_PAGE_SIZE(order))) {
      insertFreePage((void*)next->nextFree, order + 1);
      compacted = true;
    }
    next = next->nextFree;
  }

  if (compacted)
    compactFromOrder(order + 1);

  return compacted;
}

BuddyAllocator::~BuddyAllocator() {

}

bool BuddyAllocator::splitPage(const size_t order) {
  if (order <= 0)
    return false;
  if (order >= BUDDY_MAX_ORDER)
    return false;

  if (blocks[order].nextFree == NULL)
    if (!splitPage(order + 1))
      return false;

  void* loc = (void*)(blocks[order].nextFree);
  void* loc2 = (void*)((qword)loc + BUDDY_PAGE_SIZE(order - 1));
  blocks[order].nextFree = blocks[order].nextFree->nextFree;

  insertFreePage(loc, order - 1);
  insertFreePage(loc2, order - 1);

  return true;
}

void* BuddyAllocator::allocatePage(const size_t order) {
  if (blocks[order].nextFree == NULL)
    if(!splitPage(order + 1))
      return NULL;

  void* loc = (void*)(blocks[order].nextFree);
  blocks[order].nextFree = blocks[order].nextFree->nextFree;

  return loc;
}

void* BuddyAllocator::allocate(const size_t size) {
  if (size <= BUDDY_MAX_PAGE_SIZE) {
    for (size_t i = 0; i < BUDDY_MAX_ORDER; i++) {
      if (size <= BUDDY_PAGE_SIZE(i)) {
	void* ret = allocatePage(i);
	if (ret != NULL)
	  allocations[((qword)ret - start) / BUDDY_PAGE_SIZE(0)] = size;
	return ret;
      }
    }
  }

  // If we get here, it is not so simple. We need multiple large pages.
  const size_t required = (size + BUDDY_MAX_PAGE_SIZE - 1) / BUDDY_MAX_PAGE_SIZE;
  size_t found = 1;
  PageList* nextFree = blocks[BUDDY_MAX_ORDER - 1].nextFree;
  PageList* previous = &(blocks[BUDDY_MAX_ORDER - 1]);
  void* loc = (void*)nextFree;

  while (found < required) {
    if (nextFree == NULL)
      return NULL;

    if ((qword)(nextFree->nextFree) == ((qword)nextFree + BUDDY_MAX_PAGE_SIZE))
      found++;
    else {
      loc = (void*)(nextFree->nextFree);
      previous = nextFree;
      found = 1;
    }
    nextFree = nextFree->nextFree;
  }
  previous->nextFree = nextFree->nextFree;
  allocations[((qword)loc - start) / BUDDY_PAGE_SIZE(0)] = size;
  return loc;
}

void BuddyAllocator::free(void * const location) {
  size_t size = allocations[((qword)location - start) / BUDDY_PAGE_SIZE(0)];

  if (size <= BUDDY_MAX_PAGE_SIZE) {
    for (int i = 0; i < BUDDY_MAX_ORDER; i++) {
      if (size <= BUDDY_PAGE_SIZE(i)) {
	insertFreePage(location, i);
        compactFromOrder(i);
      }
    }
  } else {
    void* loc = location;
    while(size > BUDDY_MAX_PAGE_SIZE) {
      insertFreePage(loc, BUDDY_MAX_ORDER - 1);
      loc = (void*)((qword)loc + BUDDY_MAX_PAGE_SIZE);
      size -= BUDDY_MAX_PAGE_SIZE;
    }
    if (size > 0)
      insertFreePage(loc, BUDDY_MAX_ORDER - 1);
  }

}
