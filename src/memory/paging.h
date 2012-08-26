#ifndef PAGING_H
#define PAGING_H

#include "types.h"

#define PAGING_USE_BUDDY_ALLOCATOR

namespace paging {

  void initialize();

  void * allocate(const size_t);
  void free(void *);

  bool isCanonicalAddress(const void *);

  void setupPagingInternals();

  typedef qword PML4TE;
  typedef qword PDPTE;
  typedef qword PDTE;
  typedef qword PTE;

  struct PML4T {
    PML4TE entry[512];
  };
  struct PDPT {
    PDPTE entry[512];
  };
  struct PDT {
    PDTE entry[512];
  };
  struct PT {
    PTE entry[512];
  };

  bool setupPageTable(PT * tables, const void * address, const qword flags);
  bool setupPageDirectory(PDT * tables, const void * address, const qword flags);
  bool setupPageDirectory(PDT * tables, const PT * address, const qword flags);
  bool setupPageDirectoryPointer(PDPT * tables, const void * address, const qword flags);
  bool setupPageDirectoryPointer(PDPT * tables, const PDT * address, const qword flags);

  PML4T * getPML4T();
  PDPT * getPDPTLow();
  PDPT * getPDPTHigh();
  PDT * getPDTStart();
  PT * getPTStart();
  void * getMemoryStart();
  void * getMemoryEnd();
  size_t getMemorySize();

  bool setPTE(PTE * page, const void * address, const qword flags);
  bool setPDTETable(PDTE * page, const void * address, const qword flags);
  bool setPDTEPage(PDTE * page, const void * address, const qword flags);
  bool setPDPTETable(PDPTE * page, const void * address, const qword flags);
  bool setPDPTEPage(PDPTE * page, const void * address, const qword flags);
  bool setPML4E(PML4E * page, const void * address, const qword flags);

}

// How many bits are used in each address?
#define PAGING_ADDRESS_BITS 48
// These are based on PAGING_ADDRESS_BITS.
// They all MUST make sense together!
#define PAGING_CANNONICAL_BITS     (0xFFFF000000000000)
#define PAGING_GLOBAL_RESERVED     (0x000F000000000000)
#define PAGING_PTE_ADDRESS         (0x0000FFFFFFFFF000)
#define PAGING_PDE_PAGE_ADDRESS    (0x0000FFFFFFE00000)
#define PAGING_PDE_TABLE_ADDRESS   (0x0000FFFFFFFFF000)
#define PAGING_PDPTE_PAGE_ADDRESS  (0x0000FFFFC0000000)
#define PAGING_PDPTE_TABLE_ADDRESS (0x0000FFFFFFFFF000)
#define PAGING_PML4E_TABLE_ADDRESS (0x0000FFFFFFFFF000)

// Common to all page tables:
#define PAGING_PAGE_FLAGS_PRESENT         (1<<0)
#define PAGING_PAGE_FLAGS_WRITEABLE       (1<<1)
#define PAGING_PAGE_FLAGS_USER            (1<<2)
#define PAGING_PAGE_FLAGS_PWT             (1<<3)
#define PAGING_PAGE_FLAGS_PCD             (1<<4)
#define PAGING_PAGE_FLAGS_ACCESSED        (1<<5)
#define PAGING_PAGE_FLAGS_EXECUTE_DISABLE (1<<63)
#define PAGING_PAGE_FLAGS_IGNORED_0       (1<<52)
#define PAGING_PAGE_FLAGS_IGNORED_1       (1<<53)
#define PAGING_PAGE_FLAGS_IGNORED_2       (1<<54)
#define PAGING_PAGE_FLAGS_IGNORED_3       (1<<55)
#define PAGING_PAGE_FLAGS_IGNORED_4       (1<<56)
#define PAGING_PAGE_FLAGS_IGNORED_5       (1<<57)
#define PAGING_PAGE_FLAGS_IGNORED_6       (1<<58)
#define PAGING_PAGE_FLAGS_IGNORED_7       (1<<59)
#define PAGING_PAGE_FLAGS_IGNORED_8       (1<<60)
#define PAGING_PAGE_FLAGS_IGNORED_9       (1<<61)
#define PAGING_PAGE_FLAGS_IGNORED_10      (1<<62)
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
#define PAGING_PTE_FLAGS_DIRTY      (1<<6)
#define PAGING_PTE_FLAGS_PAT        (1<<7)
#define PAGING_PTE_FLAGS_GLOBAL     (1<<8)
#define PAGING_PTE_FLAGS_IGNORED_0  (1<<9)
#define PAGING_PTE_FLAGS_IGNORED_1  (1<<10)
#define PAGING_PTE_FLAGS_IGNORED_2  (1<<11)
#define PAGING_PTE_FLAGS_IGNORED \
  (PAGING_PTE_FLAGS_IGNORED_0 | \
   PAGING_PTE_FLAGS_IGNORED_1 | \
   PAGING_PTE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PTE_FLAGS_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 2Mb page tables:
#define PAGING_PDE_FLAGS_PAGE_DIRTY      (1<<6)
#define PAGING_PDE_FLAGS_TABLE_IGNORED_0 (1<<6)
#define PAGING_PDE_FLAGS_PAGE            (1<<7)
#define PAGING_PDE_FLAGS_PAGE_GLOBAL     (1<<8)
#define PAGING_PDE_FLAGS_TABLE_IGNORED_1 (1<<8)
#define PAGING_PDE_FLAGS_IGNORED_0       (1<<9)
#define PAGING_PDE_FLAGS_IGNORED_1       (1<<10)
#define PAGING_PDE_FLAGS_IGNORED_2       (1<<11)
#define PAGING_PDE_FLAGS_PAGE_PAT        (1<<12)
#define PAGING_PDE_FLAGS_PAGE_IGNORED \
  (PAGING_PDE_FLAGS_IGNORED_0 | \
   PAGING_PDE_FLAGS_IGNORED_1 | \
   PAGING_PDE_FLAGS_IGNORED_2 | \
   PAGING_PAGE_FLAGS_IGNORED)
#define PAGING_PDE_FLAGS_TABLE_IGNORED \
  (PAGING_PDE_FLAGS_TABLE_IGNORED_0 | \
   PAGING_PDE_FLAGS_TABLE_IGNORED_1 | \
   PAGING_PDE_FLAGS_PAGE_IGNORED)
#define PAGING_PDE_FLAGS_PAGE_RESERVED  (0x1FE000 | PAGING_GLOBAL_RESERVED)
#define PAGING_PDE_FLAGS_TABLE_RESERVED PAGING_GLOBAL_RESERVED

// Specific to 1Gb page tables:
#define PAGING_PDPTE_FLAGS_PAGE_DIRTY      (1<<6)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED_0 (1<<6)
#define PAGING_PDPTE_FLAGS_PAGE            (1<<7)
#define PAGING_PDPTE_FLAGS_PAGE_GLOBAL     (1<<8)
#define PAGING_PDPTE_FLAGS_TABLE_IGNORED_1 (1<<8)
#define PAGING_PDPTE_FLAGS_IGNORED_0       (1<<9)
#define PAGING_PDPTE_FLAGS_IGNORED_1       (1<<10)
#define PAGING_PDPTE_FLAGS_IGNORED_2       (1<<11)
#define PAGING_PDPTE_FLAGS_PAGE_PAT        (1<<12)
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
#define PAGING_PML4E_FLAGS_IGNORED_0  (1<<6)
#define PAGING_PML4E_FLAGS_RESERVED_0 (1<<7)
#define PAGING_PML4E_FLAGS_IGNORED_1  (1<<8)
#define PAGING_PML4E_FLAGS_IGNORED_2  (1<<9)
#define PAGING_PML4E_FLAGS_IGNORED_3  (1<<10)
#define PAGING_PML4E_FLAGS_IGNORED_4  (1<<11)
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

#endif
