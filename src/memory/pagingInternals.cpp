/* This file contains some semi-constants.
 * Once initialized, they should not be touched.
 * Hence, the getter interface.
 */
#include "paging.h"
#include "multiboot.h"
#include "kprintf.h"

using namespace paging;

extern "C" size_t start_of_kernel;
extern "C" size_t end_of_kernel;
extern "C" mb_header mb_info;

extern "C" PML4T * PML4Tables;
extern "C" PDPT * PDPTIdentity;
extern "C" PDPT * PDPTKernel;
PDT * PDT_start;
PT * PT_start;
void * memory_start;
void * memory_end;
size_t memory_size;

bool initialized = false;

void setupPagingInternals() {
  if (initialized)
    return;

  

  // Figure out where in memory we need to be.
  void * mem_start = (void *)end_of_kernel;
  size_t mem_size = 0;

  if (mb_info.flags & MB_FLAGS_MEM_INFO) {
    mem_size = (mb_info.mem_upper * 1024) - (end_of_kernel - start_of_kernel);
  }

  print_string("Found memory starts at ");
  print_hex( (qword)mem_start );
  print_string(", and has ");
  print_dec( mem_size );
  print_string(" free bytes!");

  memory_end = (void *)((size_t)mem_start + mem_size);

  PDT_start = (PDT *)(((size_t)mem_start + 4095) & 0xFFFFFFFFFFFFE000);
  size_t count = ((size_t)memory_end - (size_t)PDT_start) / (2 * 1024 * 1024);
  PT_start = (PT *)((size_t)PDT_start + ((count + 511) / 512));
  count = ((size_t)memory_end - (size_t)PDT_start) / (4096);
  memory_start = (void *)((size_t)PT_start + ((count + 511) / 512));
  memory_size = (size_t)memory_end - (size_t)memory_start;
  
  initialized = true;
}


PML4T * getPML4E() { return PML4Tables; }
PDPT * getPDPTLow() { return PDPTIdentity; }
PDPT * getPDPTHigh() { return PDPTKernel; }
PDT * getPDTStart() { return PDT_start; }
PT * getPTStart() { return PT_start; }
void * getMemoryStart() { return memory_start; }
void * getMemoryEnd() { return memory_end; }
size_t getMemorySize() { return memory_size; }
