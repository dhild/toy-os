#ifndef PAGING_H
#define PAGING_H

#include <config.h>
#include <kernel/paging.h>

namespace paging {

  void setup_paging();

  PML4T* setup_user_paging();

} /* namespace paging */

#endif
