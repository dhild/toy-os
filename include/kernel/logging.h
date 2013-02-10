#ifndef KERNEL_LOGGING_H
#define KERNEL_LOGGING_H

#include <stdint.h>

namespace log {
  
  void log(const uint64_t level, const char* moduleName, const char* msg);
  uint64_t minLoggingLevel();
  void info(const char* moduleName, const char* msg);
  void debug(const char* moduleName, const char* msg);
  void severe(const char* moduleName, const char* msg);
  
  void panic(const char* moduleName, const char* msg);
  
}

#endif /* KERNEL_LOGGING_H */
