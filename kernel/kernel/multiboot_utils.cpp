#include "kernel/multiboot_utils.h"

#define MULTIBOOT_TAG_ALIGN_MASK (MULTIBOOT_TAG_ALIGN - 1)

static const multiboot_tag *mb2_first_tag;
static multiboot_uint32_t max_size;

void initialize_multiboot2(const void *mb_info) {
    max_size = *((const multiboot_uint32_t *) mb_info);
    mb2_first_tag = ((const multiboot_tag *) mb_info + 8);
}

bool initialize_multiboot(const multiboot_uint32_t magic, const void *mb_info) {
    if (magic == MULTIBOOT2_BOOTLOADER_MAGIC) {
        initialize_multiboot2(mb_info);
        return false;
    }
    return true;
}

const multiboot_tag *find_tag(const multiboot_uint32_t type) {
    const multiboot_tag* tag = mb2_first_tag;
    while (tag->type != type) {
        if (tag->type == MULTIBOOT_TAG_TYPE_END) {
            return nullptr;
        }
        tag += (tag->size + MULTIBOOT_TAG_ALIGN_MASK) & ~MULTIBOOT_TAG_ALIGN_MASK;
    }
    return tag;
}
