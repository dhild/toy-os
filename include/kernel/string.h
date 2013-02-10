#ifndef KERNEL_STRING_H
#define KERNEL_STRING_H

#include <stdint.h>
#include <stddef.h>

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

#endif /* KERNEL_STRING_H */
