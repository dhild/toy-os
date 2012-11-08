#ifndef BUDDY_ALLOCATOR_H
#define BUDDY_ALLOCATOR_H

#include "types.h"

/** The buddy allocation system:
 *
 * This system is used to allocate large chunks of a single block of memory.
 * After each allocation is finished here, the caller is responsible for using
 * it efficiently, i.e. splitting it up for further use.
 */
#define BUDDY_PAGE_SIZE(order) ((1 << (order)) * 4 * 1024)
// There are X levels of allocation, each twice as big as the last
#define BUDDY_MAX_ORDER 8
#define BUDDY_MAX_PAGE_SIZE BUDDY_PAGE_SIZE(BUDDY_MAX_ORDER - 1)

namespace buddy {

  struct PageList {
    PageList* nextFree;
  };

  class BuddyAllocator {
  private:
    BuddyAllocator(const BuddyAllocator&);

    PageList blocks[BUDDY_MAX_ORDER];
    size_t* allocations;
    const qword start;

    void insertFreePage(void* loc, const size_t order);
    bool compactFromOrder(const size_t order);
    void* allocatePage(const size_t order);
    bool splitPage(const size_t order);

  public:
    BuddyAllocator(void * location, size_t size);
    ~BuddyAllocator();

    void * allocate(const size_t);
    void free(void * const location);
  };

}

#endif
