#ifndef PAGING_H
#define PAGING_H

#include <stdint.h>
#include <kernel/paging.h>

namespace paging {

  void setup_paging();

  extern PML4T* KernelPML4Table;
  extern PDPT* KernelPDPTIdentity;
  extern PDPT* KernelPDPTMapped;
  extern bool PDPT1GbTablesAllowed;

  void getAddressInfo(void* address, PML4E* pml4e=NULL, PDPTE* pdpte=NULL, PDTE* pdte=NULL, PTE* pte=NULL);

} /* namespace paging */

#endif
