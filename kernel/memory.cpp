#include <stdint.h>
#include <kernel/memory.h>

namespace paging {

  typedef struct free_block_info {
    free_page_info* next;
  } free_page_info;

  typedef struct free_block_list {
    free_block_info free_list;
    uint64_t* map;
  } free_block_list;

  typedef struct free_block {
    
  } free_block;
}
