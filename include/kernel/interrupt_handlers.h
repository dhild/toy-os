#ifndef KERNEL_INTERRUPT_HANDLERS_H
#define KERNEL_INTERRUPT_HANDLERS_H

#include <stdint.h>

void handle_page_fault_interrupt(uint64_t errorCode);

#define PAGE_FAULT_ERROR_PRESENT 0x1
#define PAGE_FAULT_ERROR_WRITE   0x2
#define PAGE_FAULT_ERROR_USER    0x4

#endif /* KERNEL_INTERRUPT_HANDLERS_H */
