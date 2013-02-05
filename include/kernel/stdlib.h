#ifndef KERNEL_STDLIB_H
#define KERNEL_STDLIB_H

#include <kernel/stddef.h>

void* malloc(size_t size);
void* calloc(size_t num, size_t size);
void free(void* ptr);
void* realloc(void* ptr, size_t size);

#endif /* KERNEL_STDLIB_H */
