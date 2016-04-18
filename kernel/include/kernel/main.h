#ifndef TOY_OS_KERNEL_MAIN_H
#define TOY_OS_KERNEL_MAIN_H

#include <kernel/config.h>

extern "C" {

void kernel_main(const uint32_t magic, const void *mb_info);

}

#endif //TOY_OS_KERNEL_MAIN_H
