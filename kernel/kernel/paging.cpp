#include "paging.hpp"

namespace
{
    void* create_virtual_address(const uint16_t pml4, const uint16_t pdpte, const uint16_t pde, const uint16_t pte)
    {
        uint64_t addr = 0;
        if (pml4 & 0x100) {
            addr |= (((uint64_t) 0xffff) << 47);
        }
        addr |= (((uint64_t) pml4) << 39);
        addr |= (pdpte << 30);
        addr |= (pde << 21);
        addr |= (pte << 12);
        return (void*) addr;
    }

    PageTable* get_base_table()
    {
        return (PageTable*) create_virtual_address(PageTable::IDENTITY_INDEX,
                                                   PageTable::IDENTITY_INDEX,
                                                   PageTable::IDENTITY_INDEX,
                                                   PageTable::IDENTITY_INDEX);
    }

    void map_page_to_frame(PageTableEntry& page, const void* frame, const uint64_t flags)
    {
        page.contents = ((uint64_t) frame) | flags;
    }

    void* virtual_to_physical(void* virtual_addr)
    {
        uint64_t offset = ((uint64_t) virtual_addr) % PAGE_SIZE;

    }

} // namespace

void handle_page_fault(uint64_t /*error_code*/, void*/*address*/)
{

}

kernel::Page& kernel::Page::get_page_pml4_table()
{
    static Page pml4Table(510, 510, 510, 510);
    return pml4Table;
}

void* kernel::Page::get_virtual_address()
{
    uint64_t addr = 0;
    if (pml4 & 0x100) {
        addr |= (((uint64_t) 0xffff) << 47);
    }
    addr |= (((uint64_t) pml4) << 39);
    addr |= (pdpte << 30);
    addr |= (pde << 21);
    addr |= (pte << 12);
    return (void*) addr;
}

void* kernel::Page::get_physical_address()
{
    uint64_t addr = 0;
    if (pml4 & 0x100) {
        addr |= (((uint64_t) 0xffff) << 47);
    }
    addr |= (((uint64_t) pml4) << 39);
    addr |= (pdpte << 30);
    addr |= (pde << 21);
    addr |= (pte << 12);
    return (void*) addr;
}
/*
    0	present	the page is currently in memory
    1	writable	it's allowed to write to this page
    2	user accessible	if not set, only kernel mode code can access this page
    3	write through caching	writes go directly to memory
    4	disable cache	no cache is used for this page
    5	accessed	the CPU sets this bit when this page is used
    6	dirty	the CPU sets this bit when a write to this page occurs
    7	huge page/null	must be 0 in P1 and P4, creates a 1GiB page in P3, creates a 2MiB page in P2
    8	global	page isn't flushed from caches on address space switch (PGE bit of CR4 register must be set)
    9-11	available	can be used freely by the OS
    12-51	physical address	the page aligned 52bit physical address of the frame or the next page table
    52-62	available	can be used freely by the OS
    63	no execute	forbid executing code on this page (the NXE bit in the EFER register must be set)
    */
static const uint64_t PRESENT = 1 << 0;
static const uint64_t WRITABLE = 1 << 1;
static const uint64_t USER = 1 << 2;
static const uint64_t WTC = 1 << 3;
static const uint64_t DC = 1 << 4;
static const uint64_t ACCESSED = 1 << 5;
static const uint64_t DIRTY = 1 << 6;
static const uint64_t HUGE = 1 << 7;
static const uint64_t GLOBAL = 1 << 8;

namespace
{
    class FrameAllocatorInstance : public kernel::FrameAllocator
    {
    public:
        FrameAllocatorInstance()
                : kernel::FrameAllocator((multiboot_tag_mmap*) kernel::multiboot2::find_tag(MULTIBOOT_TAG_TYPE_MMAP))
        {
        }

    private:
        FrameAllocatorInstance(const FrameAllocatorInstance&) = delete;

        FrameAllocatorInstance(FrameAllocatorInstance&&) = delete;
    };
}

static kernel::FrameAllocator& kernel::FrameAllocator::get_instance()
{
    static FrameAllocatorInstance instance;
    return instance;
}

kernel::FrameAllocator::FrameAllocator(const multiboot_tag_mmap* mmap)
        : memoryBlocksCount(0)
{
    if (mmap != nullptr) {
        const multiboot_mmap_entry* entry = &(mmap->entries[0]);
        const multiboot_uint32_t entry_size = mmap->entry_size;
        const void* map_end = mmap + mmap->size;
        while (entry < map_end && memoryBlocksCount < MAX_BLOCKS) {
            // Note: memory blocks that don't fit into the array are discarded. This is unlikely, unless
            // the memory map gets quite complex.
            if (entry->type == MULTIBOOT_MEMORY_AVAILABLE) {
                memoryBlocks[memoryBlocksCount++] = {(void*) entry->addr, entry->len / FRAME_SIZE};
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
    nextFreeFrame = (uint8_t*) nextFreeFrame + (frame_count * FRAME_SIZE);
    framesLeftInBlock -= frame_count;
}

void* kernel::FrameAllocator::allocate_frame()
{
    void* addr = nullptr;
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
        nextFreeFrame = ((uint8_t*) nextFreeFrame) + FRAME_SIZE;
        --framesLeftInBlock;
    } while (kernel_physical_start <= nextFreeFrame && nextFreeFrame <= kernel_physical_end);
    return addr;
}

void kernel::FrameAllocator::deallocate_frame(void* /* frame */)
{
    // TODO: Return frames somehow.
}

void* kernel::create_virtual_address(const uint16_t pml4, const uint16_t pdpte, const uint16_t pde, const uint16_t pte)
{
    uint64_t addr = 0;
    if (pml4 & 0x100) {
        addr |= (((uint64_t) 0xffff) << 47);
    }
    addr |= (((uint64_t) pml4) << 39);
    addr |= (pdpte << 30);
    addr |= (pde << 21);
    addr |= (pte << 12);
    return (void*) addr;
}

void* kernel::allocate_kmem_page()
{
    return nullptr;
}
