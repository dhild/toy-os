#include "kernel/multiboot_utils.h"

#define MULTIBOOT_TAG_ALIGN_MASK (MULTIBOOT_TAG_ALIGN - 1)

extern "C" {
    const multiboot_tag* mb2_info_first_tag;
    multiboot_uint32_t mb2_info_max_size;
}

const multiboot_tag *kernel::multiboot2::find_tag(const multiboot_uint32_t type) {
    const multiboot_tag* tag = mb2_info_first_tag;
    while (tag->type != type) {
        if (tag->type == MULTIBOOT_TAG_TYPE_END) {
            return nullptr;
        }
        tag += (tag->size + MULTIBOOT_TAG_ALIGN_MASK) & ~MULTIBOOT_TAG_ALIGN_MASK;
    }
    return tag;
}
