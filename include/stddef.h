#ifndef __STDDEF_H
#define __STDDEF_H

#include <types.h>

#if defined(__cplusplus)
#define NULL 0
#else
#define NULL ((void *)0)
#endif

typedef __u64 size_t;

#endif /* __STDDEF_H */
