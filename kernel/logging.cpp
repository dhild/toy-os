#include <kernel/logging.h>
#include <kernel/stdarg.h>
#include <kernel/stdio.h>

namespace {
  __u64 minLogLevel = 0;
}

__u64 log::minLoggingLevel() {
  return minLogLevel;
}

void log::info(const char* moduleName, const char* msg, ...) {
  va_list args;
  va_start(args, msg);
  log::log(2048, moduleName, msg, args);
  va_end(args);
}

void log::debug(const char* moduleName, const char* msg, ...) {
  va_list args;
  va_start(args, msg);
  log::log(1024, moduleName, msg, args);
  va_end(args);
}

void log::severe(const char* moduleName, const char* msg, ...) {
  va_list args;
  va_start(args, msg);
  log::log(4096, moduleName, msg, args);
  va_end(args);
}
  
void log::panic(const char* moduleName, const char* msg, ...) {
  va_list args;
  va_start(args, msg);
  log::log(0xFFFFFFFFFFFFFFFF, moduleName, msg, args);
  va_end(args);
  
  asm volatile("1: hlt\n\t"
               "jmp 1b\n\t");
}

void log::log(const __u64 level, const char* moduleName, const char* msg, ...) {
  if (level < minLogLevel)
    return;
  
  printf("[%s]: ", moduleName);
  va_list args;
  va_start(args, msg);
  printf(msg, args);
  va_end(args);
  printf("\n");
}

