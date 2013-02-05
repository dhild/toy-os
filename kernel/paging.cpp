#include <kernel/kmain.h>
#include "paging.h"

using namespace paging;

/*

  PTE* getPageTable(void* linear);
  PDTE* getPageDirectory(void* linear);
  PDPTE* getPageDirectoryPointer(void* linear);
  PML4E* getPageLevel4(void* linear);

  int isPhysicalPageUsed(const void * physicalAddress);

  int setupPageTable(PT * tables, void * address, const qword flags, const int increment = true);
  int setupPageDirectory(PDT * tables, void * address, const qword flags, const bool increment = true);
  int setupPageDirectory(PDT * tables, PT * address, const qword flags, const bool increment = true);
  int setupPageDirectoryPointer(PDPT * tables, void * address, const qword flags, const bool increment = true);
  int setupPageDirectoryPointer(PDPT * tables, PDT * address, const qword flags, const bool increment = true);

  void * getMemoryStart();
  void * getMemoryEnd();
  size_t getMemorySize();

  int setPTE(PTE * page, const void * address, const qword flags);
  int setPDTE(PDTE * page, const void * address, const qword flags);
  int setPDTE(PDTE * page, const PT * address, const qword flags);
  int setPDPTE(PDPTE * page, const void * address, const qword flags);
  int setPDPTE(PDPTE * page, const PDT * address, const qword flags);
  int setPML4E(PML4E * page, const void * address, const qword flags);*/

// How many bits are used in each address?
#define PAGING_ADDRESS_BITS ((__u64)48)
// These are based on PAGING_ADDRESS_BITS.
// They all MUST make sense together!
#define PAGING_GLOBAL_RESERVED     ((__u64)0x000F000000000000)
#define PAGING_CANNONICAL_BITS     ((__u64)0xFFFF000000000000)
#define PAGING_PTE_ADDRESS         ((__u64)0x0000FFFFFFFFF000)
#define PAGING_PDE_PAGE_ADDRESS    ((__u64)0x0000FFFFFFE00000)
#define PAGING_PDE_TABLE_ADDRESS   ((__u64)0x0000FFFFFFFFF000)
#define PAGING_PDPTE_PAGE_ADDRESS  ((__u64)0x0000FFFFC0000000)
#define PAGING_PDPTE_TABLE_ADDRESS ((__u64)0x0000FFFFFFFFF000)
#define PAGING_PML4E_TABLE_ADDRESS ((__u64)0x0000FFFFFFFFF000)

// Common to all page tables:
#define PAGING_PAGE_FLAGS_PRESENT         (((__u64)1)<<0)
#define PAGING_PAGE_FLAGS_WRITEABLE       (((__u64)1)<<1)
#define PAGING_PAGE_FLAGS_USER            (((__u64)1)<<2)
#define PAGING_PAGE_FLAGS_PWT             (((__u64)1)<<3)
#define PAGING_PAGE_FLAGS_PCD             (((__u64)1)<<4)
#define PAGING_PAGE_FLAGS_ACCESSED        (((__u64)1)<<5)
#define PAGING_PAGE_FLAGS_EXECUTE_DISABLE (((__u64)1)<<63)
#define PAGING_PAGE_FLAGS_IGNORED_0       (((__u64)1)<<52)
#define PAGING_PAGE_FLAGS_IGNORED_1       (((__u64)1)<<53)
#define PAGING_PAGE_FLAGS_IGNORED_2       (((__u64)1)<<54)
#define PAGING_PAGE_FLAGS_IGNORED_3       (((__u64)1)<<55)
#define PAGING_PAGE_FLAGS_IGNORED_4       (((__u64)1)<<56)
#define PAGING_PAGE_FLAGS_IGNORED_5       (((__u64)1)<<57)
#define PAGING_PAGE_FLAGS_IGNORED_6       (((__u64)1)<<58)
#define PAGING_PAGE_FLAGS_IGNORED_7       (((__u64)1)<<59)
#define PAGING_PAGE_FLAGS_IGNORED_8       (((__u64)1)<<60)
#define PAGING_PAGE_FLAGS_IGNORED_9       (((__u64)1)<<61)
#define PAGING_PAGE_FLAGS_IGNORED_10      (((__u64)1)<<62)
#define PAGING_PAGE_FLAGS_IGNORED \
  (PAGING_PAGE_FLAGS_IGNORED_0 |  \
   PAGING_PAGE_FLAGS_IGNORED_1 | \
   PAGING_PAGE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED_3 | \
   PAGING_PAGE_FLAGS_IGNORED_4 | \
   PAGING_PAGE_FLAGS_IGNORED_5 | \
   PAGING_PAGE_FLAGS_IGNORED_6 | \
   PAGING_PAGE_FLAGS_IGNORED_7 | \
   PAGING_PAGE_FLAGS_IGNORED_8 | \
   PAGING_PAGE_FLAGS_IGNORED_9 | \
   PAGING_PAGE_FLAGS_IGNORED_10)

// Specific to 4Kb pages:
#define PAGING_PTE_FLAGS_DIRTY      (((__u64)1)<<6)
#define PAGING_PTE_FLAGS_PAT        (((__u64)1)<<7)
#define PAGING_PTE_FLAGS_GLOBAL     (((__u64)1)<<8)
#define PAGING_PTE_FLAGS_IGNORED_0  (((__u64)1)<<9)
#define PAGING_PTE_FLAGS_IGNORED_1  (((__u64)1)<<10)
#define PAGING_PTE_FLAGS_IGNORED_2  (((__u64)1)<<11)
#define PAGING_PTE_FLAGS_IGNORED \
  (PAGING_PTE_FLAGS_IGNORED_0 | \
   PAGING_PTE_FLAGS_IGNORED_1 | \
   PAGING_PTE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PTE_FLAGS_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 2Mb page tables:
#define PAGING_PDE_FLAGS_PAGE_DIRTY      (((__u64)1)<<6)
#define PAGING_PDE_FLAGS_TABLE_IGNORED_0 (((__u64)1)<<6)
#define PAGING_PDE_FLAGS_PAGE            (((__u64)1)<<7)
#define PAGING_PDE_FLAGS_PAGE_GLOBAL     (((__u64)1)<<8)
#define PAGING_PDE_FLAGS_TABLE_IGNORED_1 (((__u64)1)<<8)
#define PAGING_PDE_FLAGS_IGNORED_0       (((__u64)1)<<9)
#define PAGING_PDE_FLAGS_IGNORED_1       (((__u64)1)<<10)
#define PAGING_PDE_FLAGS_IGNORED_2       (((__u64)1)<<11)
#define PAGING_PDE_FLAGS_PAGE_PAT        (((__u64)1)<<12)
#define PAGING_PDE_FLAGS_PAGE_IGNORED \
  (PAGING_PDE_FLAGS_IGNORED_0 | \
   PAGING_PDE_FLAGS_IGNORED_1 | \
   PAGING_PDE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PDE_FLAGS_TABLE_IGNORED \
  (PAGING_PDE_FLAGS_TABLE_IGNORED_0 | \
   PAGING_PDE_FLAGS_TABLE_IGNORED_1 | \
   PAGING_PDE_FLAGS_PAGE_IGNORED)
#define PAGING_PDE_FLAGS_PAGE_RESERVED  (((__u64)0x1FE000) | PAGING_GLOBAL_RESERVED)
#define PAGING_PDE_FLAGS_TABLE_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 1Gb page tables:
#define PAGING_PDPTE_FLAGS_PAGE_DIRTY      (((__u64)1)<<6)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED_0 (((__u64)1)<<6)
#define PAGING_PDPTE_FLAGS_PAGE            (((__u64)1)<<7)
#define PAGING_PDPTE_FLAGS_PAGE_GLOBAL     (((__u64)1)<<8)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED_1 (((__u64)1)<<8)
#define PAGING_PDPTE_FLAGS_IGNORED_0       (((__u64)1)<<9)
#define PAGING_PDPTE_FLAGS_IGNORED_1       (((__u64)1)<<10)
#define PAGING_PDPTE_FLAGS_IGNORED_2       (((__u64)1)<<11)
#define PAGING_PDPTE_FLAGS_PAGE_PAT        (((__u64)1)<<12)
#define PAGING_PDPTE_FLAGS_PAGE_IGNORED \
  (PAGING_PDPTE_FLAGS_IGNORED_0 | \
   PAGING_PDPTE_FLAGS_IGNORED_1 | \
   PAGING_PDPTE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED \
  (PAGING_PDPTE_FLAGS_TABLE_IGNORED_0 | \
   PAGING_PDPTE_FLAGS_TABLE_IGNORED_1 | \
   PAGING_PDPTE_FLAGS_PAGE_IGNORED)
#define PAGING_PDPTE_FLAGS_PAGE_RESERVED  (0x3FFFE000 | PAGING_GLOBAL_RESERVED)
#define PAGING_PDPTE_FLAGS_TABLE_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 512Gb page tables:
#define PAGING_PML4E_FLAGS_IGNORED_0  (((__u64)1)<<6)
#define PAGING_PML4E_FLAGS_RESERVED_0 (((__u64)1)<<7)
#define PAGING_PML4E_FLAGS_IGNORED_1  (((__u64)1)<<8)
#define PAGING_PML4E_FLAGS_IGNORED_2  (((__u64)1)<<9)
#define PAGING_PML4E_FLAGS_IGNORED_3  (((__u64)1)<<10)
#define PAGING_PML4E_FLAGS_IGNORED_4  (((__u64)1)<<11)
#define PAGING_PML4E_FLAGS_IGNORED \
  (PAGING_PML4E_FLAGS_IGNORED_0 | \
   PAGING_PML4E_FLAGS_IGNORED_1 | \
   PAGING_PML4E_FLAGS_IGNORED_2 | \
   PAGING_PML4E_FLAGS_IGNORED_3 | \
   PAGING_PML4E_FLAGS_IGNORED_4 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PML4E_FLAGS_RESERVED \
  (PAGING_PML4E_FLAGS_RESERVED_0 | \
   PAGING_GLOBAL_RESERVED)

/* These values are set by the boot code before jumping to kernel space. 
extern PML4T PML4Tables;
extern PDPT PDPTIdentity;
extern PDPT PDPTKernel;

namespace {
  PML4T* KernelPML4Table;
  PDPT* KernelPDPTIdentity;
  PDPT* KernelPDPTMapped;
  
  bool PDPT1GbTablesAllowed;
}*/

void paging::setup_paging() {
  
}

void allocate_kernel_page() {

}

