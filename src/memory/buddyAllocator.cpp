#include "memory.h"
#include "kprintf.h"

using namespace buddy;

Block* Block::blocks[BUDDY_LEVELS];
qword Block::blockCounts[BUDDY_LEVELS];
qword Block::blockSizes[BUDDY_LEVELS];
bool Block::initialized = false;

void Block::initialize() {
  qword size = BUDDY_SMALLEST_BLOCK;
  for (block_order_t i = 0; i < BUDDY_LEVELS; i++) {
    blockSizes[i] = size;
    size *= 2;
  }
  blockCount = 0;
  initialized = true;
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

Block::Block(const void* loc, const block_order_t o) : location(loc), order(o), inUse(false) {}

void Block::split() {
  if (this->order == 0) {
    log_error( "Trying to split lowest order block!" );
    return;
  }
  if (this->isUsed()) {
    log_error( "Trying to split block in use!" );
    return;
  }
  this->setUsed( true );

  block_order_t order = this->order - 1;
  Block* childA = new Block(this->location, order );
  Block* childB = new Block(this->location + getSize(order), order );
}

Block* Block::getFree(const block_order_t order) {
  for (qword i = 0; i < blockCounts[order]; i++) {
    if (blocks[order][i]->inUse == false) {
      blocks[order][i]->inUse = true;
      return blocks[order][i];
    }
  }
  if (order == BUDDY_LEVELS) {
    log_error( "Unable to allocate largest block!" );
    return NULL;
  }

  Block* bigger = getFree(order + 1);
  if (bigger == NULL) {
    log_error( "Unable to allocate larger block!" );
    return NULL;
  }
  split_block( bigger );

  if (blocks[blockCounts[order] - 2]->inUse == false) {
    blocks[blockCounts[order] - 2]->inUse = true;
    return blocks[blockCounts[order] - 2];
  }
  if (blocks[blockCounts[order] - 1]->inUse == false) {
    blocks[blockCounts[order] - 1]->inUse = true;
    return blocks[blockCounts[order] - 1];
  }

  log_error( "Unable to find a free block!" );
  return NULL;
}

Block* findByLoc(const void* loc) {
  for (block_order_t i = BUDDY_LEVELS - 1; i > -1; i--) {
    for (qword j = 0; j < blockCounts[i]; j++) {
      if (blocks[i][j]->location == location)
	return blocks[i][j];
    }
  }
  return NULL;
}

void* Block::requestMemory(qword size) {
  if (!initialized)
    initialize();

  for (block_order_t i = 0; i < BUDDY_LEVELS; i++) {
    if (size < blockSizes[i]) {
      BuddyBlock* block = getFree(i);
      if (block == NULL) {
	log_error( "Unable to fill request for memory!" );
	return NULL;
      }
      block->setUsed(true);
      return block->location;
    }
  }
  // We need more than one of the largest blocks.
  // For now, return several of the largest blocks.
  // This is a waste, especially if it's a request for only a few
  // more bytes, but for now we'll have to just deal with it.
  // TODO: Fix physical block allocator to use smallest number of blocks possible.
  qword request_count = (size + BLOCK_MAX_SIZE - 1) / BLOCK_MAX_SIZE;
  BuddyBlock* found_blocks[request_count];
  for (qword i = 0; i < block_counts[BUDDY_LEVELS - 1]; i++) {
    found_blocks[0] = blocks[BUDDY_LEVELS - 1][i];
    if (found_blocks[0]->inUse)
      continue;
    for (qword j = 1; j < request_count; j++) {
      found_blocks[j] = get_specific_block( location );
      if ((found_blocks[j]->inUse) || (found_blocks[j]->order != (BUDDY_LEVELS - 1)))
	continue;
    }
    // We have enough blocks!
    mark_blocks_in_use( found_blocks, request_count );
    return found_blocks[0]->location;
  }
  // We couldn't satisfy the request!
  log_error( "Unable to fill request for memory! Not enough contiguous blocks available" );
  return NULL;
}

/** Requests a given size of memory from the buddy allocator.
 */
void* buddy_request_memory( qword size ) {
  buddy_check_initialized();
  for (block_order_t i = 0; i < BUDDY_LEVELS; i++) {
    if (size < block_sizes[i]) {
      BuddyBlock* block = get_block( i );
      if (block == NULL) {
	log_error( "Unable to fill request for memory!" );
	return NULL;
      }
      mark_blocks_in_use( &block, 1 );
      return block->location;
    }
  }
  // We need more than one of the largest blocks.
  // For now, return several of the largest blocks.
  // This is a waste, especially if it's a request for only a few
  // more bytes, but for now we'll have to just deal with it.
  // TODO: Fix physical block allocator to use smallest number of blocks possible.
  qword request_count = (size + BLOCK_MAX_SIZE - 1) / BLOCK_MAX_SIZE;
  BuddyBlock* found_blocks[request_count];
  for (qword i = 0; i < block_counts[BUDDY_LEVELS - 1]; i++) {
    found_blocks[0] = blocks[BUDDY_LEVELS - 1][i];
    if (found_blocks[0]->inUse)
      continue;
    for (qword j = 1; j < request_count; j++) {
      found_blocks[j] = get_specific_block( location );
      if ((found_blocks[j]->inUse) || (found_blocks[j]->order != (BUDDY_LEVELS - 1)))
	continue;
    }
    // We have enough blocks!
    mark_blocks_in_use( found_blocks, request_count );
    return found_blocks[0]->location;
  }
  // We couldn't satisfy the request!
  log_error( "Unable to fill request for memory! Not enough contiguous blocks available" );
  return NULL;
}

/** Requests to release the memory pointed at by the given address.
 */
void buddy_release_memory(const void* mem) {
  buddy_check_initialized(); // Really, we should be initialized here, but check anyways.
  BuddyBlock* block = get_specific_block( mem );
  if (block == NULL) {
    log_error( "Attempting to free a memory address that can't be found as a block!" );
    return;
  }
  block->inUse = false;
}

/** Calls the buddy allocator.
 */
void* request_memory( qword size ) {
  return buddy_request_memory( size );
}

/** Calls the buddy deallocator.
 */
void release_memory( const void* mem ) {
  buddy_release_memory( mem );
}
