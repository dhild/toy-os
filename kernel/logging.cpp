#include <stdarg.h>
#include <kernel/logging.h>
#include <kernel/stdio.h>

namespace {
  uint64_t minLogLevel = 0;
  const uint64_t panic_level = 0xFFFFFFFFFFFFFFFF;
}

const uint64_t log::info_level = 2048;
const uint64_t log::debug_level = 1024;
const uint64_t log::severe_level = 4096;

uint64_t log::minLoggingLevel() {
  return minLogLevel;
}

void log::info(const char* moduleName, const char* format, ...) {
  va_list args;
  va_start(args, format);
  log::log(info_level, moduleName, format, args);
  va_end(args);
}

void log::debug(const char* moduleName, const char* format, ...) {
  va_list args;
  va_start(args, format);
  log::log(debug_level, moduleName, format, args);
  va_end(args);
}

void log::severe(const char* moduleName, const char* format, ...) {
  va_list args;
  va_start(args, format);
  log::log(severe_level, moduleName, format, args);
  va_end(args);
}
  
void log::panic(const char* moduleName, const char* format, ...) {
  va_list args;
  va_start(args, format);
  log::log(panic_level, moduleName, format, args);
  va_end(args);
  
  asm volatile("1: hlt\n\t"
               "jmp 1b\n\t");
}

void log::log(const uint64_t level, const char* moduleName, const char* format, ...) {
  if (level < minLogLevel)
    return;

  printf("[%s]: ", moduleName);
  va_list args;
  va_start(args, format);
  printf(format, args);
  va_end(args);
  printf("\n");
}

