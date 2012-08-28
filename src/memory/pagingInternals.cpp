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

extern "C" PML4T * PML4Tables;
extern "C" PDPT * PDPTIdentity;
extern "C" PDPT * PDPTKernel;
void * memory_start;
void * memory_end;
size_t memory_size;

qword * bitmap;
size_t bitmap_length;

bool initialized = false;

void paging::setupPagingInternals() {
  if (initialized)
    return;

  // Figure out where in memory we need to be.
  void * mem_start = (void *)end_of_kernel;
  size_t mem_size = 0;

  if (mb_info->flags & MB_FLAGS_MEM_INFO) {
    mem_size = (mb_info->mem_upper * 1024) + (1024 * 1024) - end_of_kernel;
  }

  print_string("Found memory starts at ");
  print_hex( (qword)mem_start );
  print_string(", and has ");
  print_dec( mem_size );
  print_string(" free bytes!");

  memory_end = (void *)((size_t)mem_start + mem_size);

  // Set up physical bitmap
  bitmap = (qword *)mem_start;
  bitmap_length = ((mem_size + (63 * 4096)) / (4096 * 64));

  for (size_t i = 0; i < bitmap_length; i++)
    bitmap[i] = 0;

  mem_start = (void *)((qword)mem_start + (bitmap_length / 8));

  // Align the start of memory:
  memory_start = (void *)(((qword)mem_start + 4095) & 0xFFFFFFFFFFFFF000);
  memory_size = (qword)memory_end - (qword)memory_start;
  
  initialized = true;
}

void * paging::lowToHigh(const void * linearAddress) {
  return (void *)((qword)linearAddress + 0xFFFFC00000000000);
}

void * paging::highToLow(const void * linearAddress) {
  return (void *)((qword)linearAddress - 0xFFFFC00000000000);
}

bool paging::isPhysicalPageUsed(const void * physicalAddress) {
  if (physicalAddress > memory_end) {
    log_error("Checking if physical page outside memory is used!");
    return false;
  }
  if (physicalAddress < memory_start)
    return true;

  const size_t index = ((qword)physicalAddress - (qword)memory_start) / (4096 * 64);
  const size_t bit = (((qword)physicalAddress - (qword)memory_start) - (index * 4096 * 64)) / 4096;
  return bitmap[index] & (1 << bit);
}

void * paging::allocatePhysicalPage() {
  for (size_t i = 0; i < bitmap_length; i++) {
    if (bitmap[i] != 0xFFFFFFFFFFFFFFFF) {
      size_t bit = 0;
      qword t = bitmap[i];
      while (!(t & 1)) {
	t = t >> 1;
	bit++;
      }
      bitmap[i] = bitmap[i] & (1 << bit);
      return (void *)((qword)memory_start + 4096 * (bit + (i * 64)));
    }
  }
  return NULL;
}

void paging::freePhysicalPage(const void * physicalAddress) {
  if (physicalAddress > memory_end) {
    log_error("Attempting to set usage of physical page outside memory!");
    return;
  }
  if (physicalAddress < memory_start) {
    log_error("Attempting to set usage of physical page in kernel memory!");
    return;
  }

  const size_t index = ((qword)physicalAddress - (qword)memory_start) / (4096 * 64);
  const size_t bit = (((qword)physicalAddress - (qword)memory_start) - (index * 4096 * 64)) / 4096;

 bitmap[index] = bitmap[index] | (1 << bit);
}

PML4T * paging::getPML4T() { return PML4Tables; }
PDPT * paging::getPDPTLow() { return PDPTIdentity; }
PDPT * paging::getPDPTHigh() { return PDPTKernel; }
void * paging::getMemoryStart() { return memory_start; }
void * paging::getMemoryEnd() { return memory_end; }
size_t paging::getMemorySize() { return memory_size; }

PDT * paging::getPDT(const void * linearAddress) {
  PDPT * pdpt = NULL;
  if ((qword)linearAddress < ((qword)512 * 1024 * 1024 * 1024))
    pdpt = getPDPTLow();
  else if ((sqword)linearAddress < ((sqword)-512 * 1024 * 1024 * 1024))
    pdpt = getPDPTHigh();
  else {
    log_error("Address is not below 512Gb or in kernel space!");
    return NULL;
  }
  // Okay, now find the specific PDT entry:
  qword index = (qword)linearAddress & ((1024 * 1024 * 1024) - 1);
  index = index / (2 * 1024 * 1024);

  return (PDT *)(pdpt->entry[index] & PAGING_PDPTE_TABLE_ADDRESS);
}

PT * paging::getPT(const void * linearAddress) {
  PDT * pdt = getPDT(linearAddress);

  if (pdt == NULL) {
    log_error("Unable to find PDT entry!");
    return NULL;
  }

  qword index = (qword)linearAddress & ((2 * 1024 * 1024) - 1);
  index = index / 4096;

  return (PT *)(pdt->entry[index] & PAGING_PDE_TABLE_ADDRESS);
}

bool paging::setupPageTable(PT * tables, void * address, const qword flags, const bool increment) {
  bool result = true;
  for (qword i = 0; i < 512; i++) {
    if (increment)
      address = (void *)((qword)address + 4096);
    result = result & setPTE(&(tables->entry[i]), address, flags);
  }
  return result;
}

bool paging::setupPageDirectory(PDT * tables, void * address, const qword flags, const bool increment) {
  bool result = true;
  for (qword i = 0; i < 512; i++) {
    if (increment)
      address = (void *)((qword)address + (2 * 1024 * 1024));
    result = result & setPDTE(&(tables->entry[i]), address, flags);
  }
  return result;
}

bool paging::setupPageDirectory(PDT * tables, PT * address, const qword flags, const bool increment) {
  bool result = true;
  for (qword i = 0; i < 512; i++) {
    if (increment)
      address = (PT *)((qword)address + 4096);
    result = result & setPDTE(&(tables->entry[i]), address, flags);
  }
  return result;
}

bool paging::setupPageDirectoryPointer(PDPT * tables, void * address, const qword flags, const bool increment) {
  bool result = true;
  for (qword i = 0; i < 512; i++) {
    if (increment)
      address = (void *)((qword)address + (1024 * 1024 * 1024));
    result = result & setPDPTE(&(tables->entry[i]), address, flags);
  }
  return result;
}

bool paging::setupPageDirectoryPointer(PDPT * tables, PDT * address, const qword flags, const bool increment) {
  bool result = true;
  for (qword i = 0; i < 512; i++) {
    if (increment)
      address = (PDT *)((qword)address + 4096);
    result = result & setPDPTE(&(tables->entry[i]), address, flags);
  }
  return result;
}

bool paging::isCanonicalAddress(const void * address) {
  if ((qword)address < PAGING_PTE_ADDRESS)
    return true;

  return (((qword)address & PAGING_CANNONICAL_BITS) == PAGING_CANNONICAL_BITS);
}

bool paging::setPTE(PTE * page, const void * address, const qword flags) {
  if (!isCanonicalAddress(address)) {
    log_error("Attempting to set page entry to a non-cannonical address!");
    return false;
  }
  if (((qword)address % 4096) != 0) {
    log_error("Attempting to set a page entry to an unaligned address!");
    return false;
  }
  *page = ((qword)address | flags) & (!PAGING_PTE_FLAGS_RESERVED);
  return true;
}

bool paging::setPDTE(PDTE * page, const PT * address, const qword flags) {
  if (!isCanonicalAddress(address)) {
    log_error("Attempting to set page directory entry to a non-cannonical address!");
    return false;
  }
  if (((qword)address % 4096) != 0) {
    log_error("Attempting to set a page directory entry to an unaligned address!");
    return false;
  }
  *page = ((qword)address | flags) & (!PAGING_PDE_FLAGS_TABLE_RESERVED);
  return true;
}

bool paging::setPDTE(PDTE * page, const void * address, const qword flags) {
  if (!isCanonicalAddress(address)) {
    log_error("Attempting to set page directory entry to a non-cannonical address!");
    return false;
  }
  if (((qword)address % (2 * 1024 * 1024)) != 0) {
    log_error("Attempting to set a page directory entry to an unaligned address!");
    return false;
  }
  *page = ((qword)address | flags) & (!PAGING_PDE_FLAGS_PAGE_RESERVED);
  return true;
}

bool paging::setPDPTE(PDPTE * page, const PDT * address, const qword flags) {
  if (!isCanonicalAddress(address)) {
    log_error("Attempting to set page directory pointer entry to a non-cannonical address!");
    return false;
  }
  if (((qword)address % 4096) != 0) {
    log_error("Attempting to set a page directory pointer entry to an unaligned address!");
    return false;
  }
  *page = ((qword)address | flags) & (!PAGING_PDPTE_FLAGS_TABLE_RESERVED);
  return true;
}

bool paging::setPDPTE(PDPTE * page, const void * address, const qword flags) {
  if (!isCanonicalAddress(address)) {
    log_error("Attempting to set page directory pointer entry to a non-cannonical address!");
    return false;
  }
  if (((qword)address % (1024 * 1024 * 1024)) != 0) {
    log_error("Attempting to set a page directory pointer entry to an unaligned address!");
    return false;
  }
  *page = ((qword)address | flags) & (!PAGING_PDPTE_FLAGS_PAGE_RESERVED);
  return true;
}

bool paging::setPML4E(PML4E * page, const void * address, const qword flags) {
  if (!isCanonicalAddress(address)) {
    log_error("Attempting to set page level 4 entry to a non-cannonical address!");
    return false;
  }
  if (((qword)address % 4096) != 0) {
    log_error("Attempting to set a page level 4 entry to an unaligned address!");
    return false;
  }
  *page = ((qword)address | flags) & (!PAGING_PML4E_FLAGS_RESERVED);
  return true;
}
