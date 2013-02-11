#include <kernel/kmain.h>
#include <kernel/logging.h>
#include <kernel/stdio.h>
#include <kernel/multiboot.h>
#include "interrupts.h"
#include "paging.h"


void test_mb_info(void* address) {
  if ((uint64_t)address & 7)
    log::panic("Multiboot test", "Multiboot header address not aligned!");

  uint32_t size = *(uint32_t*)address;

  for (multiboot_tag* tag = (multiboot_tag*)((uint64_t)address + 8);
       tag->type != MULTIBOOT_TAG_TYPE_END;
       tag = (multiboot_tag*)(((uint64_t)tag + (tag->size + 7)) & ~7)) {
    size -= tag->size;
  }
}

void initialize_screen() {
  clearScreen();
  printf("kmain()\n");

  printf("Testing %%#x: %#x\n", 0xDEADBEEF);
  printf("Testing %%p: %p\n", &kmain);
  printf("Testing %%d: %d\n", -1234);
  
  log::info(__FILE__, "Testing logging %%#x: %x, %%p: %p, %%d: %d", 0xCAFEBABE, &kmain, -1234);
}

void kmain(void* mb_info_address) {

  initialize_screen();

  paging::setup_paging();

  interrupts::setup_interrupts();

  test_mb_info(mb_info_address);
  
  paging::setup_paging();
}
