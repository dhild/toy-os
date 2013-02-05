#include <stdlib.h>
#include <string.h>
#include <types.h>
#include "memory.h"

void* calloc(size_t num, size_t size) {
  void* ptr = malloc(num * size);
  if (ptr == NULL)
    return ptr;

  memset(ptr, 0, num * size);

  return ptr;
}

typedef struct {
  void* nextFree;
} PageList;

PageList blocks[BUDDY_MAX_ORDER];
size_t* allocations;
void* start;

void insertFreePage(void* location, const size_t order) {
  PageList* nextFree = &(blocks[order]);
  PageList* loc = (PageList*)location;

  // Handle the case where the blocks[] entry is NULL.
  if (nextFree->nextFree == NULL) {
    loc->nextFree = NULL;
    blocks[order].nextFree = loc;
    return;
  }

  // Step through until we find the "proper" place in the free blocks.
  while ((__u64)(nextFree->nextFree) < (__u64)loc) {
    // If we encounter the end of the list, handle it.
    if (nextFree->nextFree == NULL) {
      loc->nextFree = NULL;
      nextFree->nextFree = loc;
      return;
    }
    // Otherwise, search the next element.
    nextFree = (PageList*)(nextFree->nextFree);
  }
  // If we get here, then the next item is past the location given.
  loc->nextFree = nextFree->nextFree;
  nextFree->nextFree = loc;
}

bool splitPage(const size_t order) {
  if (order <= 0)
    return false;
  if (order >= BUDDY_MAX_ORDER)
    return false;

  if (blocks[order].nextFree == NULL)
    if (!splitPage(order + 1))
      return false;

  void* loc = (void*)(blocks[order].nextFree);
  void* loc2 = (void*)((__u64)loc + BUDDY_PAGE_SIZE(order - 1));
  blocks[order].nextFree = ((PageList*)(blocks[order].nextFree))->nextFree;

  insertFreePage(loc, order - 1);
  insertFreePage(loc2, order - 1);

  return true;
}

void* allocatePage(const size_t order) {
  if (blocks[order].nextFree == NULL)
    if(!splitPage(order + 1))
      return NULL;

  void* loc = (void*)(blocks[order].nextFree);
  blocks[order].nextFree = ((PageList*)(blocks[order].nextFree))->nextFree;

  return loc;
}

void initialize(void * loc, size_t size) {
  start = loc;
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
  allocations[((__u64)allocations - (__u64)start) / BUDDY_PAGE_SIZE(0)] = alloc_size;
}

bool compactFromOrder(const size_t order) {
  if (order >= (BUDDY_MAX_ORDER - 1))
    return false;

  bool compacted = false;

  PageList* next = &(blocks[order]);

  while ((next->nextFree != NULL) && ((__u64)(next->nextFree) != NULL)) {
    if ((__u64)next->nextFree == ((__u64)(((PageList*)(next->nextFree))->nextFree) ^ BUDDY_PAGE_SIZE(order))) {
      insertFreePage((void*)next->nextFree, order + 1);
      compacted = true;
    }
    next = (PageList*)(next->nextFree);
  }

  if (compacted)
    compactFromOrder(order + 1);

  return compacted;
}
void* allocate(const size_t size) {
  if (size <= BUDDY_MAX_PAGE_SIZE) {
    for (size_t i = 0; i < BUDDY_MAX_ORDER; i++) {
      if (size <= BUDDY_PAGE_SIZE(i)) {
	void* ret = allocatePage(i);
	if (ret != NULL)
	  allocations[((__u64)ret - (__u64)start) / BUDDY_PAGE_SIZE(0)] = size;
	return ret;
      }
    }
  }

  // If we get here, it is not so simple. We need multiple large pages.
  const size_t required = (size + BUDDY_MAX_PAGE_SIZE - 1) / BUDDY_MAX_PAGE_SIZE;
  size_t found = 1;
  PageList* nextFree = (PageList*)blocks[BUDDY_MAX_ORDER - 1].nextFree;
  PageList* previous = &(blocks[BUDDY_MAX_ORDER - 1]);
  void* loc = (void*)nextFree;

  while (found < required) {
    if (nextFree == NULL)
      return NULL;

    if ((__u64)(nextFree->nextFree) == ((__u64)nextFree + BUDDY_MAX_PAGE_SIZE))
      found++;
    else {
      loc = (void*)(nextFree->nextFree);
      previous = nextFree;
      found = 1;
    }
    nextFree = (PageList*)nextFree->nextFree;
  }
  previous->nextFree = nextFree->nextFree;
  allocations[((__u64)loc - (__u64)start) / BUDDY_PAGE_SIZE(0)] = size;
  return loc;
}

void free(void * const location) {
  size_t size = allocations[((__u64)location - (__u64)start) / BUDDY_PAGE_SIZE(0)];

  if (size <= BUDDY_MAX_PAGE_SIZE) {
    for (size_t i = 0; i < BUDDY_MAX_ORDER; i++) {
      if (size <= BUDDY_PAGE_SIZE(i)) {
	insertFreePage(location, i);
        compactFromOrder(i);
      }
    }
  } else {
    void* loc = location;
    while(size > BUDDY_MAX_PAGE_SIZE) {
      insertFreePage(loc, BUDDY_MAX_ORDER - 1);
      loc = (void*)((__u64)loc + BUDDY_MAX_PAGE_SIZE);
      size -= BUDDY_MAX_PAGE_SIZE;
    }
    if (size > 0)
      insertFreePage(loc, BUDDY_MAX_ORDER - 1);
  }

}
