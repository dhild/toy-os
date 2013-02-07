#include <kernel/logging.h>
#include <kernel/stdio.h>

namespace {
  uint64_t minLogLevel = 0;
}

uint64_t log::minLoggingLevel() {
  return minLogLevel;
}

void log::info(const char* moduleName, const char* msg) {
  log::log(2048, moduleName, msg);
}

void log::debug(const char* moduleName, const char* msg) {
  log::log(1024, moduleName, msg);
}

void log::severe(const char* moduleName, const char* msg) {
  log::log(4096, moduleName, msg);
}
  
void log::panic(const char* moduleName, const char* msg) {
  log::log(0xFFFFFFFFFFFFFFFF, moduleName, msg);
  
  asm volatile("1: hlt\n\t"
               "jmp 1b\n\t");
}

void log::log(const uint64_t level, const char* moduleName, const char* msg) {
  if (level < minLogLevel)
    return;
  
  puts("[");
  puts(moduleName);
  puts("] : ");
  puts(msg);
  puts("\n");
}

