#include "memory.h"
#include "paging.h"

void * allocate(const size_t bytes) {
  return paging::allocate(bytes);
}

void free(void* loc) {
  paging::free(loc);
}
