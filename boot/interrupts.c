#include <kernel/interrupts.h>

interrupt_handler interrupts[256];

int handle_exception(void* rip) {
  rip = (void*)((uint64_t)rip + 1);
  return 0;
}
