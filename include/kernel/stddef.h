#ifndef KERNEL_STDDEF_H
#define KERNEL_STDDEF_H

#include <config.h>

#if defined(__cplusplus)
#define NULL 0
#else
#define NULL ((void *)0)
#endif

typedef __u64 size_t;

#endif /* KERNEL_STDDEF_H */
