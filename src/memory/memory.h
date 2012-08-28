#ifndef MEMORY_MANAGEMENT_H
#define MEMORY_MANAGEMENT_H MEMORY_MANAGEMENT_H

#include "paging.h"
#include "types.h"

// Requests a given size of paged virtual memory.
void* allocate(const size_t size) { return paging::allocate(size); }
void free(const void* loc) { return paging::free(loc); }

#endif
