#ifndef TOY_OS_KERNEL_MAIN_HPP
#define TOY_OS_KERNEL_MAIN_HPP

#include <kernel/config.hpp>
#include <multiboot2.h>


namespace kernel
{
    extern "C" {
    void kernel_main();
    }

    void* allocate_kmem_page();
} // namespace kernel


#endif //TOY_OS_KERNEL_MAIN_HPP
