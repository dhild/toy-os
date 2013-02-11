#include <kernel/kmain.h>
#include <kernel/paging.h>
#include "paging.h"

using namespace paging;

PML4T* paging::KernelPML4Table;
PDPT* paging::KernelPDPTIdentity;
PDPT* paging::KernelPDPTMapped;
bool paging::PDPT1GbTablesAllowed;

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
#define PAGING_ADDRESS_BITS ((uint64_t)48)
// These are based on PAGING_ADDRESS_BITS.
// They all MUST make sense together!
#define PAGING_GLOBAL_RESERVED     ((uint64_t)0x000F000000000000)
#define PAGING_CANNONICAL_BITS     ((uint64_t)0xFFFF000000000000)
#define PAGING_PTE_ADDRESS         ((uint64_t)0x0000FFFFFFFFF000)
#define PAGING_PDE_PAGE_ADDRESS    ((uint64_t)0x0000FFFFFFE00000)
#define PAGING_PDE_TABLE_ADDRESS   ((uint64_t)0x0000FFFFFFFFF000)
#define PAGING_PDPTE_PAGE_ADDRESS  ((uint64_t)0x0000FFFFC0000000)
#define PAGING_PDPTE_TABLE_ADDRESS ((uint64_t)0x0000FFFFFFFFF000)
#define PAGING_PML4E_TABLE_ADDRESS ((uint64_t)0x0000FFFFFFFFF000)

// Common to all page tables:
#define PAGING_PAGE_FLAGS_PRESENT         (((uint64_t)1)<<0)
#define PAGING_PAGE_FLAGS_WRITEABLE       (((uint64_t)1)<<1)
#define PAGING_PAGE_FLAGS_USER            (((uint64_t)1)<<2)
#define PAGING_PAGE_FLAGS_PWT             (((uint64_t)1)<<3)
#define PAGING_PAGE_FLAGS_PCD             (((uint64_t)1)<<4)
#define PAGING_PAGE_FLAGS_ACCESSED        (((uint64_t)1)<<5)
#define PAGING_PAGE_FLAGS_EXECUTE_DISABLE (((uint64_t)1)<<63)
#define PAGING_PAGE_FLAGS_IGNORED_0       (((uint64_t)1)<<52)
#define PAGING_PAGE_FLAGS_IGNORED_1       (((uint64_t)1)<<53)
#define PAGING_PAGE_FLAGS_IGNORED_2       (((uint64_t)1)<<54)
#define PAGING_PAGE_FLAGS_IGNORED_3       (((uint64_t)1)<<55)
#define PAGING_PAGE_FLAGS_IGNORED_4       (((uint64_t)1)<<56)
#define PAGING_PAGE_FLAGS_IGNORED_5       (((uint64_t)1)<<57)
#define PAGING_PAGE_FLAGS_IGNORED_6       (((uint64_t)1)<<58)
#define PAGING_PAGE_FLAGS_IGNORED_7       (((uint64_t)1)<<59)
#define PAGING_PAGE_FLAGS_IGNORED_8       (((uint64_t)1)<<60)
#define PAGING_PAGE_FLAGS_IGNORED_9       (((uint64_t)1)<<61)
#define PAGING_PAGE_FLAGS_IGNORED_10      (((uint64_t)1)<<62)
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
#define PAGING_PTE_FLAGS_DIRTY      (((uint64_t)1)<<6)
#define PAGING_PTE_FLAGS_PAT        (((uint64_t)1)<<7)
#define PAGING_PTE_FLAGS_GLOBAL     (((uint64_t)1)<<8)
#define PAGING_PTE_FLAGS_IGNORED_0  (((uint64_t)1)<<9)
#define PAGING_PTE_FLAGS_IGNORED_1  (((uint64_t)1)<<10)
#define PAGING_PTE_FLAGS_IGNORED_2  (((uint64_t)1)<<11)
#define PAGING_PTE_FLAGS_IGNORED \
  (PAGING_PTE_FLAGS_IGNORED_0 | \
   PAGING_PTE_FLAGS_IGNORED_1 | \
   PAGING_PTE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PTE_FLAGS_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 2Mb page tables:
#define PAGING_PDE_FLAGS_PAGE_DIRTY      (((uint64_t)1)<<6)
#define PAGING_PDE_FLAGS_TABLE_IGNORED_0 (((uint64_t)1)<<6)
#define PAGING_PDE_FLAGS_2_MB_PAGE       (((uint64_t)1)<<7)
#define PAGING_PDE_FLAGS_PAGE_GLOBAL     (((uint64_t)1)<<8)
#define PAGING_PDE_FLAGS_TABLE_IGNORED_1 (((uint64_t)1)<<8)
#define PAGING_PDE_FLAGS_IGNORED_0       (((uint64_t)1)<<9)
#define PAGING_PDE_FLAGS_IGNORED_1       (((uint64_t)1)<<10)
#define PAGING_PDE_FLAGS_IGNORED_2       (((uint64_t)1)<<11)
#define PAGING_PDE_FLAGS_PAGE_PAT        (((uint64_t)1)<<12)
#define PAGING_PDE_FLAGS_PAGE_IGNORED \
  (PAGING_PDE_FLAGS_IGNORED_0 | \
   PAGING_PDE_FLAGS_IGNORED_1 | \
   PAGING_PDE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PDE_FLAGS_TABLE_IGNORED \
  (PAGING_PDE_FLAGS_TABLE_IGNORED_0 | \
   PAGING_PDE_FLAGS_TABLE_IGNORED_1 | \
   PAGING_PDE_FLAGS_PAGE_IGNORED)
#define PAGING_PDE_FLAGS_PAGE_RESERVED  (((uint64_t)0x1FE000) | PAGING_GLOBAL_RESERVED)
#define PAGING_PDE_FLAGS_TABLE_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 1Gb page tables:
#define PAGING_PDPTE_FLAGS_PAGE_DIRTY      (((uint64_t)1)<<6)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED_0 (((uint64_t)1)<<6)
#define PAGING_PDPTE_FLAGS_1_GB_PAGE       (((uint64_t)1)<<7)
#define PAGING_PDPTE_FLAGS_PAGE_GLOBAL     (((uint64_t)1)<<8)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED_1 (((uint64_t)1)<<8)
#define PAGING_PDPTE_FLAGS_IGNORED_0       (((uint64_t)1)<<9)
#define PAGING_PDPTE_FLAGS_IGNORED_1       (((uint64_t)1)<<10)
#define PAGING_PDPTE_FLAGS_IGNORED_2       (((uint64_t)1)<<11)
#define PAGING_PDPTE_FLAGS_PAGE_PAT        (((uint64_t)1)<<12)
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
#define PAGING_PML4E_FLAGS_IGNORED_0  (((uint64_t)1)<<6)
#define PAGING_PML4E_FLAGS_RESERVED_0 (((uint64_t)1)<<7)
#define PAGING_PML4E_FLAGS_IGNORED_1  (((uint64_t)1)<<8)
#define PAGING_PML4E_FLAGS_IGNORED_2  (((uint64_t)1)<<9)
#define PAGING_PML4E_FLAGS_IGNORED_3  (((uint64_t)1)<<10)
#define PAGING_PML4E_FLAGS_IGNORED_4  (((uint64_t)1)<<11)
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

#define LINEAR_PML4_BITS 0xFF8000000000
#define LINEAR_PDPT_BITS 0x007FC0000000
#define LINEAR_PDT_BITS  0x00003FE00000
#define LINEAR_PT_BITS   0x0000001FF000
#define LINEAR_PML4_SHIFT 39
#define LINEAR_PDP_SHIFT 30
#define LINEAR_PD_SHIFT 21
#define LINEAR_PT_SHIFT 12

PDPT* pml4e_to_pdpt(PML4E pml4e) {
  return (PDPT*)(PAGING_PML4E_TABLE_ADDRESS & (uint64_t)pml4);
}

PDT* pdpte_to_pdt(PDPTE pdpt) {
  return (PDT*)(PAGING_PDPT_TABLE_ADDRESS & (uint64_t)pdpt);
}

PT* pdte_to_pt(PDTE pdt) {
  return (PT*)(PAGING_PDT_TABLE_ADDRESS & (uint64_t)pdt);
}

void paging::getAddressInfo(void* address, PML4E* pml4e, PDPTE* pdpte, PDTE* pdte, PTE* pte) {
  uint64_t index = ((uint64_t)address & LINEAR_PML4_BITS) >> LINEAR_PML4_SHIFT;
  PML4E pml4e1 = KernelPML4Table->entry[index];

  if (pml4e != NULL)
    *pml4e = pml4e1;

  PDPT* pdpt = pml4e_to_pdpt(pml4e1);
  index = ((uint64_t)address & LINEAR_PDPT_BITS) >> LINEAR_PDPT_SHIFT;
  PDPTE pdpte1 = pdpt->entry[index];

  if (pdpte != NULL)
    *pdpte = pdpte1;

  if (pdpte1 & PAGING_PDPTE_FLAGS_1_GB_PAGE)
    return;

  PDT* pdt = pdpte_to_pdt(pdpte1);
  index = ((uint64_t)address & LINEAR_PDT_BITS) >> LINEAR_PDT_SHIFT;
  PML4E pdte1 = pdt->entry[index];

  if (pdte != NULL)
    *pdte = pdte1;

  if (pdte1 & PAGING_PDE_FLAGS_2_MB_PAGE)
    return;

  if (pte == NULL)
    return;

  PT* pt = pdte_to_pt(pdte1);
  index = ((uint64_t)address & LINEAR_PT_BITS) >> LINEAR_PT_SHIFT;
  PTE pte1 = pt->entry[index];
}

void paging::setup_paging() {
  uint32_t flags;
  asm volatile (
        "mov $0x80000001, %%eax\n\t"
        "cpuid\n\t"
	: "=d"(flags)
	:
	: "%rax", "%rbx", "%rcx" );

  PDPT1GbTablesAllowed = flags & (1<<26);

  asm volatile (
        "mov %%cr3, %%rax\n\t"
        "mov %%rax, %0\n\t"
	: "=m"(KernelPML4Table)
	:
	: "%rax"
	);

  KernelPDPTIdentity = (PDPT*)((KernelPML4Table->entry[0]) & (PAGING_PDPTE_TABLE_ADDRESS | PAGING_CANNONICAL_BITS));
  KernelPDPTMapped = (PDPT*)((KernelPML4Table->entry[384]) & (PAGING_PDPTE_TABLE_ADDRESS | PAGING_CANNONICAL_BITS));
}

