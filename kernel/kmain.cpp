#include <kernel/kmain.h>
#include <kernel/logging.h>
#include <kernel/stdio.h>
#include "paging.h"

void kmain() {
  printf("kmain()\n");
  
  log::info("kmain", "Testing logging %d", 1234);
  
  paging::setup_paging();
}
