#ifndef __STRING_H
#define __STRING_H

#include <stddef.h>
#include <types.h>

#ifdef __cplusplus
extern "C" {
#endif

  void* memcpy(void* dest, void* src, size_t len);
  void* memset(void* dest, int x, size_t len);

  size_t strlen(const char* str);
  size_t strnlen(const char* str, size_t count);

#ifdef __cplusplus
}
#endif

#endif /* __STRING_H */
