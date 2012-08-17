#ifndef MEMORY_MANAGEMENT_H
#define MEMORY_MANAGEMENT_H MEMORY_MANAGEMENT_H

#include "types.h"

// Requests a given size of paged virtual memory.
void* request_memory(qword size);
void release_memory(const void* mem);

#endif
