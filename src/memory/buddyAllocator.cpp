#include "buddyAllocator.h"
#include "kprintf.h"

using namespace buddy;

BlockManager::BlockManager(void* const loc, const qword length) : start(loc), size(length) {
  // First, allocate enough arrays to store our blocks.
  qword remaining = size;
  void* pos = loc;
  for (block_order_t i = BUDDY_LEVELS - 1; i >= 0; i--) {
    counts[i] = remaining / Block::getSize(i);
    blocks[i] = (Block*)(pos);
    remaining -= counts[i] * sizeof(Block);
    pos = (void*)((qword)pos + counts[i] * sizeof(Block));
  }

  for (block_order_t i = 0; i < BUDDY_LEVELS; i++) {
    Block* b = blocks[i];
    const qword blockSize = Block::getSize(i);
    counts[i] = remaining / blockSize;
    for (qword j = 0; j < counts[i]; j++) {
      b = new(b) Block(pos, i);
      pos = (void*)((qword)pos + blockSize);
      b++;
    }
  }
}

BlockManager::~BlockManager() {
  for (block_order_t i = 0; i < BUDDY_LEVELS; i++) {
    Block* b = blocks[i];
    for (qword j = 0; j < counts[i]; j++) {
      b->Block::~Block();
      b++;
    }
  }
}

void* BlockManager::allocate(qword size) {
  block_order_t order = 0;
  while ((Block::getSize(order) < size) && (order < BUDDY_LEVELS))
    order++;

  if (order < BUDDY_LEVELS) {
    // The requested size fits within a single block.
    // Search for an available block.
    Block* b = blocks[order];
    for (qword i = 0; i < counts[order]; i++) {
      if (!b->isUsed()) {
	b->setUsed(true);
	return b->getLocation();
      }
    }
    log_error("Unable to allocate block!");
    return NULL;
  } else {
    // We need several blocks.
    qword blocksNeeded = (size - 1 + Block::maxSize()) / Block::maxSize();
    Block* start = blocks[BUDDY_LEVELS - 1];
    for (qword i = 0; i <= (counts[BUDDY_LEVELS - 1] - blocksNeeded); i++) {
      bool stillGood = true;
      Block* b = start;
      for (qword j = 0; j < blocksNeeded; j++) {
	if (b->isUsed()) {
	  stillGood = false;
	  break;
	}
	b++;
      }
      if (stillGood) {
	// Awesome! We have the needed blocks!
	void* mem = start->getLocation();
	start->setUsed(true);
	b = start;
	b++;
	for (qword j = 0; j < blocksNeeded; j++) {
	  b->setUsed(true);
	  start++;
	  b++;
	}
	return mem;
      }
      start++;
    }
  }
  log_error("Failed to allocate memory!");
  return NULL;
}

void BlockManager::checkMerge(Block* b) {
  if (b == NULL)
    return;

  if (b->isUsed())
    return;

  if (b->isMaxOrder())
    return; // No recombination possible.

  // We're good, check the buddy block.
  //const qword bIndex = ((qword)(b->getLocation()) - (qword)(this->start)) / b->getSize();
}

void BlockManager::free(void*) {
}

bool Block::initialized = false;

void Block::initialize() {
  qword size = BUDDY_SMALLEST_BLOCK;
  for (block_order_t i = 0; i < BUDDY_LEVELS; i++) {
    blockSizes[i] = size;
    size *= 2;
  }
  initialized = true;
}

Block::Block(void* loc, const block_order_t o)
  : location(loc), order(o), usage(FREE) {}

Block::~Block() {}

void Block::split(Block* a, Block* b) {
  const void* low = this->location;
  const void* high = (void*)((qword)low + this->getSize());
  if ((a->location < low) || (a->location > high) ||
      (b->location < low) || (b->location > high))
    return;

  this->usage = SPLIT;
}

qword Block::getSize() {
  qword size = BUDDY_SMALLEST_BLOCK;
  for (block_order_t i = 0; i < BUDDY_LEVELS; i++)
    size *= 2;
  return size;
}

qword Block::getSize(const block_order_t s) {
  if (!initialized)
    initialize();
  if (s < 0) {
    log_error("Attempting to get size of negative block order!");
    return 0;
  }
  if (s >= BUDDY_LEVELS) {
    log_error("Attempting to get size of block order greater than BUDDY_LEVELS!");
    return 0;
  }
  return blockSizes[s];
}
