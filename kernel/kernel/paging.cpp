#include <kernel/paging.hpp>
#include <kernel/multiboot_utils.h>

extern "C" {
const void *kernel_physical_start;
const void *kernel_physical_end;

void handle_page_fault(uint64_t /*flags*/, void */*address*/)
{

}
}

kernel::FrameAllocator &kernel::FrameAllocator::get_instance()
{
    static FrameAllocator instance;
    return instance;
}

kernel::FrameAllocator::FrameAllocator()
        : memoryBlocks(nullptr), memoryBlocksCount(0)
{
    const multiboot_tag_mmap *mmap = (multiboot_tag_mmap *) kernel::multiboot2::find_tag(MULTIBOOT_TAG_TYPE_MMAP);
    if (mmap != nullptr) {
        const multiboot_mmap_entry *entry = &(mmap->entries[0]);
        const multiboot_uint32_t entry_size = mmap->entry_size;
        const void *map_end = mmap + mmap->size;
        while (entry < map_end) {
            if (entry->type == MULTIBOOT_MEMORY_AVAILABLE) {
                if (memoryBlocks == nullptr) {
                    // Setup with an offset so that we don't match twice here:
                    memoryBlocks = (MemoryBlock *) (entry->addr + 8);
                } else if (((memoryBlocksCount * sizeof(MemoryBlock)) / FRAME_SIZE) > memoryBlocks[0].size_in_frames) {
                    // Note: memory blocks that don't fit into the first page are discarded. This is unlikely, unless
                    // the memory map gets quite complex.
                    break;
                }
                memoryBlocks[memoryBlocksCount] = {(void *) entry->addr, entry->len / FRAME_SIZE};
                ++memoryBlocksCount;
            }
            entry += entry_size;
        }
    }
    // Store the memory blocks in that first block.
    // If we wanted to, we could move them to any free frame at this point.
    nextFreeFrame = memoryBlocks[0].address;
    framesLeftInBlock = memoryBlocks[0].size_in_frames;
    nextFreeIndex = 1;
    uint64_t frame_count = 1 + ((memoryBlocksCount * sizeof(MemoryBlock)) / FRAME_SIZE);
    nextFreeFrame = (uint8_t *) nextFreeFrame + (frame_count * FRAME_SIZE);
    framesLeftInBlock -= frame_count;
}

void *kernel::FrameAllocator::allocate_frame()
{
    void *addr = nullptr;
    do {
        if (framesLeftInBlock == 0) {
            if (nextFreeIndex < memoryBlocksCount) {
                nextFreeFrame = memoryBlocks[nextFreeIndex].address;
                framesLeftInBlock = memoryBlocks[nextFreeIndex].size_in_frames;
                ++nextFreeIndex;
            } else {
                return nullptr;
            }
        }
        addr = nextFreeFrame;
        nextFreeFrame = ((uint8_t *) nextFreeFrame) + FRAME_SIZE;
        --framesLeftInBlock;
    } while (kernel_physical_start <= nextFreeFrame && nextFreeFrame <= kernel_physical_end);
    return addr;
}

void kernel::FrameAllocator::deallocate_frame(void * /* frame */)
{
    // TODO: Return frames somehow.
}
