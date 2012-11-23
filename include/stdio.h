#ifndef __STDIO_H
#define __STDIO_H

#include <stdarg.h>
#include <stddef.h>
#include <video.h>

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

#endif /* __STDIO_H */
