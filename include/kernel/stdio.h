#ifndef KERNEL_STDIO_H
#define KERNEL_STDIO_H

#include <kernel/stdarg.h>
#include <kernel/stddef.h>
#include <kernel/video.h>

#ifdef __cplusplus
extern "C" {
#endif

  int printf(const char* format, ...);
  int sprintf(char* buf, const char *format, ...);
  int vsprintf(char* buf, const char* format, va_list args);

  static inline int isdigit(int ch) {
    return (ch >= '0') && (ch <= '9');
  }

  static inline int isxdigit(int ch) {
    if (isdigit(ch))
      return 1;

    if ((ch >= 'a') && (ch <= 'f'))
      return 1;

    return (ch >= 'A') && (ch <= 'F');
  }

#ifdef __cplusplus
}
#endif

#endif /* KERNEL_STDIO_H */
