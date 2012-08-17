#include "kprintf.h"
#include "multiboot.h"
#include "types.h"

using namespace stackAllocator;

void** stackPointer;
qword stackRemaining;

bool initialized = false;

void initialize() {
  void* memstart;
  void* memend;

  stackPointer = 0;
  stackRemaining = (memend - memstart) / STACK_PAGE_SIZE;

  for (qword i = 0; i < stackRemaining; i++) {
    stackPointer[i] = memstart;
    memstart += STACK_PAGE_SIZE;
  }

  initialized = true;
}

void** requestMemory(qword size) {
  qword requestCount = (size + STACK_PAGE_SIZE - 1) / STACK_PAGE_SIZE;

  if (stackRemaining < requestCount) {
    log_error("Stack allocator: Not enough free memory!");
    return NULL;
  }

  stackRemaining -= requestCount;
  void* addr = 
}
