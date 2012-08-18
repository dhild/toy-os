#ifndef BUDDY_ALLOCATOR_H
#define BUDDY_ALLOCATOR_H

#include "types.h"

// Smallest block size is X bytes
#define BUDDY_SMALLEST_BLOCK 4096
// There are X levels of allocation, each twice as big as the last
#define BUDDY_LEVELS 4

namespace buddy {

  typedef sbyte block_order_t;

  enum BlockUsage {
    FREE,
    INUSE,
    SPLIT
  };

  class Block {
  private:
    Block(const Block&);
    static qword* blockSizes;
    static bool initialized;
    static void initialize();

    void * const location;
    const block_order_t order;
    BlockUsage usage;

  public:
    Block(void*, const block_order_t);
    ~Block();
    void setUsed(const bool inUse) { this->usage = inUse ? INUSE : FREE; }
    bool isUsed() { return (this->usage != FREE); }
    BlockUsage getUsage() { return usage; }
    void* getLocation() { return location; }
    block_order_t getOrder() { return order; }
    bool isMaxOrder() { return (order + 1) == BUDDY_LEVELS; }

    void split(Block*, Block*);

    qword getSize();
    static qword getSize(const block_order_t);
    static qword maxSize() { return getSize(BUDDY_LEVELS - 1); }

    void* operator new(qword, void*);
    void operator delete(void*);
  };

  class BlockManager {
  private:
    void* const start;
    const qword size;
    
    Block* blocks[BUDDY_LEVELS];
    qword counts[BUDDY_LEVELS];

    void checkMerge(Block*);
  public:
    BlockManager(void* const location, const qword size);
    ~BlockManager();

    void* allocate(qword);
    void free(void*);
  };

}

#endif
