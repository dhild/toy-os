#ifndef MEMORY_MANAGEMENT_H
#define MEMORY_MANAGEMENT_H MEMORY_MANAGEMENT_H

#include "types.h"

// Requests a given size of paged virtual memory.
void* allocate(const size_t);
void free(const void*);

#endif
