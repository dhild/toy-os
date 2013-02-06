#include <kernel/kmain.h>
#include <kernel/logging.h>
#include <kernel/stdio.h>
#include <kernel/multiboot.h>
#include "paging.h"



void test_mb_info(void* address) {
  if ((__u64)address & 7)
    log::panic("Multiboot test", "Multiboot header address not aligned!");

  __u32 size = *(__u32*)address;

  for (multiboot_tag* tag = (multiboot_tag*)((__u64)address + 8);
       tag->type != MULTIBOOT_TAG_TYPE_END;
       tag = (multiboot_tag*)(((__u64)tag + (tag->size + 7)) & ~7)) {
    size -= tag->size;
  }
}

void kmain(void* mb_info_address) {
  puts("kmain()\n");
  
  log::info("kmain", "Testing logging");

  test_mb_info(mb_info_address);
  
  paging::setup_paging();
}
