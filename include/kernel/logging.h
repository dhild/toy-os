#ifndef KERNEL_LOGGING_H
#define KERNEL_LOGGING_H

#include <stdint.h>
#include <stdarg.h>

namespace log {
  
  void log(const uint64_t level, const char* moduleName, const char* format, ...);
  uint64_t minLoggingLevel();
  void info(const char* moduleName, const char* format, ...);
  void debug(const char* moduleName, const char* format, ...);
  void severe(const char* moduleName, const char* format, ...);
  
  void panic(const char* moduleName, const char* format, ...);


  extern const uint64_t info_level;
  extern const uint64_t debug_level;
  extern const uint64_t severe_level;
}

#endif /* KERNEL_LOGGING_H */
