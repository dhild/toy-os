#ifndef BUDDY_ALLOCATOR_H
#define BUDDY_ALLOCATOR_H

#include "types.h"

// Smallest block size is X bytes
#define BUDDY_SMALLEST_BLOCK (4 * 1024)
// There are X levels of allocation, each twice as big as the last
#define BUDDY_LEVELS 4
#define BUDDY_LARGEST_BLOCK (8 * BUDDY_SMALLEST_BLOCK)

namespace buddy {

  enum BlockUsage {
    FREE,
    INUSE,
    SPLIT
  };

  class BuddyAllocator {
  private:
    BuddyAllocator(const BuddyAllocator&);

    void * const mem_start;
    const size_t mem_size;
    BlockUsage* blocks[BUDDY_LEVELS];
    size_t counts[BUDDY_LEVELS];

    bool checkMerges();
    void split(const qword level, const size_t index);
    void * getLocation(const size_t level, const size_t index);
  public:
    BuddyAllocator(void * location, const size_t size);
    ~BuddyAllocator();

    void * allocate(const size_t);
    void free(void * const location);
  };

}

#endif
