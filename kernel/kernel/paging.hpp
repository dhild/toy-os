#ifndef TOY_OS_KERNEL_PAGING_HPP
#define TOY_OS_KERNEL_PAGING_HPP

#include <kernel/main.hpp>
#include <kernel/multiboot_utils.hpp>

namespace kernel
{
    class Page
    {
    public:
        static const uint64_t PAGE_SIZE = 4096;

        void* get_virtual_address();

        void* get_physical_address();

        bool isPresent();
        bool isWritable();
        bool isUser();

        void setPresent(bool present);
        void setWritable(bool writable);
        void setUser(bool user);

    private:
        static Page& get_page_pml4_table();

        uint16_t pml4;
        uint16_t pdpte;
        uint16_t pde;
        uint16_t pte;

        Page(const uint16_t _pml4, const uint16_t _pdpte, const uint16_t _pde, const uint16_t _pte)
                : pml4(_pml4), pdpte(_pdpte), pde(_pde), pte(_pte)
        {
        }
    };

    class PageTable
    {
    protected:
        Page location;

        PageTable(Page&& _location) : location(_location)
        {
        }
    };

    class PageTable4 : public PageTable {
    public:
        static PageTable4& get_active_instance();
    };

    class FrameAllocator
    {
    public:
        static const uint64_t FRAME_SIZE = Page::PAGE_SIZE;

        FrameAllocator(const multiboot_tag_mmap* mmap);

        static FrameAllocator& get_instance();

        void* allocate_frame();

        void deallocate_frame(void* frame);

    private:
        FrameAllocator(const FrameAllocator&) = delete;

        FrameAllocator(FrameAllocator&&) = delete;

        void* nextFreeFrame;
        uint64_t framesLeftInBlock;

        struct MemoryBlock
        {
            void* address;
            uint64_t size_in_frames;
        };

        static const uint16_t MAX_BLOCKS = 64;

        MemoryBlock memoryBlocks[MAX_BLOCKS];
        uint64_t memoryBlocksCount;
        uint64_t nextFreeIndex;
    };

    struct PageTableEntry
    {
        uint64_t contents;

        void* getPhysicalAddress()
        {
            return (void*) (contents & 0x000ffffffffff000);
        }
    };

    class PageTable
    {
        PageTableEntry entry[512];

        static const uint16_t IDENTITY_INDEX = 510;

        static PageTable& getPML4();
    };

    void* create_virtual_address(const uint16_t pml4, const uint16_t pdpte, const uint16_t pde, const uint16_t pte);

    extern "C" {
    /** Declared by the linker. */
    const void* kernel_physical_start;
    /** Declared by the linker. */
    const void* kernel_physical_end;

    void handle_page_fault(uint64_t /*error_code*/, void*/*address*/);
    }
} // namespace kernel

#endif //TOY_OS_KERNEL_PAGING_HPP
