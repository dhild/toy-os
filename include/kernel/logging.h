#ifndef KERNEL_LOGGING_H
#define KERNEL_LOGGING_H

#include <config.h>

namespace log {
  
  void log(const __u64 level, const char* moduleName, const char* msg, ...);
  __u64 minLoggingLevel();
  void info(const char* moduleName, const char* msg, ...);
  void debug(const char* moduleName, const char* msg, ...);
  void severe(const char* moduleName, const char* msg, ...);
  
  void panic(const char* moduleName, const char* msg, ...);
  
}

#endif /* KERNEL_LOGGING_H */
