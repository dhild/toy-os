#ifndef TOY_OS_KERNEL_MULTIBOOT_UTILS_H
#define TOY_OS_KERNEL_MULTIBOOT_UTILS_H

#include <multiboot2.h>

namespace kernel
{
    namespace multiboot2
    {
        const multiboot_tag *find_tag(const multiboot_uint32_t type);
    } // namespace multiboot2
} // namespace kernel

#endif //TOY_OS_KERNEL_MULTIBOOT_UTILS_H
