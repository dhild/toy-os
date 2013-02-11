#include <kernel/paging.h>
#include <kernel/interrupt_handlers.h>
#include <kernel/stdio.h>
#include <kernel/logging.h>

void handle_page_fault_interrupt(uint64_t errorCode, void* address) {
  
  switch (errorCode) {
  case 0:
    printf("Supervisory process tried to read non-present page\n");
    break;
  case PAGE_FAULT_ERROR_PRESENT:
    printf("Supervisory process tried to read a page and caused a protection fault\n");
    break;
  case PAGE_FAULT_ERROR_WRITE:
    printf("Supervisory process tried to write to a non-present page\n");
    break;
  case (PAGE_FAULT_ERROR_PRESENT | PAGE_FAULT_ERROR_WRITE):
    printf("Supervisory process tried to write a page and caused a protection fault\n");
    break;
  case PAGE_FAULT_ERROR_USER:
    printf("User process tried to read non-present page\n");
    break;
  case (PAGE_FAULT_ERROR_USER | PAGE_FAULT_ERROR_PRESENT):
    printf("User process tried to read a page and caused a protection fault\n");
    break;
  case (PAGE_FAULT_ERROR_USER | PAGE_FAULT_ERROR_WRITE):
    printf("User process tried to write to a non-present page\n");
    break;
  case (PAGE_FAULT_ERROR_USER | PAGE_FAULT_ERROR_PRESENT | PAGE_FAULT_ERROR_WRITE):
    printf("User process tried to write a page and caused a protection fault\n");
    break;
  }

  log::info(__FILE__, "Failed paging address: %p\n", address);

  PML4E pml4e;
  PDPTE pdpte;
  PDTE pdte;
  PTE pte;
  getAddressInfo(address, &pml4e, &pdpte, &pdte, &pte);
}
