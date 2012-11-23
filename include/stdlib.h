#ifndef __STDLIB_H
#define __STDLIB_H

#include <stddef.h>

void* malloc(size_t size);
void* calloc(size_t num, size_t size);
void free(void* ptr);
void* realloc(void* ptr, size_t size);

#endif /* __STDLIB_H */
