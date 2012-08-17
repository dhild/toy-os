#ifndef BUDDY_ALLOCATOR_H
#define BUDDY_ALLOCATOR_H

// Smallest block size is X bytes
#define BUDDY_SMALLEST_BLOCK 4096
// There are X levels of allocation, each twice as big as the last
#define BUDDY_LEVELS 4

namespace buddy {

  typedef block_order_t sbyte;

  class Block {
  private:
    Block(const Block&);
    static Block* blocks;
    static qword blockCount;
    static qword* blockSizes;
    static bool initialized;
    static void initialize();

    static Block* getFree(const block_order_t);
    static Block* findByLoc(const void*);

    void split();

    void* location;
    block_order_t order;
    bool inUse;

  public:
    Block(const void*, const block_order_t);
    ~Block();
    void setUsed(const bool b) { this->inUse = b; }
    bool isUsed() { return this->inUse; }

    static qword getSize(const block_order_t);
    static qword maxSize() { return getSize(BUDDY_LEVELS - 1); }

    void* operator new(qword);
    void operator delete(void*);

    static void* requestMemory(qword);
    static void releaseMemory(void*);
  };

}

#endif
