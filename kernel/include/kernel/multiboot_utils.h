#ifndef TOY_OS_KERNEL_MULTIBOOT_UTILS_H
#define TOY_OS_KERNEL_MULTIBOOT_UTILS_H

#include <multiboot2.h>

bool initialize_multiboot(const multiboot_uint32_t magic, const void *mb_info);

const multiboot_tag* find_tag(const multiboot_uint32_t type);

#endif //TOY_OS_KERNEL_MULTIBOOT_UTILS_H
