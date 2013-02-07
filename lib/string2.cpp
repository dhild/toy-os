#include <kernel/string.h>

size_t strlen(const char* str) {
  size_t size = 0;
  while (*str != '\0') {
    str++;
    size++;
  }
  return size;
}

size_t strnlen(const char* str, size_t count) {
  size_t size = 0;
  while (count > 0) {
    if (*str == '\0')
      return size;
    size++;
    count--;
    str++;
  }
  return size;
}

void* memcpy(void* dest, void* src, size_t len) {
  for (size_t i = 0; i < len; i++)
    ((uint8_t *)dest)[i] = ((uint8_t *)src)[i];
  return dest;
}

void* memset(void* dest, int x, size_t len) {
  for (size_t i = 0; i < len; i++)
    ((uint8_t *)dest)[i] = (uint8_t)x;
  return dest;
}

