#ifndef BOOT_BOOT_H
#define BOOT_BOOT_H

#include <boot/addresses.h>
#include <types.h>

#ifdef __cplusplus
extern "C" {
#endif
  // These functions are implemented in assembly.
  // See printing.asm
  void putchar(int c);
  void puts(const char* s);
  
  void clearScreen();
  void scrollScreen();

void* memcpy(void* dest, void* src, size_t len);
void* memset(void* dest, int x, size_t len);

#ifdef __cplusplus
}
#endif

#endif // BOOT_BOOT_H

