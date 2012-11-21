#include <interrupts.h>

interrupt_handler interrupts[256];

int handle_exception(void* rip) {
  rip = (void*)((__u64)rip + 1);
  return 0;
}

