#include <kernel/main.h>
#include <kernel/multiboot_utils.h>
#include <kernel/early_video.h>

bool initialize(const uint32_t magic, const void *mb_info) {
    if (initialize_multiboot(magic, mb_info)) {
        return true;
    }
    if (initialize_video()) {
        return true;
    }
    return false;
}

void kernel_main(const uint32_t magic, const void *mb_info) {
    if (initialize(magic, mb_info)) {
        // Error, fall out
        return;
    }
}
