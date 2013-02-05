#ifndef KERNEL_PAGING_H
#define KERNEL_PAGING_H

#include <types.h>

namespace paging {

  typedef __u64 PML4E;
  typedef __u64 PDPTE;
  typedef __u64 PDTE;
  typedef __u64 PTE;
  
  typedef struct PML4T {
    PML4E entry[512];
  } PML4T;
  typedef struct PDPT {
    PDPTE entry[512];
  } PDPT;
  typedef struct PDT {
    PDTE entry[512];
  } PDT;
  typedef struct PT {
    PTE entry[512];
  } PT;

  void allocate_kernel_page(void* linearAddress);
  void allocate_user_page(PML4T* page_data, void* linearAddress);
  
  void load_page(PML4T* page_data, void* linearAddress);
  
  void delete_kernel_page(void* linearAddress);
  void delete_user_page(PML4T* page_data, void* linearAddress);

} /* namespace paging */

#endif /* KERNEL_PAGING_H */
