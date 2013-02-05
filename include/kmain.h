#ifndef __KMAIN_H
#define __KMAIN_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

  void kmain();

  int isCanonicalAddress(const void*);

  void* allocateKernelPages(size_t size);
  void* allocateUserPages(size_t size);

  void freeKernelPage(void* mem);
  void freeUserPage(void* mem);

#ifdef __cplusplus
}
#endif

#endif /* __KMAIN_H */
