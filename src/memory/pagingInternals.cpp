/* This file contains some semi-constants.
 * Once initialized, they should not be touched.
 * Hence, the getter interface.
 */
#include "paging.h"
#include "multiboot.h"
#include "kprintf.h"

using namespace paging;

/* The semi-constants. */
extern "C" size_t start_of_kernel;
extern "C" size_t end_of_kernel;
extern "C" mb_header mb_info;

extern "C" PML4T * PML4Tables;
extern "C" PDPT * PDPTIdentity;
extern "C" PDPT * PDPTKernel;
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
void * getMemoryStart() { return memory_start; }
void * getMemoryEnd() { return memory_end; }
size_t getMemorySize() { return memory_size; }

PDT * getPDT(const void * linearAddress) {
  PDPT * pdpt = NULL;
  if (linearAddress < (512 * 1024 * 1024 * 1024))
    pdpt = getPDPTLow();
  else if (linearAddress > (- 512 * 1024 * 1024 * 1024))
    pdpt = getPDPTHigh();
  else {
    log_error("Address is not below 512Gb or in kernel space!");
    return NULL;
  }
  // Okay, now find the specific PDT entry:
  qword index = (qword)linearAddress & ((1024 * 1024 * 1024) - 1);
  index = index / (2 * 1024 * 1024);

  return pdpt->entry[index];
}

PT * getPT(const void * linearAddress) {
  PDT * pdt = getPDT(linearAddress);

  if (pdt == NULL) {
    log_error("Unable to find PDT entry!");
    return NULL;
  }

  qword index = (qword)linearAddress & ((2 * 1024 * 1024) - 1);
  index = index / 4096;

  return pdt->entry[index];
}

bool setupPageTable(PT * tables, const void * address, const qword flags) {
  for (qword i = 0; i < 512; i++) {
    void * addr = (void *)((qword)address + (i * 4096));
    if (!setPTE(tables->entry[i], addr, flags))
      return false;
  }
}

bool setupPageDirectory(PDT * tables, const void * address, const qword flags) {
  for (qword i = 0; i < 512; i++) {
    void * addr = (void *)((qword)address + (i * 2 * 1024 * 1024));
    if (!setPDTE(tables->entry[i], addr, flags));
      return false;
  }
}

bool setupPageDirectory(PDT * tables, const PT * address, const qword flags) {
  for (qword i = 0; i < 512; i++) {
    void * addr = (void *)((qword)address + (i * 4096));
    if (!setPDTE(tables->entry[i], addr, flags));
      return false;
  }
}

bool setupPageDirectoryPointer(PDPT * tables, const void * address, const qword flags) {
  for (qword i = 0; i < 512; i++) {
    void * addr = (void *)((qword)address + (i * 4096));
    if (!setPDPTE(tables->entry[i], addr, flags));
      return false;
  }
}

bool setupPageDirectoryPointer(PDPT * tables, const PDT * address, const qword flags) {
  for (qword i = 0; i < 512; i++) {
    void * addr = (void *)((qword)address + (i * 4096));
    if (!setPDPTE(tables->entry[i], addr, flags));
      return false;
  }
}


bool isCanonicalAddress(const void * address) {
  if (address < PAGING_PTE_ADDRESS)
    return true;

  return ((address & PAGING_CANNONICAL_BITS) == PAGING_CANNONICAL_BITS);
}

bool setPTE(PTE * page, const void * address, const qword flags) {
  if (!isCanonical(address)) {
    log_error("Attempting to set page entry to a non-cannonical address!");
    return false;
  }
  if ((address % 4096) != 0) {
    log_error("Attempting to set a page entry to an unaligned address!");
    return false;
  }
  *page = (address | flags) & (!PAGING_PTE_FLAGS_RESERVED);
}

bool setPDTE(PDTE * page, const PT * address, const qword flags) {
  if (!isCanonical(address)) {
    log_error("Attempting to set page directory entry to a non-cannonical address!");
    return false;
  }
  if ((address % 4096) != 0) {
    log_error("Attempting to set a page directory entry to an unaligned address!");
    return false;
  }
  *page = (address | flags) & (!PAGING_PDTE_FLAGS_RESERVED);
}

bool setPDTE(PDTE * page, const void * address, const qword flags) {
  if (!isCanonical(address)) {
    log_error("Attempting to set page directory entry to a non-cannonical address!");
    return false;
  }
  if ((address % (2 * 1024 * 1024)) != 0) {
    log_error("Attempting to set a page directory entry to an unaligned address!");
    return false;
  }
  *page = (address | flags) & (!PAGING_PDTE_FLAGS_RESERVED);
}

bool setPDPTE(PDPTE * page, const PDT * address, const qword flags) {
  if (!isCanonical(address)) {
    log_error("Attempting to set page directory pointer entry to a non-cannonical address!");
    return false;
  }
  if ((address % 4096) != 0) {
    log_error("Attempting to set a page directory pointer entry to an unaligned address!");
    return false;
  }
  *page = (address | flags) & (!PAGING_PDPTE_FLAGS_RESERVED);
}

bool setPDPTE(PDPTE * page, const void * address, const qword flags) {
  if (!isCanonical(address)) {
    log_error("Attempting to set page directory pointer entry to a non-cannonical address!");
    return false;
  }
  if ((address % (1024 * 1024 * 1024)) != 0) {
    log_error("Attempting to set a page directory pointer entry to an unaligned address!");
    return false;
  }
  *page = (address | flags) & (!PAGING_PDPTE_FLAGS_RESERVED);
}

bool setPML4E(PML4E * page, const void * address, const qword flags) {
  if (!isCanonical(address)) {
    log_error("Attempting to set page level 4 entry to a non-cannonical address!");
    return false;
  }
  if ((address % 4096) != 0) {
    log_error("Attempting to set a page level 4 entry to an unaligned address!");
    return false;
  }
  *page = (address | flags) & (!PAGING_PML4E_FLAGS_RESERVED);
}
